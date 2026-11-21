import { FieldValue, type Firestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import "./firebaseAdmin.js";
import {
  changedFields,
  computeListingDerived,
  isOwnedListingMedia,
  shouldSetPublishedAt,
  type CategoryInput,
  type ListingInput,
  type ProviderInput,
} from "./listingDerived.js";

async function communeNameLookup(db: Firestore): Promise<(id: string) => string> {
  const names = new Map<string, string>();
  const snap = await db.collection("config").doc("locations").get();
  const cities = (snap.data()?.cities ?? []) as Array<{
    communes?: Array<{ id: string; name: string }>;
  }>;
  for (const city of cities) {
    for (const c of city.communes ?? []) names.set(c.id, c.name);
  }
  return (id) => names.get(id) ?? id.replace(/_/g, " ");
}

/**
 * Recomputes the server-owned fields of one listing and writes them only if
 * they differ from what is stored (so the resulting trigger invocation is a
 * no-op and the loop ends). Returns true when a write happened.
 */
export async function reconcileListing(
  db: Firestore,
  listingId: string,
): Promise<boolean> {
  const ref = db.collection("listings").doc(listingId);
  const snap = await ref.get();
  if (!snap.exists) return false;
  const listing = snap.data() as ListingInput & { providerId: string; categoryId: string };

  const [providerSnap, categorySnap, communeName] = await Promise.all([
    db.collection("providers").doc(listing.providerId).get(),
    db.collection("categories").doc(listing.categoryId).get(),
    communeNameLookup(db),
  ]);

  const derived = computeListingDerived(
    listing,
    providerSnap.data() as ProviderInput | undefined,
    categorySnap.data() as CategoryInput | undefined,
    communeName,
  );

  const diff = changedFields(snap.data() as Record<string, unknown>, derived);
  const update: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(diff)) {
    update[k] = v === null ? FieldValue.delete() : v;
  }
  if (shouldSetPublishedAt(listing, derived)) {
    update.publishedAt = FieldValue.serverTimestamp();
  }
  if (Object.keys(update).length === 0) return false;
  await ref.update(update);
  return true;
}

/** Best-effort deletion of the listing's own Storage objects. */
export async function deleteListingMedia(
  providerId: string,
  paths: string[],
): Promise<void> {
  const bucket = getStorage().bucket();
  await Promise.all(
    paths
      .filter((p) => isOwnedListingMedia(p, providerId))
      .map((p) =>
        bucket
          .file(p)
          .delete({ ignoreNotFound: true })
          .catch((e) => logger.warn("media delete failed", { path: p, message: String(e) })),
      ),
  );
}
