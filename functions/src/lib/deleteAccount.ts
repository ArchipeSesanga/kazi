import { createHash } from "node:crypto";
import {
  type DocumentReference,
  type Firestore,
  type Query,
} from "firebase-admin/firestore";
import "./firebaseAdmin.js";

/** Marker written in place of the author of a deleted account. */
export const DELETED_AUTHOR_UID = "deleted";
export const DELETED_AUTHOR_NAME = "Utilisateur supprimé";

const PAGE = 200;
/** Upper bound so a handler that leaves a document behind cannot loop forever. */
const MAX_PAGES = 500;

export interface DeleteAccountDeps {
  /** Deletes every Storage object under the prefix; must be a no-op when empty. */
  deleteStoragePrefix: (prefix: string) => Promise<void>;
  /** Deletes the Auth user; must resolve when the user is already gone. */
  deleteAuthUser: (uid: string) => Promise<void>;
}

export interface DeleteAccountReport {
  reviewsAnonymised: number;
  reportsAnonymised: number;
  contactsDeleted: number;
  listingsDeleted: number;
  favoritesOfProviderDeleted: number;
}

/** Storage prefixes owned by an account (TDD §6.5 step 6). */
export const storagePrefixesFor = (uid: string): string[] => [
  `media/${uid}/`,
  `private/verification/${uid}/`,
];

/** Stable id for an anonymised review, so a retry never creates a second copy. */
export function anonymisedReviewId(uid: string, providerId: string): string {
  const h = createHash("sha256").update(`${uid}:${providerId}`).digest("hex");
  return `deleted_${h.slice(0, 20)}`;
}

/** Repeats [handle] on pages of [query] until it matches nothing. */
async function drain(
  query: Query,
  handle: (docs: FirebaseFirestore.QueryDocumentSnapshot[]) => Promise<void>,
): Promise<number> {
  let total = 0;
  for (let page = 0; page < MAX_PAGES; page++) {
    const snap = await query.limit(PAGE).get();
    if (snap.empty) return total;
    await handle(snap.docs);
    total += snap.size;
    if (snap.size < PAGE) {
      // One more pass proves the handler removed every match, and keeps the
      // loop safe if a handler ever leaves a document behind.
      const again = await query.limit(1).get();
      if (again.empty) return total;
    }
  }
  throw new Error("deleteAccount: a query kept returning documents");
}

const deleteRefs = async (db: Firestore, refs: DocumentReference[]) => {
  const batch = db.batch();
  refs.forEach((r) => batch.delete(r));
  await batch.commit();
};

/**
 * Deletes an account and everything it owns (TDD §6.5).
 *
 * Safe to retry after a partial failure: every step is idempotent, the
 * `users/{uid}` document (status `deleting`) is only removed near the end, and
 * the Auth user last. A retry simply repeats the steps that are not finished.
 * Nothing here recreates a document: all writes are deletes or updates of
 * documents found by a query.
 */
export async function deleteAccountData(
  db: Firestore,
  uid: string,
  deps: DeleteAccountDeps,
): Promise<DeleteAccountReport> {
  const report: DeleteAccountReport = {
    reviewsAnonymised: 0,
    reportsAnonymised: 0,
    contactsDeleted: 0,
    listingsDeleted: 0,
    favoritesOfProviderDeleted: 0,
  };
  const userRef = db.collection("users").doc(uid);
  const providerRef = db.collection("providers").doc(uid);

  // 1. Mark the account as being deleted (blocks new provider/review creates
  //    through `userActive()` in the rules). Skipped when already gone.
  if ((await userRef.get()).exists) await userRef.update({ status: "deleting" });

  // 2. Reviews written by the user: anonymise. The review id is the author's
  //    uid, so the document is moved to a neutral id (set + delete in one
  //    batch). Rating, text and timestamps are kept, so provider ratings do
  //    not change.
  report.reviewsAnonymised = await drain(
    db.collectionGroup("reviews").where("authorUid", "==", uid),
    async (docs) => {
      const batch = db.batch();
      for (const d of docs) {
        const providerId = d.ref.parent.parent?.id;
        if (!providerId) continue;
        const rest = { ...d.data() };
        delete rest.authorPhotoUrl;
        batch.set(
          db.collection("providers").doc(providerId).collection("reviews").doc(anonymisedReviewId(uid, providerId)),
          { ...rest, authorUid: DELETED_AUTHOR_UID, authorName: DELETED_AUTHOR_NAME },
        );
        batch.delete(d.ref);
      }
      await batch.commit();
    },
  );

  // 3. Reports filed by the user are kept (safety record) without the reporter.
  report.reportsAnonymised = await drain(
    db.collection("reports").where("reporterUid", "==", uid),
    async (docs) => {
      const batch = db.batch();
      docs.forEach((d) => batch.update(d.ref, { reporterUid: DELETED_AUTHOR_UID }));
      await batch.commit();
    },
  );

  // 4. Contact records: the user's own, and those that hold this account's
  //    phone numbers as a provider snapshot.
  for (const q of [
    db.collection("contacts").where("clientUid", "==", uid),
    db.collection("contacts").where("providerId", "==", uid),
  ]) {
    report.contactsDeleted += await drain(q, (docs) => deleteRefs(db, docs.map((d) => d.ref)));
  }

  // 5. Other users' favourites that point at this account (name/photo snapshot).
  report.favoritesOfProviderDeleted = await drain(
    db.collectionGroup("favorites").where("providerId", "==", uid),
    (docs) => deleteRefs(db, docs.map((d) => d.ref)),
  );

  // 6. Provider data: listings first (their delete trigger tolerates a missing
  //    provider), then the provider doc with its reviews, then verification.
  report.listingsDeleted = await drain(
    db.collection("listings").where("providerId", "==", uid),
    (docs) => deleteRefs(db, docs.map((d) => d.ref)),
  );
  await db.recursiveDelete(providerRef);
  await db.collection("verificationRequests").doc(uid).delete();

  // 7. Storage.
  for (const prefix of storagePrefixesFor(uid)) await deps.deleteStoragePrefix(prefix);

  // 8. users/{uid} with favorites, blocks, devices; then the Auth user, last,
  //    so a failure before this point leaves the account able to retry.
  await db.recursiveDelete(userRef);
  await deps.deleteAuthUser(uid);

  return report;
}
