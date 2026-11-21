// Runs against the Firestore emulator (see reconcile.emulator.test.ts).
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { assertFreshLogin, RECENT_LOGIN_SECONDS } from '../../src/callables/deleteAccount';
import { approveProviderIfExists } from '../../src/lib/approveProvider';
import {
  anonymisedReviewId,
  DELETED_AUTHOR_NAME,
  DELETED_AUTHOR_UID,
  deleteAccountData,
  storagePrefixesFor,
  type DeleteAccountDeps,
} from '../../src/lib/deleteAccount';
import { processListingWrite } from '../../src/lib/processListing';
import { syncListingSlot } from '../../src/lib/listingSlots';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;
const UID = 'u1';

describe('assertFreshLogin', () => {
  const now = 1_800_000_000;
  const phone = (authTime: number | undefined) => ({ phone_number: '+243810000001', auth_time: authTime });
  const code = (fn: () => void) => {
    try {
      fn();
    } catch (e) {
      return (e as HttpsError).code + ':' + (e as HttpsError).message;
    }
    return 'ok';
  };

  it('accepts a verified user who confirmed an OTP just now', () => {
    expect(code(() => assertFreshLogin(phone(now - 10), now))).toBe('ok');
    expect(code(() => assertFreshLogin(phone(now - RECENT_LOGIN_SECONDS), now))).toBe('ok');
  });
  it('rejects a stale sign-in and asks for a fresh OTP', () => {
    expect(code(() => assertFreshLogin(phone(now - RECENT_LOGIN_SECONDS - 1), now))).toBe(
      'failed-precondition:recent-login-required',
    );
    expect(code(() => assertFreshLogin(phone(now - 86400), now))).toContain('recent-login-required');
  });
  it('rejects a token without auth_time', () => {
    expect(code(() => assertFreshLogin(phone(undefined), now))).toContain('recent-login-required');
  });
  it('rejects an email-only account even with a fresh login', () => {
    expect(code(() => assertFreshLogin({ email: 'a@b.cd', auth_time: now }, now))).toContain('permission-denied');
    expect(code(() => assertFreshLogin(undefined, now))).toContain('permission-denied');
  });
});

