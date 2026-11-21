import type { Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";
import { AUTO_HIDE_THRESHOLD } from "../config.js";
import { writeAdminLog } from "./adminLog.js";

import { MODERATION_REASON } from "../../../shared/moderation.js";

export const AUTO_REPORTS_REASON = MODERATION_REASON.autoReports;

export interface AutoHideResult {
  openReports: number;
  hidden: number;
}

/**
 * TDD §6.1 `onReportCreated`: when a target has at least
 * `AUTO_HIDE_THRESHOLD` open reports (one per distinct reporter, guaranteed by
 * the deterministic report id), hide it:
 *  - listing: `moderation = hidden`, reason `auto_reports`;
 *  - provider: every one of its listings is hidden the same way; the provider
 *    stays approved until a moderator decides.
 * Idempotent: a listing that is already hidden (for any reason) is left
 * untouched, and nothing is logged when nothing changed.
 */
export async function applyAutoHide(
  db: Firestore,
  report: { targetType: string; targetKey: string },
): Promise<AutoHideResult> {
  const { targetType, targetKey } = report;
  const open = await db
    .collection("reports")
    .where("targetType", "==", targetType)
    .where("targetKey", "==", targetKey)
    .where("status", "==", "open")
    .count()
    .get();
  const openReports = open.data().count;
  if (openReports < AUTO_HIDE_THRESHOLD) return { openReports, hidden: 0 };

  let refs: FirebaseFirestore.DocumentReference[] = [];
  if (targetType === "listing") {
    refs = [db.collection("listings").doc(targetKey)];
  } else if (targetType === "provider") {
    const listings = await db.collection("listings").where("providerId", "==", targetKey).get();
    refs = listings.docs.map((d) => d.ref);
  } else {
    return { openReports, hidden: 0 };
  }

  let hidden = 0;
  for (const ref of refs) {
    const changed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists || snap.data()?.moderation === "hidden") return false;
      tx.update(ref, { moderation: "hidden", moderationReason: AUTO_REPORTS_REASON });
      return true;
    });
    if (changed) hidden++;
  }

  if (hidden > 0) {
    await writeAdminLog(db, {
      actorUid: "system",
      action: "auto_hide",
      targetType,
      targetId: targetKey,
      note: `open_reports=${openReports} listings_hidden=${hidden}`,
    });
  }
  return { openReports, hidden };
}
