import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, serverTimestamp, setDoc, updateDoc } from '@firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

/**
 * Reviews (TDD §4.5): a contact is required (enforced here, not only in the
 * UI), no self-review, one per user and provider, author edits / deletes, and
 * the provider's rating fields can never be written by a client. Every denial
 * has a passing twin so it is proven to come from the rule under test.
 */
const PHONE = (n: number) => `+24381000000${n}`;
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-reviews-rules-test',
    firestore: { rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());

const user = (uid: string, n: number) => testEnv.authenticatedContext(uid, { phone_number: PHONE(n) }).firestore();
const alice = () => user('alice', 1); // contacted p1
const bob = () => user('bob', 2); // never contacted anybody
const p1 = () => user('p1', 3); // the provider
const moderator = () => testEnv.authenticatedContext('mod', { moderator: true }).firestore();
const guest = () => testEnv.authenticatedContext('g').firestore(); // no phone number

const review = (extra: Record<string, unknown> = {}) => ({
  authorUid: 'alice', authorName: 'Alice', rating: 4, text: 'Très bon travail',
  createdAt: serverTimestamp(), updatedAt: serverTimestamp(), ...extra,
});
const path = (db: ReturnType<typeof alice>, uid = 'alice', pid = 'p1') => doc(db, 'providers', pid, 'reviews', uid);

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [uid, n] of [['alice', 1], ['bob', 2], ['p1', 3], ['p2', 4]] as const) {
      await setDoc(doc(db, 'users', uid), { displayName: uid, phone: PHONE(n), status: 'active' });
    }
    for (const pid of ['p1', 'p2']) {
      await setDoc(doc(db, 'providers', pid), {
        displayName: pid, status: 'approved', ratingAvg: 0, ratingCount: 0, ratingSum: 0, listingCount: 0,
        categoryIds: ['plomberie'], city: 'kinshasa', baseCommune: 'gombe', communes: ['gombe'],
        whatsappNumber: '+243812345678', yearsExperience: 1, portfolio: [],
      });
    }
    // alice contacted p1 only
    await setDoc(doc(db, 'contacts', 'alice_p1'), { clientUid: 'alice', providerId: 'p1' });
    // p1 "contacted" itself in the data (cannot happen through the contact rule): still no self-review
    await setDoc(doc(db, 'contacts', 'p1_p1'), { clientUid: 'p1', providerId: 'p1' });
  });
});

describe('creating a review', () => {
  it('a verified user who contacted the provider can review (twin of the denials)', async () => {
    await assertSucceeds(setDoc(path(alice()), review()));
  });

  it('without a prior contact with that provider it is denied', async () => {
    await assertFails(setDoc(path(bob(), 'bob'), review({ authorUid: 'bob', authorName: 'Bob' })));
    // alice contacted p1, not p2
    await assertFails(setDoc(path(alice(), 'alice', 'p2'), review()));
  });

  it('a contact of somebody else does not count', async () => {
    await assertFails(setDoc(path(bob(), 'bob'), review({ authorUid: 'bob', authorName: 'Bob' })));
    await assertFails(setDoc(path(bob(), 'alice'), review()));
  });

  it('a provider cannot review themselves', async () => {
    await assertFails(setDoc(path(p1(), 'p1'), review({ authorUid: 'p1', authorName: 'p1' })));
  });

  it('one review per user and provider: another id is denied, a repeat is only an edit', async () => {
    await assertSucceeds(setDoc(path(alice()), review()));
    await assertFails(setDoc(path(alice(), 'alice-2'), review({ authorUid: 'alice-2' })));
    // the same document again is an update: it may change rating/text, nothing else
    await assertSucceeds(updateDoc(path(alice()), { rating: 2, updatedAt: serverTimestamp() }));
    await assertFails(setDoc(path(alice()), review({ createdAt: serverTimestamp(), authorUid: 'bob' })));
  });

  it('whole stars 1–5 only', async () => {
    for (const rating of [0, 6, 3.5, '5', null]) {
      await assertFails(setDoc(path(alice()), review({ rating })));
    }
    await assertSucceeds(setDoc(path(alice()), review({ rating: 1 })));
    await assertSucceeds(updateDoc(path(alice()), { rating: 5, updatedAt: serverTimestamp() }));
  });

  it('comment up to 300 characters, optional', async () => {
    await assertFails(setDoc(path(alice()), review({ text: 'x'.repeat(301) })));
    await assertSucceeds(setDoc(path(alice()), review({ text: 'x'.repeat(300) })));
    await assertFails(updateDoc(path(alice()), { text: 'x'.repeat(301), updatedAt: serverTimestamp() }));
    await deleteDoc(path(alice()));
    const { text: _text, ...noText } = review();
    await assertSucceeds(setDoc(path(alice()), noText));
  });

  it('refuses a guest without a verified phone and a suspended-by-deletion user', async () => {
    await assertFails(setDoc(path(guest(), 'g'), review({ authorUid: 'g' })));
    await testEnv.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'users', 'alice'), { status: 'deleting' }, { merge: true }));
    await assertFails(setDoc(path(alice()), review()));
  });

  it('refuses client-set server fields on the review', async () => {
    await assertFails(setDoc(path(alice()), review({ providerReply: 'merci' })));
    await assertFails(setDoc(path(alice()), review({ createdAt: new Date() })));
  });
});

