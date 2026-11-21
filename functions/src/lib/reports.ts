import { FieldValue, type Firestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";
import "./firebaseAdmin.js";
import { REPORTS_PER_DAY, REPORT_WINDOW_MS } from "../config.js";

import {
  REPORT_DETAILS_MAX,
  REPORT_REASONS,
  REPORT_TARGETS,
  type ReportReason as ReportReasonValue,
  type ReportTarget,
} from "../../../shared/moderation.js";

export { REPORT_REASONS, REPORT_TARGETS };
export type { ReportReasonValue, ReportTarget };

export interface ReportInput {
  targetType: ReportTarget;
  targetKey: string;
  reason: ReportReasonValue;
  details?: string;
}

export type SubmitReportResult = { status: "created" | "already_reported"; reportId: string };

export const reportId = (uid: string, type: string, key: string) => `${uid}_${type}_${key}`;

/**
 * Files a report. The report document is created here (never by the client)
 * so the per-user limit cannot be bypassed:
 *  - one report per user and target (deterministic id; a repeat is a no-op
 *    that returns `already_reported` and does not use quota);
 *  - at most `REPORTS_PER_DAY` new reports per rolling 24 hours, counted in
 *    `reportQuota/{uid}` (server-only);
 *  - the target must exist and must not belong to the reporter.
 * Everything happens in one transaction, so a retry cannot double-count.
 */
export async function submitReport(
  db: Firestore,
  uid: string,
  input: ReportInput,
  now: number = Date.now(),
): Promise<SubmitReportResult> {
  const details = (input.details ?? "").trim();
  if (details.length > REPORT_DETAILS_MAX) throw new HttpsError("invalid-argument", "details-too-long");

  const id = reportId(uid, input.targetType, input.targetKey);
  const reportRef = db.collection("reports").doc(id);
  const quotaRef = db.collection("reportQuota").doc(uid);
  const targetRef = db
    .collection(input.targetType === "listing" ? "listings" : "providers")
    .doc(input.targetKey);

  return db.runTransaction(async (tx) => {
    const [existing, quota, target] = await Promise.all([
      tx.get(reportRef),
      tx.get(quotaRef),
      tx.get(targetRef),
    ]);
    if (existing.exists) return { status: "already_reported", reportId: id };
    if (!target.exists) throw new HttpsError("not-found", "target-not-found");
    const ownerId = input.targetType === "listing" ? target.data()?.providerId : input.targetKey;
    if (ownerId === uid) throw new HttpsError("failed-precondition", "own-target");

    const q = quota.data() as { windowStart?: number; count?: number } | undefined;
    const inWindow = q?.windowStart !== undefined && now - q.windowStart < REPORT_WINDOW_MS;
    const count = inWindow ? (q?.count ?? 0) : 0;
    if (count >= REPORTS_PER_DAY) throw new HttpsError("resource-exhausted", "rate-limited");

    tx.set(reportRef, {
      reporterUid: uid,
      targetType: input.targetType,
      targetKey: input.targetKey,
      reason: input.reason,
      details,
      status: "open",
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(quotaRef, { windowStart: inWindow ? q!.windowStart : now, count: count + 1 });
    return { status: "created", reportId: id };
  });
}
