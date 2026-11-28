import { Timestamp, type Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";
import { DRAFT_MAX_AGE_DAYS } from "../config.js";

const PAGE = 200;

/**
 * Deletes draft listings not updated for `DRAFT_MAX_AGE_DAYS` (30). Only
 * `status == "draft"` is ever touched. Each deletion runs `onListingWritten`,
 * which removes the listing's Storage photos; drafts never held a slot, so
 * provider counters are unaffected. Idempotent and safe to re-run.
 */
export async function cleanupDraftListings(
  db: Firestore,
  now: number = Date.now(),
  maxAgeDays: number = DRAFT_MAX_AGE_DAYS,
): Promise<number> {
  const cutoff = Timestamp.fromMillis(now - maxAgeDays * 24 * 60 * 60 * 1000);
  let deleted = 0;
  for (;;) {
    const snap = await db
      .collection("listings")
      .where("status", "==", "draft")
      .where("updatedAt", "<", cutoff)
      .limit(PAGE)
      .get();
    if (snap.empty) return deleted;
    const batch = db.batch();
    snap.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    deleted += snap.size;
  }
}
