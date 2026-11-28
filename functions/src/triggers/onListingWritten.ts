import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import "../lib/firebaseAdmin.js";
import { REGION } from "../config.js";
import { processListingWrite } from "../lib/processListing.js";

/**
 * TDD §6.1. On every listing write:
 *  - slots: only active + paused listings count toward
 *    `config/limits.maxListingsPerProvider`; a listing over the limit is
 *    hidden (`moderation = hidden`, `moderationReason = over_limit`), never
 *    deleted, and keeps its photos;
 *  - fill denormalised fields, `visible`, `searchKeywords`, `publishedAt`,
 *    content moderation (see `reconcileListing`);
 *  - removed photos / deleted listing: delete Storage objects.
 * Writes happen only when a computed value changed, so the invocation caused
 * by the function's own write is a no-op (logged as `wrote: false`).
 */
export const onListingWritten = onDocumentWritten(
  { document: "listings/{listingId}", region: REGION },
  async (event) => {
    const change = event.data;
    if (!change) return;
    const { listingId } = event.params;
    const before = change.before.exists ? change.before.data() : undefined;
    const after = change.after.exists ? change.after.data() : undefined;
    const kind = !before ? "create" : !after ? "delete" : "update";
    const { wrote } = await processListingWrite(getFirestore(), listingId, before, after);
    logger.info("onListingWritten", { listingId, kind, wrote });
  },
);
