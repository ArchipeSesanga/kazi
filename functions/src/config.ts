export const REGION = "africa-south1";
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
