import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  type Firestore,
} from '@firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

/**
 * Access model: "signed in" = verified phone number or a staff claim
 * (admin / moderator). Guests and email-only accounts can read and write
 * nothing. Every denial below is paired with a passing twin that uses the
 * same operation as a verified-phone user, so a denial is proven to come
 * from the account type and not from a bad payload.
 */
const uid = 'u1';
const PHONE = '+243810000001';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-access-rules-test',
    firestore: { rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', uid), {
      displayName: 'Alice Mbuyi', phone: PHONE, locale: 'fr', city: 'kinshasa',
      termsVersion: '1', status: 'active',
    });
    await setDoc(doc(db, 'users', 'other'), {
      displayName: 'Bob', phone: '+243810000002', locale: 'fr', city: 'kinshasa',
      termsVersion: '1', status: 'active',
    });
    await setDoc(doc(db, 'users', uid, 'favorites', 'p1'), { providerId: 'p1', displayName: 'P' });
    await setDoc(doc(db, 'providers', 'p1'), {
      displayName: 'Jean', status: 'approved', listingCount: 0, ratingAvg: 0,
    });
    await setDoc(doc(db, 'providers', 'pending1'), { displayName: 'Nouveau', status: 'pending' });
    await setDoc(doc(db, 'providers', 'p1', 'reviews', 'someone'), {
      authorUid: 'someone', authorName: 'Eve', rating: 5,
    });
    await setDoc(doc(db, 'listings', 'visible1'), { providerId: 'p1', visible: true, title: 'Visible' });
    await setDoc(doc(db, 'listings', 'draft1'), { providerId: 'p1', visible: false, title: 'Draft' });
    await setDoc(doc(db, 'categories', 'plomberie'), { name: 'Plomberie' });
    await setDoc(doc(db, 'config', 'limits'), { maxListingsPerProvider: 10 });
    await setDoc(doc(db, 'adminLogs', 'log1'), { action: 'x' });
    await setDoc(doc(db, 'reports', 'r0'), { status: 'open' });
    await setDoc(doc(db, 'contacts', 'u1_p1'), { clientUid: uid, providerId: 'p1' });
  });
});

const phone = () => testEnv.authenticatedContext(uid, { phone_number: PHONE }).firestore();
const emailOnly = () => testEnv.authenticatedContext(uid, { email: 'dev@example.com' }).firestore();
const guest = () => testEnv.unauthenticatedContext().firestore();
const admin = () => testEnv.authenticatedContext('admin1', { admin: true, email: 'a@kazi.test' }).firestore();
const moderator = () =>
  testEnv.authenticatedContext('mod1', { moderator: true, email: 'm@kazi.test' }).firestore();

type Op = (db: Firestore) => Promise<unknown>;

/** The same operation: allowed for a verified phone user, denied for the rest. */
function onlyVerifiedPhone(name: string, op: Op) {
  describe(name, () => {
    it('allows a verified-phone user', () => assertSucceeds(op(phone())));
    it('denies an email-only account', () => assertFails(op(emailOnly())));
    it('denies a guest', () => assertFails(op(guest())));
  });
}

const read = (path: string): Op => (db) => getDoc(doc(db, path));

describe('reads are sign-in only', () => {
  onlyVerifiedPhone('categories', read('categories/plomberie'));
  onlyVerifiedPhone('config/limits', read('config/limits'));
  onlyVerifiedPhone('approved provider', read('providers/p1'));
  onlyVerifiedPhone('visible listing', read('listings/visible1'));
  onlyVerifiedPhone('provider review', read('providers/p1/reviews/someone'));
  onlyVerifiedPhone('own users doc', read(`users/${uid}`));
  onlyVerifiedPhone('own favorites', read(`users/${uid}/favorites/p1`));
  onlyVerifiedPhone('own contact', read('contacts/u1_p1'));
  onlyVerifiedPhone('reviews collection group', (db) => getDocs(collectionGroup(db, 'reviews')));

  describe('what a verified-phone user still cannot read', () => {
    it('another user’s profile', () => assertFails(read('users/other')(phone())));
    it('a pending provider', () => assertFails(read('providers/pending1')(phone())));
    it('someone else’s draft listing', () => assertFails(read('listings/draft1')(phone())));
    it('reports and the audit log', async () => {
      await assertFails(read('reports/r0')(phone()));
      await assertFails(read('adminLogs/log1')(phone()));
    });
  });
});

