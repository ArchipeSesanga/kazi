import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { approveProviderIfExists } from "../lib/approveProvider.js";
import { ratingScoreOf } from "../lib/ratings.js";
import { reconcileListing } from "../lib/reconcile.js";

const WATCHED = ["displayName", "photoUrl", "verified", "ratingAvg", "ratingCount", "ratingScore", "status"];

/**
 * TDD §6.1 (subset):
 *  - v1 auto-approval: a provider that is `pending` on create (or resubmitted
 *    from `rejected`) becomes `approved` when
 *    `config/moderation.autoApproveProviders == true`;
 *  - keeps the server-only `ratingScore` present (new providers start at the prior);
 *  - when a denormalised field changes, recompute the provider's listings.
 */
export const onProviderWritten = onDocumentWritten(
  { document: "providers/{providerId}", region: REGION },
  async (event) => {
    const change = event.data;
    if (!change?.after.exists) return;
    const db = getFirestore();
    const { providerId } = event.params;
    const before = change.before.exists ? change.before.data() : undefined;
    const after = change.after.data()!;

    const justSubmitted =
      after.status === "pending" && (!before || before.status === "rejected");
    if (justSubmitted) {
      const cfg = await db.collection("config").doc("moderation").get();
      if (cfg.data()?.autoApproveProviders === true) {
        await approveProviderIfExists(change.after.ref);
        return; // the resulting write re-enters here and propagates
      }
    }

    // `ratingScore` is server-only and clients cannot create it, so a new
    // (or pre-existing) provider gets it here; the write re-enters this trigger.
    const score = ratingScoreOf(after.ratingSum ?? 0, after.ratingCount ?? 0);
    if (after.ratingScore !== score) {
      await change.after.ref.update({ ratingScore: score });
      return;
    }

    if (!before) return; // brand-new provider has no listings
    if (!WATCHED.some((k) => JSON.stringify(before[k]) !== JSON.stringify(after[k]))) {
      return;
    }
    const listings = await db
      .collection("listings")
      .where("providerId", "==", providerId)
      .get();
    for (const doc of listings.docs) await reconcileListing(db, doc.id);
  },
);
