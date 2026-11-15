import { FieldValue, type Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";
import { getMaxListingsPerProvider } from "./limits.js";
import { decideSlot, OVER_LIMIT_REASON, wantsSlot } from "./slots.js";

/**
 * Brings `countsTowardLimit`, `providers.listingCount` and the `over_limit`
 * hide of one listing in line with its current status. A listing that would
 * exceed the limit is NOT deleted: it is hidden (`moderation = hidden`,
 * `moderationReason = over_limit`) and keeps its photos. Any later write of
 * the listing (edit, resume) retries once a slot is free.
 * Returns true when something was written.
 */
export async function syncListingSlot(db: Firestore, listingId: string): Promise<boolean> {
  const listingRef = db.collection("listings").doc(listingId);
  const max = await getMaxListingsPerProvider(db);
  return db.runTransaction(async (tx) => {
    const lSnap = await tx.get(listingRef);
    if (!lSnap.exists) return false;
    const l = lSnap.data()!;
    const providerRef = db.collection("providers").doc(l.providerId);
    const pSnap = await tx.get(providerRef);
    if (!pSnap.exists) return false; // e.g. account deletion in progress

    const count = (pSnap.data()?.listingCount as number | undefined) ?? 0;
    const held = l.countsTowardLimit === true;
    const d = decideSlot({
      held,
      wants: wantsSlot(l.status),
      markedOverLimit: l.moderation === "hidden" && l.moderationReason === OVER_LIMIT_REASON,
      count,
      max,
    });

    const update: Record<string, unknown> = {};
    if (held !== d.countsTowardLimit) update.countsTowardLimit = d.countsTowardLimit;
    if (d.mark === "over_limit") {
      update.moderation = "hidden";
      update.moderationReason = OVER_LIMIT_REASON;
    } else if (d.mark === "clear") {
      update.moderation = "ok";
      update.moderationReason = FieldValue.delete();
    }
    if (d.countDelta !== 0) {
      tx.update(providerRef, { listingCount: Math.max(0, count + d.countDelta) });
    }
    if (Object.keys(update).length === 0) return d.countDelta !== 0;
    tx.update(listingRef, update);
    return true;
  });
}

/** A deleted listing that held a slot frees it. */
export async function releaseSlotOnDelete(
  db: Firestore,
  before: { providerId: string; countsTowardLimit?: boolean },
): Promise<void> {
  if (before.countsTowardLimit !== true) return;
  const ref = db.collection("providers").doc(before.providerId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    const count = (snap.data()?.listingCount as number | undefined) ?? 0;
    tx.update(ref, { listingCount: Math.max(0, count - 1) });
  });
}
