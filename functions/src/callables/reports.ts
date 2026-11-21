import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall, type CallableRequest } from "firebase-functions/v2/https";
import { z } from "zod";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { canPerform, isVerifiedCaller, type CallerToken, type StaffAction } from "../lib/caller.js";
import { dismissReport, hideListing, restoreListing, suspendProvider } from "../lib/moderation.js";
import { REPORT_REASONS, REPORT_TARGETS, submitReport } from "../lib/reports.js";

function parse<T extends z.ZodTypeAny>(schema: T, data: unknown): z.infer<T> {
  const r = schema.safeParse(data);
  if (!r.success) throw new HttpsError("invalid-argument", "invalid-input");
  return r.data;
}

const reportSchema = z.object({
  targetType: z.enum(REPORT_TARGETS),
  targetKey: z.string().min(1).max(200),
  reason: z.enum(REPORT_REASONS),
  details: z.string().max(500).optional(),
});

/** Report a listing or a provider. Verified users only; rate-limited per user. */
export const submitReportCallable = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
  if (!isVerifiedCaller(request.auth?.token as unknown as CallerToken)) {
    throw new HttpsError("permission-denied", "A verified phone number is required.");
  }
  const input = parse(reportSchema, request.data);
  const result = await submitReport(getFirestore(), uid, input);
  logger.info("submitReport", { targetType: input.targetType, status: result.status });
  return result;
});

/** Every moderator callable: staff claim, validated input, audit log. */
function moderatorCall<T extends z.ZodTypeAny, R>(
  action: StaffAction,
  schema: T,
  run: (uid: string, input: z.infer<T>) => Promise<R>,
) {
  return onCall({ region: REGION }, async (request: CallableRequest) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
    if (!canPerform(request.auth?.token as unknown as CallerToken, action)) {
      throw new HttpsError("permission-denied", "Moderator access required.");
    }
    const result = await run(uid, parse(schema, request.data));
    logger.info(`moderator:${action}`, { ok: true });
    return result;
  });
}

const note = z.string().max(500).optional();

export const moderator_hideListing = moderatorCall(
  "hideListing",
  z.object({ listingId: z.string().min(1).max(200), note }),
  (uid, i) => hideListing(getFirestore(), uid, i),
);
export const moderator_restoreListing = moderatorCall(
  "restoreListing",
  z.object({ listingId: z.string().min(1).max(200), note }),
  (uid, i) => restoreListing(getFirestore(), uid, i),
);
export const moderator_suspendProvider = moderatorCall(
  "suspendProvider",
  z.object({ providerId: z.string().min(1).max(200), reason: z.string().min(3).max(500) }),
  (uid, i) => suspendProvider(getFirestore(), uid, i),
);
export const moderator_dismissReport = moderatorCall(
  "dismissReport",
  z.object({ reportId: z.string().min(1).max(450), note }),
  (uid, i) => dismissReport(getFirestore(), uid, i),
);
