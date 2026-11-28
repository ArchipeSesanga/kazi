// Runs against the Firestore emulator:
//   firebase emulators:exec --only firestore "npm --prefix functions test"
import { getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { anonymisedReviewId } from '../../src/lib/deleteAccount';
import { ratingScoreOf, recomputeProviderRating } from '../../src/lib/ratings';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;

describe.skipIf(!emulator)('onReviewWritten aggregate (Firestore emulator)', () => {
  const db = () => getFirestore();
  const reviews = () => db().collection('providers').doc('p1').collection('reviews');
  const provider = async () => (await db().collection('providers').doc('p1').get()).data()!;

  async function clear() {
    const snap = await db().collection('providers').get();
    for (const p of snap.docs) await db().recursiveDelete(p.ref);
  }

  beforeEach(async () => {
    await clear();
    await db().collection('providers').doc('p1').set({
      status: 'approved', displayName: 'Jean', ratingSum: 0, ratingCount: 0, ratingAvg: 0, listingCount: 0,
    });
  });
  afterAll(clear);

  const rate = (uid: string, rating: number) => reviews().doc(uid).set({ authorUid: uid, rating, text: '' });

  it('add: count, sum, average and score follow', async () => {
    await rate('u1', 5);
    await rate('u2', 4);
    expect(await recomputeProviderRating(db(), 'p1')).toBe(true);
    expect(await provider()).toMatchObject({
      ratingSum: 9, ratingCount: 2, ratingAvg: 4.5, ratingScore: ratingScoreOf(9, 2),
    });
  });

  it('edit: a changed rating moves the sum, not the count', async () => {
    await rate('u1', 5);
    await rate('u2', 4);
    await recomputeProviderRating(db(), 'p1');
    await rate('u2', 2);
    await recomputeProviderRating(db(), 'p1');
    expect(await provider()).toMatchObject({ ratingSum: 7, ratingCount: 2, ratingAvg: 3.5 });
  });

  it('delete: count decrements; the last review deleted gives 0', async () => {
    await rate('u1', 5);
    await rate('u2', 3);
    await recomputeProviderRating(db(), 'p1');
    await reviews().doc('u2').delete();
    await recomputeProviderRating(db(), 'p1');
    expect(await provider()).toMatchObject({ ratingSum: 5, ratingCount: 1, ratingAvg: 5 });
    await reviews().doc('u1').delete();
    await recomputeProviderRating(db(), 'p1');
    expect(await provider()).toMatchObject({ ratingSum: 0, ratingCount: 0, ratingAvg: 0, ratingScore: 4 });
  });

  it('anonymising move (delete + create, same rating) is net zero', async () => {
    await rate('u1', 4);
    await rate('u2', 5);
    await recomputeProviderRating(db(), 'p1');
    const before = await provider();
    // What deleteAccount does: the author's review moves to a stable anonymous id.
    await reviews().doc('u1').delete();
    await reviews().doc(anonymisedReviewId('u1', 'p1')).set({ authorUid: 'anonymous', rating: 4, text: '' });
    await recomputeProviderRating(db(), 'p1');
    expect(await provider()).toMatchObject({
      ratingSum: before.ratingSum, ratingCount: before.ratingCount,
      ratingAvg: before.ratingAvg, ratingScore: before.ratingScore,
    });
  });

  it('a duplicate delivery of the same event changes nothing', async () => {
    await rate('u1', 5);
    expect(await recomputeProviderRating(db(), 'p1')).toBe(true);
    const once = await provider();
    expect(await recomputeProviderRating(db(), 'p1')).toBe(false);
    expect(await recomputeProviderRating(db(), 'p1')).toBe(false);
    expect(await provider()).toEqual(once);
  });

  it('never creates a provider that does not exist', async () => {
    await db().collection('providers').doc('ghost').collection('reviews').doc('u1').set({ rating: 5 });
    expect(await recomputeProviderRating(db(), 'ghost')).toBe(false);
    expect((await db().collection('providers').doc('ghost').get()).exists).toBe(false);
  });

  it('ignores a malformed rating instead of corrupting the totals', async () => {
    await rate('u1', 5);
    await reviews().doc('bad').set({ authorUid: 'bad', rating: 9, text: '' });
    await recomputeProviderRating(db(), 'p1');
    expect(await provider()).toMatchObject({ ratingSum: 5, ratingCount: 1 });
  });
});
