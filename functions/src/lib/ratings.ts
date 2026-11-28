import type { Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";

/** Smoothing prior for the ranking score: "4.0 stars worth 5 reviews". */
export const RATING_PRIOR_MEAN = 4.0;
export const RATING_PRIOR_WEIGHT = 5;

const isStars = (v: unknown): v is number => Number.isInteger(v) && (v as number) >= 1 && (v as number) <= 5;

/** Shown average: one decimal, 0 when there is no review. */
export function ratingAvgOf(sum: number, count: number): number {
  return count > 0 ? Math.round((sum / count) * 10) / 10 : 0;
}

/**
 * Server-only smoothed average used to rank "best rated":
 * (4.0 * 5 + ratingSum) / (5 + ratingCount). A provider with no review scores
 * the prior (4.0), so one 5-star review does not outrank a long record.
 */
export function ratingScoreOf(sum: number, count: number): number {
  return Math.round(((RATING_PRIOR_MEAN * RATING_PRIOR_WEIGHT + sum) / (RATING_PRIOR_WEIGHT + count)) * 10000) / 10000;
}

export interface RatingFields {
  ratingSum: number;
  ratingCount: number;
  ratingAvg: number;
  ratingScore: number;
}

export function ratingFieldsOf(sum: number, count: number): RatingFields {
  return {
    ratingSum: sum,
    ratingCount: count,
    ratingAvg: ratingAvgOf(sum, count),
    ratingScore: ratingScoreOf(sum, count),
  };
}

/**
 * Recomputes `providers/{id}` rating fields from its reviews, in a transaction
 * (the reviews are read inside it, so a concurrent review write retries it).
 *
 * Recomputing from the reviews instead of applying a delta is what makes it
 * idempotent: a re-delivered event, or the anonymising move of deleteAccount
 * (delete + create with the same rating), gives the same totals. Never creates
 * the provider; returns true when it wrote.
 */
export async function recomputeProviderRating(db: Firestore, providerId: string): Promise<boolean> {
  const providerRef = db.collection("providers").doc(providerId);
  const reviewsQuery = providerRef.collection("reviews").select("rating");
  return db.runTransaction(async (tx) => {
    const [provider, reviews] = await Promise.all([tx.get(providerRef), tx.get(reviewsQuery)]);
    if (!provider.exists) return false;
    let sum = 0;
    let count = 0;
    for (const r of reviews.docs) {
      const rating = r.get("rating");
      if (isStars(rating)) {
        sum += rating;
        count++;
      }
    }
    const next = ratingFieldsOf(sum, count);
    const prev = provider.data() as Partial<RatingFields>;
    const same = (Object.keys(next) as Array<keyof RatingFields>).every((k) => prev[k] === next[k]);
    if (same) return false;
    tx.update(providerRef, { ...next });
    return true;
  });
}
