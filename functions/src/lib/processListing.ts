import type { Firestore } from "firebase-admin/firestore";
import { removedPhotoPaths } from "./listingDerived.js";
import { releaseSlotOnDelete, syncListingSlot } from "./listingSlots.js";
import { deleteListingMedia, reconcileListing } from "./reconcile.js";

type Doc = Record<string, any> | undefined; // eslint-disable-line @typescript-eslint/no-explicit-any

export interface ProcessResult {
  /** True when this invocation wrote to Firestore (which re-triggers once). */
  wrote: boolean;
}

/**
 * Body of `onListingWritten`, separated from the trigger so it can be tested
 * against the emulator. Every write is conditional on a computed value having
 * changed, so the invocation caused by our own write finds nothing to do.
 */
export async function processListingWrite(
  db: Firestore,
  listingId: string,
  before: Doc,
  after: Doc,
): Promise<ProcessResult> {
  if (!after) {
    if (before) {
      await releaseSlotOnDelete(db, before as { providerId: string });
      await deleteListingMedia(
        before.providerId,
        (before.photos ?? []).map((p: { path?: string }) => p.path),
      );
    }
    return { wrote: false };
  }

  if (before) {
    await deleteListingMedia(after.providerId, removedPhotoPaths(before.photos, after.photos));
  }
  const slotWrote = await syncListingSlot(db, listingId);
  const derivedWrote = await reconcileListing(db, listingId);
  return { wrote: slotWrote || derivedWrote };
}
