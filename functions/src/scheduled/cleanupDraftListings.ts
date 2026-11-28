import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { SCHEDULER_REGION } from "../config.js";
import { cleanupDraftListings as run } from "../lib/cleanupDrafts.js";

/** Nightly 03:30 Africa/Kinshasa: delete drafts untouched for 30 days. */
export const cleanupDraftListings = onSchedule(
  {
    schedule: "30 3 * * *",
    timeZone: "Africa/Kinshasa",
    region: SCHEDULER_REGION,
    retryCount: 1,
  },
  async () => {
    const deleted = await run(getFirestore());
    logger.info("cleanupDraftListings", { deleted });
  },
);
