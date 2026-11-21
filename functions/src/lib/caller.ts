/**
 * "Signed in" for callables, mirroring `signedIn()` in firestore.rules:
 * a verified phone number (the account identity) or the admin claim.
 * An email/password account with neither is treated like a guest.
 * Every callable must call this before doing any work.
 */
export interface CallerToken {
  phone_number?: unknown;
  admin?: unknown;
  [claim: string]: unknown;
}

export function isVerifiedCaller(token: CallerToken | undefined | null): boolean {
  if (!token) return false;
  return typeof token.phone_number === 'string' && token.phone_number.length > 0
    ? true
    : token.admin === true;
}

export function isAdminCaller(token: CallerToken | undefined | null): boolean {
  return !!token && token.admin === true;
}
