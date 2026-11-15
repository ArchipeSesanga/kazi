import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { reconcileListing } from "../lib/reconcile.js";

const WATCHED = ["displayName", "photoUrl", "verified", "ratingAvg", "ratingCount", "status"];

/**
 * TDD §6.1 (subset):
 *  - v1 auto-approval: a provider that is `pending` on create (or resubmitted
 *    from `rejected`) becomes `approved` when
 *    `config/moderation.autoApproveProviders == true`;
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
        await change.after.ref.update({
          status: "approved",
          approvedAt: FieldValue.serverTimestamp(),
        });
        return; // the resulting write re-enters here and propagates
      }
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
