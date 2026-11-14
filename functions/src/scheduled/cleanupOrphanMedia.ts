import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { initializeApp } from "firebase-admin/app";
import { REGION, ORPHAN_MEDIA_AGE_HOURS } from "../config.js";

initializeApp();

const db = getFirestore();
const bucket = getStorage().bucket();

/**
 * Deletes orphan media files under media/{uid}/listings/{listingId}/
 * whose listing doc no longer exists or doesn't reference them.
 * Only targets files older than ORPHAN_MEDIA_AGE_HOURS.
 *
 * Runs daily at 03:00 Africa/Kinshasa.
 */
export const cleanupOrphanMedia = onSchedule(
  {
    schedule: "0 3 * * *",
    timeZone: "Africa/Kinshasa",
    region: REGION,
    retryCount: 1,
  },
  async () => {
    const cutoff = new Date(
      Date.now() - ORPHAN_MEDIA_AGE_HOURS * 60 * 60 * 1000
    );

    const [files] = await bucket.getFiles({ prefix: "media/" });

    const listingFiles = files.filter((f) => f.name.includes("/listings/"));

    // Group by listingId → { listingId: { uid, files[] } }
    const byListing = new Map<
      string,
      { uid: string; files: typeof listingFiles }
    >();

    for (const file of listingFiles) {
      // Path: media/{uid}/listings/{listingId}/{filename}
      const parts = file.name.split("/");
      if (parts.length < 5) continue;
      const uid = parts[1];
      const listingId = parts[3];
      const key = `${uid}/${listingId}`;
      if (!byListing.has(key)) {
        byListing.set(key, { uid, files: [] });
      }
      byListing.get(key)!.files.push(file);
    }

    let deletedCount = 0;

    for (const [key, { files: groupFiles }] of byListing) {
      const listingId = key.split("/")[1];
      const listingDoc = await db.doc(`listings/${listingId}`).get();

      const referencedPaths = new Set<string>();
      if (listingDoc.exists) {
        const photos = listingDoc.data()?.photos as
          | Array<{ path?: string }>
          | undefined;
        if (photos) {
          for (const p of photos) {
            if (p.path) referencedPaths.add(p.path);
          }
        }
      }

      for (const file of groupFiles) {
        // Skip files that are referenced by the listing
        if (referencedPaths.has(file.name)) continue;

        // Skip recent files (within age threshold)
        const metadata = file.metadata;
        const created = metadata.timeCreated
          ? new Date(metadata.timeCreated)
          : null;
        if (created && created > cutoff) continue;

        // Orphan: listing doesn't exist, or file isn't referenced, and it's old enough
        try {
          await file.delete();
          deletedCount++;
        } catch (err) {
          console.warn(`Failed to delete orphan: ${file.name}`, err);
        }
      }
    }

    console.log(`cleanupOrphanMedia: deleted ${deletedCount} orphan files`);
  }
);
