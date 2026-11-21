/**
 * Single source of truth for the moderation contract, shared by the Cloud
 * Functions (`functions/src`) and the admin web app (`admin/src`).
 *
 * Plain TypeScript with no imports, so both projects can compile it. Names,
 * enums and limits are defined here once; the Flutter app mirrors the same
 * enum values (`lib/core/models/enums.dart`).
 */

/** Region of the callables (Firestore and Functions live in the same region). */
export const FUNCTIONS_REGION = "africa-south1";

// ── Reports ────────────────────────────────────────────────────────────────
export const REPORT_TARGETS = ["listing", "provider"] as const;
export type ReportTarget = (typeof REPORT_TARGETS)[number];

export const REPORT_REASONS = ["scam", "inappropriate", "fake", "wrong_category", "other"] as const;
export type ReportReason = (typeof REPORT_REASONS)[number];

export const REPORT_STATUSES = ["open", "dismissed", "actioned"] as const;
export type ReportStatus = (typeof REPORT_STATUSES)[number];

export const REPORT_DETAILS_MAX = 500;

/** A report as stored in `reports/{reporterUid}_{targetType}_{targetKey}`. */
export interface ReportDoc {
  reporterUid: string;
  targetType: ReportTarget;
  targetKey: string;
  reason: ReportReason;
  details: string;
  status: ReportStatus;
  createdAt?: unknown; // Firestore Timestamp (server) / Timestamp (client)
  resolution?: { action: string; note: string; by: string; at: unknown };
}

// ── Moderation state ───────────────────────────────────────────────────────
export type ListingModeration = "ok" | "hidden";
export type ProviderStatus = "pending" | "approved" | "rejected" | "suspended";

/** Values of `listings.moderationReason` set by the system and by staff. */
export const MODERATION_REASON = {
  /** Hidden by a moderator. */
  admin: "admin",
  /** Hidden automatically after enough open reports. */
  autoReports: "auto_reports",
  /** Owned by the listing-slot logic; staff must not override it. */
  overLimit: "over_limit",
  /** Owned by the content checks in `onListingWritten`. */
  autoContent: "auto_content",
} as const;

// ── Moderator callables ────────────────────────────────────────────────────
export const MODERATOR_CALLABLES = {
  hideListing: "moderator_hideListing",
  restoreListing: "moderator_restoreListing",
  suspendProvider: "moderator_suspendProvider",
  dismissReport: "moderator_dismissReport",
} as const;

export const NOTE_MAX = 500;
export const SUSPEND_REASON_MIN = 3;
export const SUSPEND_REASON_MAX = 500;

export interface HideListingInput { listingId: string; note?: string }
export interface RestoreListingInput { listingId: string; note?: string }
export interface SuspendProviderInput { providerId: string; reason: string }
export interface DismissReportInput { reportId: string; note?: string }
export interface ModerationResult { resolvedReports: number }

/** Machine-readable `HttpsError.message` values the callables use. */
export const MODERATION_ERRORS = {
  listingNotFound: "listing-not-found",
  providerNotFound: "provider-not-found",
  reportNotFound: "report-not-found",
  overLimit: "over-limit",
  invalidInput: "invalid-input",
} as const;

// ── Staff claims ───────────────────────────────────────────────────────────
export type StaffRole = "admin" | "moderator";

/** The role granted by an ID token's custom claims, or null for non-staff. */
export function staffRoleFromClaims(claims: Record<string, unknown> | undefined | null): StaffRole | null {
  if (!claims) return null;
  if (claims.admin === true) return "admin";
  if (claims.moderator === true) return "moderator";
  return null;
}
