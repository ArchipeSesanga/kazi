import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { isVerifiedCaller } from "../lib/caller.js";
import { deleteAccountData } from "../lib/deleteAccount.js";

/** How recent the caller's sign-in must be (a fresh OTP re-confirmation). */
export const RECENT_LOGIN_SECONDS = 5 * 60;

/** Throws unless the caller is a verified user who just re-confirmed with an OTP. */
export function assertFreshLogin(
  token: Record<string, unknown> | undefined,
  nowSeconds: number = Math.floor(Date.now() / 1000),
): void {
  if (!isVerifiedCaller(token)) {
    throw new HttpsError("permission-denied", "A verified phone number is required.");
  }
  const authTime = typeof token?.auth_time === "number" ? token.auth_time : 0;
  if (nowSeconds - authTime > RECENT_LOGIN_SECONDS) {
    throw new HttpsError("failed-precondition", "recent-login-required");
  }
}

/** TDD §6.5. The client signs out locally after this resolves. */
export const deleteAccount = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
  assertFreshLogin(request.auth?.token as unknown as Record<string, unknown>);

  const bucket = getStorage().bucket();
  try {
    const report = await deleteAccountData(getFirestore(), uid, {
      deleteStoragePrefix: async (prefix) => {
        await bucket.deleteFiles({ prefix, force: true });
      },
      deleteAuthUser: async (id) => {
        try {
          await getAuth().deleteUser(id);
        } catch (e) {
          if ((e as { code?: string }).code !== "auth/user-not-found") throw e;
        }
      },
    });
    logger.info("deleteAccount", report); // counts only, no personal data
    return { ok: true };
  } catch (e) {
    logger.error("deleteAccount failed", { message: (e as Error).message });
    throw new HttpsError("internal", "Deletion did not finish. Try again.");
  }
});
