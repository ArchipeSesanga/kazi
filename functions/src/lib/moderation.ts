import { FieldValue, Timestamp, type Firestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import "./firebaseAdmin.js";
import { writeAdminLog } from "./adminLog.js";

import { MODERATION_ERRORS, MODERATION_REASON } from "../../../shared/moderation.js";

/** Hidden reasons the slot logic owns; moderators never override them. */
const OVER_LIMIT = MODERATION_REASON.overLimit;
export const ADMIN_HIDE_REASON = MODERATION_REASON.admin;

type Resolution = "dismissed" | "actioned";

/**
 * Marks every open report on a target as resolved (TDD §6.3) with
 * `resolution = { action, note, by, at }`. Returns how many were updated.
 */
export async function resolveOpenReports(
  db: Firestore,
  target: { type: string; key: string },
  status: Resolution,
  action: string,
  actorUid: string,
  note?: string,
): Promise<number> {
  const open = await db
    .collection("reports")
    .where("targetType", "==", target.type)
    .where("targetKey", "==", target.key)
    .where("status", "==", "open")
    .get();
  if (open.empty) return 0;
  const batch = db.batch();
  const resolution = { action, note: note ?? "", by: actorUid, at: Timestamp.now() };
  open.docs.forEach((d) => batch.update(d.ref, { status, resolution }));
  await batch.commit();
  return open.size;
}

const need = async (ref: FirebaseFirestore.DocumentReference, what: string) => {
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", `${what}-not-found`); // see MODERATION_ERRORS
  return snap.data() as Record<string, unknown>;
};

/** Hides a listing (`moderation = hidden`, reason `admin`). */
export async function hideListing(
  db: Firestore,
  actorUid: string,
  input: { listingId: string; note?: string },
): Promise<{ resolvedReports: number }> {
  const ref = db.collection("listings").doc(input.listingId);
  const before = await need(ref, "listing");
  await ref.update({ moderation: "hidden", moderationReason: ADMIN_HIDE_REASON });
  const resolvedReports = await resolveOpenReports(
    db, { type: "listing", key: input.listingId }, "actioned", "hide_target", actorUid, input.note,
  );
  await writeAdminLog(db, {
    actorUid, action: "hide_listing", targetType: "listing", targetId: input.listingId,
    before: { moderation: before.moderation ?? "ok", moderationReason: before.moderationReason ?? null },
    after: { moderation: "hidden", moderationReason: ADMIN_HIDE_REASON },
    note: input.note,
  });
  return { resolvedReports };
}

/**
 * Restores a listing hidden by reports or by a moderator. A listing hidden
 * for `over_limit` belongs to the slot logic and is refused. Open reports on
 * it are dismissed so they do not re-hide it.
 */
export async function restoreListing(
  db: Firestore,
  actorUid: string,
  input: { listingId: string; note?: string },
): Promise<{ resolvedReports: number }> {
  const ref = db.collection("listings").doc(input.listingId);
  const before = await need(ref, "listing");
  if (before.moderationReason === OVER_LIMIT) {
    throw new HttpsError("failed-precondition", MODERATION_ERRORS.overLimit);
  }
  await ref.update({ moderation: "ok", moderationReason: FieldValue.delete() });
  const resolvedReports = await resolveOpenReports(
    db, { type: "listing", key: input.listingId }, "dismissed", "unhide_target", actorUid, input.note,
  );
  await writeAdminLog(db, {
    actorUid, action: "restore_listing", targetType: "listing", targetId: input.listingId,
    before: { moderation: before.moderation ?? "ok", moderationReason: before.moderationReason ?? null },
    after: { moderation: "ok", moderationReason: null },
    note: input.note,
  });
  return { resolvedReports };
}

/**
 * Suspends a provider. `onProviderWritten` then hides all their listings
 * (visibility depends on the provider status).
 */
export async function suspendProvider(
  db: Firestore,
  actorUid: string,
  input: { providerId: string; reason: string },
): Promise<{ resolvedReports: number }> {
  const ref = db.collection("providers").doc(input.providerId);
  const before = await need(ref, "provider");
  await ref.update({ status: "suspended" });
  const resolvedReports = await resolveOpenReports(
    db, { type: "provider", key: input.providerId }, "actioned", "suspend_provider", actorUid, input.reason,
  );
  await writeAdminLog(db, {
    actorUid, action: "suspend_provider", targetType: "provider", targetId: input.providerId,
    before: { status: before.status ?? null }, after: { status: "suspended" }, note: input.reason,
  });
  return { resolvedReports };
}

/** Dismisses the report and every other open report on the same target. */
export async function dismissReport(
  db: Firestore,
  actorUid: string,
  input: { reportId: string; note?: string },
): Promise<{ resolvedReports: number }> {
  const report = await need(db.collection("reports").doc(input.reportId), "report");
  const resolvedReports = await resolveOpenReports(
    db,
    { type: String(report.targetType), key: String(report.targetKey) },
    "dismissed", "dismiss", actorUid, input.note,
  );
  await writeAdminLog(db, {
    actorUid, action: "dismiss_report", targetType: String(report.targetType),
    targetId: String(report.targetKey), note: input.note,
  });
  return { resolvedReports };
}