describe('writes are verified-phone only', () => {
  const stamp = () => serverTimestamp();

  onlyVerifiedPhone('favorite', (db) =>
    setDoc(doc(db, 'users', uid, 'favorites', 'p2'), { providerId: 'p2', displayName: 'Plombier', createdAt: stamp() }),
  );

  onlyVerifiedPhone('block', (db) =>
    setDoc(doc(db, 'users', uid, 'blocks', 'x'), { createdAt: stamp() }),
  );

  onlyVerifiedPhone('contact', (db) =>
    setDoc(doc(db, 'contacts', `${uid}_p2`), {
      clientUid: uid, providerId: 'p2', providerName: 'Jean', channel: 'whatsapp',
      providerVerified: false, whatsappNumber: '+243812345678', firstAt: stamp(), lastAt: stamp(),
    }),
  );

  onlyVerifiedPhone('report', (db) =>
    setDoc(doc(db, 'reports', `${uid}_provider_p1`), {
      reporterUid: uid, targetType: 'provider', targetKey: 'p1', reason: 'scam',
      status: 'open', createdAt: stamp(),
    }),
  );

  onlyVerifiedPhone('review (after contact)', (db) =>
    setDoc(doc(db, 'providers', 'p1', 'reviews', uid), {
      authorUid: uid, authorName: 'Alice', rating: 4, createdAt: stamp(), updatedAt: stamp(),
    }),
  );

  onlyVerifiedPhone('provider profile', (db) =>
    setDoc(doc(db, 'providers', uid), {
      displayName: 'Alice Plomberie', categoryIds: ['plomberie'], city: 'kinshasa',
      baseCommune: 'gombe', communes: ['gombe'], whatsappNumber: '+243812345678',
      callNumber: null, yearsExperience: 3, portfolio: [], status: 'pending', verified: false,
      ratingAvg: 0, ratingCount: 0, ratingSum: 0, listingCount: 0,
      createdAt: stamp(), updatedAt: stamp(),
    }),
  );

  describe('listing', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await setDoc(doc(ctx.firestore(), 'providers', uid), { status: 'approved', listingCount: 0 });
      });
    });
    onlyVerifiedPhone('create', (db) =>
      setDoc(doc(db, 'listings', 'new1'), {
        providerId: uid, title: 'Plomberie rapide', description: '', categoryId: 'plomberie',
        priceType: 'quote', currency: 'USD', photos: [], city: 'kinshasa', communes: ['gombe'],
        status: 'draft', createdAt: stamp(), updatedAt: stamp(),
      }),
    );
  });

  onlyVerifiedPhone('profile update', (db) =>
    // Same user, same payload: only the account type differs.
    import('@firebase/firestore').then(({ updateDoc }) =>
      updateDoc(doc(db, 'users', uid), { displayName: 'Alice M.', updatedAt: serverTimestamp() }),
    ),
  );
});

describe('staff claims', () => {
  describe('admin (no phone)', () => {
    it('reads users, reports and the audit log', async () => {
      await assertSucceeds(read('users/other')(admin()));
      await assertSucceeds(read('reports/r0')(admin()));
      await assertSucceeds(read('adminLogs/log1')(admin()));
    });
    it('reads the sign-in-only data', async () => {
      await assertSucceeds(read('categories/plomberie')(admin()));
      await assertSucceeds(read('providers/pending1')(admin()));
    });
    it('cannot write the server-only audit log or categories', async () => {
      await assertFails(setDoc(doc(admin(), 'adminLogs', 'log2'), { action: 'y' }));
      await assertFails(setDoc(doc(admin(), 'categories', 'new'), { name: 'x' }));
    });
    it('cannot create a consumer profile without a verified phone', async () => {
      await assertFails(setDoc(doc(admin(), 'users', 'admin1'), { displayName: 'Admin', phone: '' }));
    });
  });

  describe('moderator (no phone): moderation actions only', () => {
    it('reads what moderation needs', async () => {
      await assertSucceeds(read('reports/r0')(moderator()));
      await assertSucceeds(read('providers/pending1')(moderator()));
      await assertSucceeds(read('listings/draft1')(moderator()));
      await assertSucceeds(read('users/other')(moderator()));
      await assertSucceeds(read('categories/plomberie')(moderator()));
    });
    it('can remove an abusive review (twin: a plain phone user cannot)', async () => {
      await assertFails(deleteDoc(doc(phone(), 'providers', 'p1', 'reviews', 'someone')));
      await assertSucceeds(deleteDoc(doc(moderator(), 'providers', 'p1', 'reviews', 'someone')));
    });
    it('cannot read the admin audit log (twin: admin can)', async () => {
      await assertSucceeds(read('adminLogs/log1')(admin()));
      await assertFails(read('adminLogs/log1')(moderator()));
    });
    it('cannot write categories, config or the audit log', async () => {
      await assertFails(setDoc(doc(moderator(), 'categories', 'new'), { name: 'x' }));
      await assertFails(setDoc(doc(moderator(), 'config', 'limits'), { maxListingsPerProvider: 99 }));
      await assertFails(setDoc(doc(moderator(), 'adminLogs', 'log2'), { action: 'y' }));
    });
    it('cannot create a consumer profile or act as a provider', async () => {
      await assertFails(setDoc(doc(moderator(), 'users', 'mod1'), { displayName: 'Mod', phone: '' }));
      await assertFails(
        setDoc(doc(moderator(), 'providers', 'p1'), { displayName: 'Hijack', status: 'approved' }),
      );
    });
  });
});
