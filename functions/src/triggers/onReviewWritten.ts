import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { recomputeProviderRating } from "../lib/ratings.js";

/**
 * TDD §6.1. A review was added, edited or deleted: recompute the provider's
 * `ratingSum` / `ratingCount` / `ratingAvg` / `ratingScore` from the reviews.
 * Idempotent (see `recomputeProviderRating`); the provider write then flows to
 * the provider's listings through `onProviderWritten`.
 */
export const onReviewWritten = onDocumentWritten(
  { document: "providers/{providerId}/reviews/{reviewerId}", region: REGION },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const { providerId, reviewerId } = event.params;
    const before = change.before.exists ? change.before.data() : undefined;
    const after = change.after.exists ? change.after.data() : undefined;
    // Text-only edits and provider replies do not move the rating.
    if (before && after && before.rating === after.rating) return;
    const wrote = await recomputeProviderRating(getFirestore(), providerId);
    logger.info("onReviewWritten", {
      providerId,
      reviewerId,
      kind: !before ? "create" : !after ? "delete" : "update",
      wrote,
    });
  },
);
