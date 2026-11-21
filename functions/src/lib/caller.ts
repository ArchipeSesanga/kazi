/**
 * Caller checks for callables, mirroring `signedIn()` / `isModerator()` /
 * `isAdmin()` in firestore.rules. Every callable calls one of these before
 * doing any work.
 *
 * - "Signed in": a verified phone number (the account identity) or a staff
 *   claim. An email/password account with neither is treated like a guest.
 * - `moderator`: moderation actions only.
 * - `admin`: moderation plus roles, categories and the audit log.
 */
export interface CallerToken {
  phone_number?: unknown;
  admin?: unknown;
  moderator?: unknown;
  [claim: string]: unknown;
}

type Token = CallerToken | undefined | null;

export function isAdminCaller(token: Token): boolean {
  return !!token && token.admin === true;
}

export function isModeratorCaller(token: Token): boolean {
  return !!token && (token.moderator === true || token.admin === true);
}

/** Admin or moderator (the two staff claims). */
export function isStaffCaller(token: Token): boolean {
  return isModeratorCaller(token);
}

export function isVerifiedCaller(token: Token): boolean {
  if (!token) return false;
  const hasPhone = typeof token.phone_number === 'string' && token.phone_number.length > 0;
  return hasPhone || isStaffCaller(token);
}

/** Actions moderators may perform (and admins, who include moderators). */
export const MODERATION_ACTIONS = [
  'hideListing',
  'restoreListing',
  'suspendProvider',
  'dismissReport',
  'setProviderStatus',
  'resolveReport',
  'getVerificationFiles',
  'decideVerification',
] as const;

/** Actions only admins may perform. */
export const ADMIN_ONLY_ACTIONS = ['upsertCategory', 'setRole', 'viewAuditLog'] as const;

export type StaffAction =
  | (typeof MODERATION_ACTIONS)[number]
  | (typeof ADMIN_ONLY_ACTIONS)[number];

export function canPerform(token: Token, action: StaffAction): boolean {
  if ((ADMIN_ONLY_ACTIONS as readonly string[]).includes(action)) return isAdminCaller(token);
  return isModeratorCaller(token);
}
