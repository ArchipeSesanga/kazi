import type { Firestore } from "firebase-admin/firestore";
import "./firebaseAdmin.js";
import { writeAdminLog } from "./adminLog.js";
import { isStaffCaller } from "./caller.js";
import { deleteAccountData, storagePrefixesFor, type DeleteAccountDeps, type DeleteAccountReport } from "./deleteAccount.js";
import { titleHasPhoneNumber } from "./visibility.js";

/**
 * Operator tooling: delete an account on request (privacy requests received by
 * email or WhatsApp, see docs/11-PROD-RUNBOOK.md §G). Staff only, dry-run by
 * default, every real run writes an `adminLogs` entry. The deletion itself is
 * the same `deleteAccountData` the app's `deleteAccount` callable uses.
 */

export class OperatorError extends Error {
  constructor(
    readonly code: "operator-not-staff" | "operator-not-found" | "invalid-phone" | "invalid-reason" | "account-not-found" | "ambiguous-account",
    message: string,
  ) {
    super(message);
  }
}

/** Auth lookups the tool needs (the real one wraps `firebase-admin/auth`). */
export interface AccountLookup {
  userByPhone(e164: string): Promise<{ uid: string } | null>;
  userByEmail(email: string): Promise<{ uid: string; claims: Record<string, unknown> } | null>;
}

const E164 = /^\+[1-9][0-9]{7,14}$/;

/** `+243 81 234 5678` -> `+243812345678`; null when it is not E.164. */
export function normalisePhone(input: string): string | null {
  const compact = input.replace(/[\s.\-()]/g, "");
  return E164.test(compact) ? compact : null;
}

/** The reason goes into the audit log: no phone numbers or emails in it. */
export function validateReason(reason: string): string {
  const r = reason.trim();
  if (r.length < 3 || r.length > 200) {
    throw new OperatorError("invalid-reason", "The reason must be 3 to 200 characters.");
  }
  if (titleHasPhoneNumber(r) || r.includes("@")) {
    throw new OperatorError("invalid-reason", "Do not put phone numbers or emails in the reason: use a ticket reference.");
  }
  return r;
}

/** Only an existing staff account (admin or moderator claim) may run the tool. */
export async function authoriseOperator(lookup: AccountLookup, email: string): Promise<{ uid: string }> {
  const op = await lookup.userByEmail(email.trim());
  if (!op) throw new OperatorError("operator-not-found", "No account with that operator email.");
  if (!isStaffCaller(op.claims)) {
    throw new OperatorError("operator-not-staff", "The operator account has no admin or moderator claim.");
  }
  return { uid: op.uid };
}

/**
 * Finds the account by phone number: the Auth user first, then a `users`
 * document with that phone (covers an earlier partial deletion).
 */
export async function findAccount(
  db: Firestore,
  lookup: AccountLookup,
  e164: string,
): Promise<{ uid: string; via: "auth" | "profile" }> {
  const auth = await lookup.userByPhone(e164);
  if (auth) return { uid: auth.uid, via: "auth" };
  const docs = await db.collection("users").where("phone", "==", e164).limit(2).get();
  if (docs.size > 1) throw new OperatorError("ambiguous-account", "More than one profile has this phone number.");
  if (docs.size === 1) return { uid: docs.docs[0].id, via: "profile" };
  throw new OperatorError("account-not-found", "No account found for this phone number.");
}

export interface DeletionPlan {
  userProfile: boolean;
  providerProfile: boolean;
  listings: number;
  reviewsToAnonymise: number;
  reportsToAnonymise: number;
  contactsAsClient: number;
  contactsAsProvider: number;
  favouritesOfProvider: number;
  verificationRequest: boolean;
  reportQuota: boolean;
  storageFiles: Record<string, number>;
}

/** What `deleteAccountData` would touch. Read-only. */
export async function planDeletion(
  db: Firestore,
  uid: string,
  countStorage?: (prefix: string) => Promise<number>,
): Promise<DeletionPlan> {
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  const exists = async (path: string) => (await db.doc(path).get()).exists;
  const storageFiles: Record<string, number> = {};
  for (const prefix of storagePrefixesFor(uid)) {
    storageFiles[prefix] = countStorage ? await countStorage(prefix) : -1; // -1 = not counted
  }
  return {
    userProfile: await exists(`users/${uid}`),
    providerProfile: await exists(`providers/${uid}`),
    listings: await count(db.collection("listings").where("providerId", "==", uid)),
    reviewsToAnonymise: await count(db.collectionGroup("reviews").where("authorUid", "==", uid)),
    reportsToAnonymise: await count(db.collection("reports").where("reporterUid", "==", uid)),
    contactsAsClient: await count(db.collection("contacts").where("clientUid", "==", uid)),
    contactsAsProvider: await count(db.collection("contacts").where("providerId", "==", uid)),
    favouritesOfProvider: await count(db.collectionGroup("favorites").where("providerId", "==", uid)),
    verificationRequest: await exists(`verificationRequests/${uid}`),
    reportQuota: await exists(`reportQuota/${uid}`),
    storageFiles,
  };
}

export interface OperatorDeleteOptions {
  phone: string;
  operatorEmail: string;
  reason: string;
  /** False (the default in the CLI) only prints the plan. */
  execute: boolean;
  countStorage?: (prefix: string) => Promise<number>;
}

export interface OperatorDeleteResult {
  uid: string;
  via: "auth" | "profile";
  dryRun: boolean;
  plan: DeletionPlan;
  report?: DeleteAccountReport;
}

export async function operatorDeleteAccount(
  db: Firestore,
  lookup: AccountLookup,
  deps: DeleteAccountDeps,
  opts: OperatorDeleteOptions,
): Promise<OperatorDeleteResult> {
  const e164 = normalisePhone(opts.phone);
  if (!e164) throw new OperatorError("invalid-phone", "The phone number must be E.164, for example +243812345678.");
  const reason = validateReason(opts.reason);
  const operator = await authoriseOperator(lookup, opts.operatorEmail);
  const { uid, via } = await findAccount(db, lookup, e164);
  const plan = await planDeletion(db, uid, opts.countStorage);

  if (!opts.execute) return { uid, via, dryRun: true, plan };

  // The log never contains the phone number: the uid and the reason reference.
  const log = { actorUid: operator.uid, targetType: "user", targetId: uid, note: reason };
  try {
    const report = await deleteAccountData(db, uid, deps);
    await writeAdminLog(db, { ...log, action: "operator_delete_account", after: { ...report } });
    return { uid, via, dryRun: false, plan, report };
  } catch (e) {
    await writeAdminLog(db, { ...log, action: "operator_delete_account_failed", note: `${reason} | ${(e as Error).message}`.slice(0, 500) });
    throw e;
  }
}
