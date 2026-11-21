import { staffRoleFromClaims, type StaffRole } from "@shared/moderation";

export type { StaffRole };

/** Only `admin` and `moderator` may use the panel; anyone else is signed out. */
export const roleOf = (claims: Record<string, unknown> | null | undefined): StaffRole | null =>
  staffRoleFromClaims(claims);