describe('editing and deleting', () => {
  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled((ctx) =>
      setDoc(doc(ctx.firestore(), 'providers', 'p1', 'reviews', 'alice'), {
        authorUid: 'alice', authorName: 'Alice', rating: 4, text: 'ok', createdAt: new Date(), updatedAt: new Date(),
      }),
    );
  });

  it('the author edits rating and comment, and deletes', async () => {
    await assertSucceeds(updateDoc(path(alice()), { rating: 5, text: 'Excellent', updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(path(alice())));
  });

  it('nobody else edits or deletes it (twin: the author can); a moderator can delete', async () => {
    await assertFails(updateDoc(path(bob(), 'alice'), { rating: 1, updatedAt: serverTimestamp() }));
    await assertFails(deleteDoc(path(bob(), 'alice')));
    await assertFails(updateDoc(path(p1(), 'alice'), { rating: 5, updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(path(moderator(), 'alice')));
  });

  it('the author cannot rewrite authorship or creation time', async () => {
    await assertFails(updateDoc(path(alice()), { authorUid: 'bob', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(path(alice()), { createdAt: serverTimestamp(), updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(path(alice()), { rating: 7, updatedAt: serverTimestamp() }));
  });
});

describe('rating fields on the provider are client-immutable', () => {
  const fields = ['ratingAvg', 'ratingCount', 'ratingSum', 'ratingScore'] as const;

  it('the owner can edit the profile (twin) but never a rating field', async () => {
    await assertSucceeds(updateDoc(doc(p1(), 'providers', 'p1'), { bio: 'Plombier', updatedAt: serverTimestamp() }));
    for (const f of fields) {
      await assertFails(updateDoc(doc(p1(), 'providers', 'p1'), { [f]: 5, updatedAt: serverTimestamp() }));
    }
  });

  it('nobody else can write them either, moderators included', async () => {
    for (const f of fields) {
      await assertFails(updateDoc(doc(alice(), 'providers', 'p1'), { [f]: 5 }));
      await assertFails(updateDoc(doc(moderator(), 'providers', 'p1'), { [f]: 5 }));
    }
  });

  it('a new provider cannot start with a rating or a ratingScore', async () => {
    const base = {
      displayName: 'Alice Plomberie', categoryIds: ['plomberie'], city: 'kinshasa', baseCommune: 'gombe',
      communes: ['gombe'], whatsappNumber: '+243812345678', callNumber: null, yearsExperience: 3, portfolio: [],
      status: 'pending', verified: false, ratingAvg: 0, ratingCount: 0, ratingSum: 0, listingCount: 0,
      createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
    };
    await assertSucceeds(setDoc(doc(alice(), 'providers', 'alice'), base));
    await assertFails(setDoc(doc(alice(), 'providers', 'alice'), { ...base, ratingScore: 5 }));
    await assertFails(setDoc(doc(alice(), 'providers', 'alice'), { ...base, ratingAvg: 5, ratingCount: 1, ratingSum: 5 }));
  });
});