describe.skipIf(!emulator)('deleteAccountData (Firestore emulator)', () => {
  const db = () => getFirestore();
  const exists = async (path: string) => (await db().doc(path).get()).exists;

  async function clear() {
    for (const c of ['users', 'providers', 'listings', 'contacts', 'reports', 'reportQuota', 'verificationRequests', 'config', 'categories']) {
      await db().recursiveDelete(db().collection(c));
    }
  }

  async function seed() {
    const d = db();
    await d.doc(`users/${UID}`).set({ displayName: 'Alice', phone: '+243810000001', status: 'active' });
    await d.doc(`users/${UID}/favorites/p9`).set({ providerId: 'p9' });
    await d.doc(`users/${UID}/blocks/x`).set({});
    await d.doc(`users/${UID}/devices/d1`).set({ fcmToken: 't' });
    await d.doc(`providers/${UID}`).set({ displayName: 'Alice Plomberie', status: 'approved', listingCount: 2, whatsappNumber: '+243810000001' });
    await d.doc(`providers/${UID}/reviews/someone`).set({ authorUid: 'someone', authorName: 'Eve', rating: 5 });
    await d.doc(`listings/l1`).set({ providerId: UID, status: 'active', countsTowardLimit: true, photos: [] });
    await d.doc(`listings/l2`).set({ providerId: UID, status: 'paused', countsTowardLimit: true, photos: [] });
    await d.doc(`verificationRequests/${UID}`).set({ status: 'pending' });
    // Reviews Alice wrote for other providers (doc id = her uid).
    await d.doc(`providers/p9/reviews/${UID}`).set({
      authorUid: UID, authorName: 'Alice M.', authorPhotoUrl: 'https://x/alice.jpg',
      rating: 4, text: 'Très bon travail',
    });
    await d.doc(`providers/p8/reviews/${UID}`).set({ authorUid: UID, authorName: 'Alice M.', rating: 2 });
    await d.doc(`providers/p9/reviews/bob`).set({ authorUid: 'bob', authorName: 'Bob', rating: 5 });
    await d.doc(`reports/${UID}_provider_p9`).set({ reporterUid: UID, targetType: 'provider', targetKey: 'p9', status: 'open' });
    await d.doc(`reports/bob_provider_p9`).set({ reporterUid: 'bob', targetType: 'provider', targetKey: 'p9', status: 'open' });
    await d.doc(`contacts/${UID}_p9`).set({ clientUid: UID, providerId: 'p9' });
    await d.doc(`contacts/bob_${UID}`).set({ clientUid: 'bob', providerId: UID, whatsappNumber: '+243810000001' });
    await d.doc(`contacts/bob_p9`).set({ clientUid: 'bob', providerId: 'p9' });
    await d.doc(`users/bob`).set({ displayName: 'Bob', status: 'active' });
    await d.doc(`users/bob/favorites/${UID}`).set({ providerId: UID, displayName: 'Alice Plomberie' });
    await d.doc(`users/bob/favorites/p9`).set({ providerId: 'p9' });
    await d.doc(`providers/p9`).set({ displayName: 'Paul', status: 'approved', listingCount: 1 });
    await d.doc(`listings/l9`).set({ providerId: 'p9', status: 'active', countsTowardLimit: true, photos: [] });
  }

  function makeDeps(opts: { failStorageOnce?: boolean; failAuthOnce?: boolean } = {}) {
    const prefixes: string[] = [];
    const authDeleted: string[] = [];
    let failStorage = opts.failStorageOnce ?? false;
    let failAuth = opts.failAuthOnce ?? false;
    const deps: DeleteAccountDeps = {
      deleteStoragePrefix: async (p) => {
        if (failStorage) {
          failStorage = false;
          throw new Error('storage unavailable');
        }
        prefixes.push(p);
      },
      deleteAuthUser: async (id) => {
        if (failAuth) {
          failAuth = false;
          throw new Error('auth unavailable');
        }
        authDeleted.push(id);
      },
    };
    return { deps, prefixes, authDeleted };
  }

  beforeEach(async () => {
    await clear();
    await seed();
  });
  afterAll(clear);

  it('deletes the user doc and its subcollections', async () => {
    const { deps } = makeDeps();
    await deleteAccountData(db(), UID, deps);
    expect(await exists(`users/${UID}`)).toBe(false);
    for (const p of ['favorites/p9', 'blocks/x', 'devices/d1']) {
      expect(await exists(`users/${UID}/${p}`)).toBe(false);
    }
  });

  it('deletes the report rate-limit counter of the account only', async () => {
    await db().doc(`reportQuota/${UID}`).set({ windowStart: 1, count: 3 });
    await db().doc('reportQuota/bob').set({ windowStart: 1, count: 1 });
    await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists(`reportQuota/${UID}`)).toBe(false);
    expect(await exists('reportQuota/bob')).toBe(true);
  });

  it('deletes the provider doc, its reviews and verification request', async () => {
    await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists(`providers/${UID}`)).toBe(false);
    expect(await exists(`providers/${UID}/reviews/someone`)).toBe(false);
    expect(await exists(`verificationRequests/${UID}`)).toBe(false);
  });

  it('deletes all of the provider’s listings and reports the count', async () => {
    const r = await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists('listings/l1')).toBe(false);
    expect(await exists('listings/l2')).toBe(false);
    expect(r.listingsDeleted).toBe(2);
  });

  it('deletes exactly the two Storage prefixes of the account, with a trailing slash', async () => {
    const { deps, prefixes } = makeDeps();
    await deleteAccountData(db(), UID, deps);
    expect(prefixes).toEqual([`media/${UID}/`, `private/verification/${UID}/`]);
    expect(storagePrefixesFor('u1')).toEqual(prefixes);
    // "media/u1/" must not match "media/u10/..."
    expect(prefixes.every((p) => p.endsWith('/'))).toBe(true);
  });

  it('deletes the Auth user, last', async () => {
    const order: string[] = [];
    await deleteAccountData(db(), UID, {
      deleteStoragePrefix: async () => void order.push('storage'),
      deleteAuthUser: async () => {
        order.push('auth');
        // By now everything else is already gone.
        expect(await exists(`users/${UID}`)).toBe(false);
        expect(await exists(`providers/${UID}`)).toBe(false);
      },
    });
    expect(order).toEqual(['storage', 'storage', 'auth']);
  });

  describe('reviews written by the user', () => {
    it('are anonymised, not deleted: rating and text stay, identity goes', async () => {
      const r = await deleteAccountData(db(), UID, makeDeps().deps);
      expect(r.reviewsAnonymised).toBe(2);
      const moved = (await db().doc(`providers/p9/reviews/${anonymisedReviewId(UID, 'p9')}`).get()).data()!;
      expect(moved).toMatchObject({
        authorUid: DELETED_AUTHOR_UID, authorName: DELETED_AUTHOR_NAME, rating: 4, text: 'Très bon travail',
      });
      expect(moved.authorPhotoUrl).toBeUndefined();
      expect(JSON.stringify(moved)).not.toContain('Alice');
    });

    it('no longer live under the user’s uid, and the id does not contain it', async () => {
      await deleteAccountData(db(), UID, makeDeps().deps);
      expect(await exists(`providers/p9/reviews/${UID}`)).toBe(false);
      expect(await exists(`providers/p8/reviews/${UID}`)).toBe(false);
      expect(anonymisedReviewId(UID, 'p9')).not.toContain(UID);
      const left = await db().collectionGroup('reviews').where('authorUid', '==', UID).get();
      expect(left.empty).toBe(true);
    });

    it('leave other people’s reviews alone', async () => {
      await deleteAccountData(db(), UID, makeDeps().deps);
      expect((await db().doc('providers/p9/reviews/bob').get()).data()).toMatchObject({ authorName: 'Bob', rating: 5 });
    });
  });

  it('keeps reports filed by the user, anonymised, and leaves others', async () => {
    const r = await deleteAccountData(db(), UID, makeDeps().deps);
    expect(r.reportsAnonymised).toBe(1);
    expect((await db().doc(`reports/${UID}_provider_p9`).get()).data()).toMatchObject({
      reporterUid: DELETED_AUTHOR_UID, targetKey: 'p9', status: 'open',
    });
    expect((await db().doc('reports/bob_provider_p9').get()).data()!.reporterUid).toBe('bob');
  });

  it('deletes contacts of the user and contacts that hold the provider’s numbers', async () => {
    await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists(`contacts/${UID}_p9`)).toBe(false);
    expect(await exists(`contacts/bob_${UID}`)).toBe(false);
    expect(await exists('contacts/bob_p9')).toBe(true);
  });

  it('removes other users’ favourites that point at the account, and only those', async () => {
    await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists(`users/bob/favorites/${UID}`)).toBe(false);
    expect(await exists('users/bob/favorites/p9')).toBe(true);
  });

  it('does not touch unrelated users, providers or listings', async () => {
    await deleteAccountData(db(), UID, makeDeps().deps);
    for (const p of ['users/bob', 'providers/p9', 'listings/l9']) expect(await exists(p)).toBe(true);
  });

  describe('retry after a partial failure', () => {
    it('storage fails: nothing is lost, Auth is untouched, the retry finishes', async () => {
      const first = makeDeps({ failStorageOnce: true });
      await expect(deleteAccountData(db(), UID, first.deps)).rejects.toThrow('storage unavailable');
      expect(first.authDeleted).toEqual([]);
      // The account still exists in 'deleting' state so the user can retry.
      expect((await db().doc(`users/${UID}`).get()).data()!.status).toBe('deleting');

      const second = makeDeps();
      await deleteAccountData(db(), UID, second.deps);
      expect(second.prefixes).toHaveLength(2);
      expect(second.authDeleted).toEqual([UID]);
      expect(await exists(`users/${UID}`)).toBe(false);
      expect(await exists(`providers/${UID}`)).toBe(false);
      // Review anonymisation was not repeated into duplicates.
      const anon = await db().collectionGroup('reviews').where('authorUid', '==', DELETED_AUTHOR_UID).get();
      expect(anon.size).toBe(2);
    });

    it('Auth deletion fails after the data is gone: the retry only has the Auth user left', async () => {
      const first = makeDeps({ failAuthOnce: true });
      await expect(deleteAccountData(db(), UID, first.deps)).rejects.toThrow('auth unavailable');
      expect(await exists(`users/${UID}`)).toBe(false); // the user doc is already gone

      const second = makeDeps();
      await deleteAccountData(db(), UID, second.deps);
      expect(second.authDeleted).toEqual([UID]);
    });

    it('running it again after success is a harmless no-op', async () => {
      await deleteAccountData(db(), UID, makeDeps().deps);
      const again = makeDeps();
      const r = await deleteAccountData(db(), UID, again.deps);
      expect(r).toEqual({
        reviewsAnonymised: 0, reportsAnonymised: 0, contactsDeleted: 0,
        listingsDeleted: 0, favoritesOfProviderDeleted: 0,
      });
      expect(again.authDeleted).toEqual([UID]);
      expect(await exists(`users/${UID}`)).toBe(false);
    });
  });

  it('never creates documents for a user who was never a provider', async () => {
    await db().recursiveDelete(db().doc(`providers/${UID}`));
    await db().recursiveDelete(db().collection('listings'));
    await deleteAccountData(db(), UID, makeDeps().deps);
    expect(await exists(`providers/${UID}`)).toBe(false);
    expect(await exists(`verificationRequests/${UID}`)).toBe(false);
  });

  describe('triggers must not recreate a deleted provider', () => {
    it('deleting the account’s listings runs the delete trigger without recreating the provider', async () => {
      await deleteAccountData(db(), UID, makeDeps().deps);
      // The trigger fires after the provider doc is gone.
      await processListingWrite(db(), 'l1', { providerId: UID, countsTowardLimit: true, photos: [] }, undefined);
      await processListingWrite(db(), 'l2', { providerId: UID, countsTowardLimit: true, photos: [] }, undefined);
      expect(await exists(`providers/${UID}`)).toBe(false);
    });

    it('a late listing write (slot sync / reconcile) does not recreate the provider', async () => {
      await deleteAccountData(db(), UID, makeDeps().deps);
      // A listing written by a racing client after the provider doc was removed.
      await db().doc('listings/late').set({
        providerId: UID, title: 'Réparation', categoryId: 'plomberie', status: 'active',
        communes: ['gombe'], city: 'kinshasa', photos: [],
      });
      expect(await syncListingSlot(db(), 'late')).toBe(false);
      await processListingWrite(db(), 'late', undefined, (await db().doc('listings/late').get()).data());
      expect(await exists(`providers/${UID}`)).toBe(false);
    });

    it('auto-approval updates only an existing provider', async () => {
      const ref = db().doc(`providers/${UID}`);
      await db().recursiveDelete(ref);
      expect(await approveProviderIfExists(ref)).toBe(false);
      expect(await exists(`providers/${UID}`)).toBe(false);

      await db().doc('providers/pending1').set({ status: 'pending' });
      expect(await approveProviderIfExists(db().doc('providers/pending1'))).toBe(true);
      expect((await db().doc('providers/pending1').get()).data()!.status).toBe('approved');
    });
  });
});
