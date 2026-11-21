import { FUNCTIONS_REGION } from "../../shared/moderation.js";

export const REGION = FUNCTIONS_REGION;
/**
 * Cloud Scheduler does not support `africa-south1`, so scheduled functions
 * run in this region instead (the job only touches Storage and Firestore).
 */
export const SCHEDULER_REGION = "europe-west1";
export const AUTO_HIDE_THRESHOLD = 3;
export const ORPHAN_MEDIA_AGE_HOURS = 24;

/**
 * Fallback for `config/limits.maxListingsPerProvider` (Firestore is the
 * single source; this is only used when the document is missing).
 * Keep in sync with `Limits.maxListingsPerProvider` in the app and with the
 * fallback in firestore.rules.
 */
export const DEFAULT_MAX_LISTINGS_PER_PROVIDER = 10;

/** Reports a user may file per rolling 24 hours (`reportQuota/{uid}`). */
export const REPORTS_PER_DAY = 10;
export const REPORT_WINDOW_MS = 24 * 60 * 60 * 1000;

/** Draft listings untouched for this long are deleted by `cleanupDraftListings`. */
export const DRAFT_MAX_AGE_DAYS = 30;
