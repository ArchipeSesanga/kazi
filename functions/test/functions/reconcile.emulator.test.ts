// Runs against the Firestore emulator:
//   firebase emulators:exec --only firestore "npm --prefix functions test"
import { getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { getMaxListingsPerProvider } from '../../src/lib/limits';
import { reconcileListing } from '../../src/lib/reconcile';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;

describe.skipIf(!emulator)('reconcileListing (Firestore emulator)', () => {
  const db = () => getFirestore();

  async function clear() {
    for (const c of ['listings', 'providers', 'categories', 'config']) {
      const snap = await db().collection(c).get();
      await Promise.all(snap.docs.map((d) => d.ref.delete()));
    }
  }

  async function seed(providerStatus: string | null, listing: Record<string, unknown> = {}) {
    if (providerStatus) {
      await db().collection('providers').doc('p1').set({
        status: providerStatus, displayName: 'Jean Mukendi', verified: true,
        ratingAvg: 4.5, ratingCount: 3, listingCount: 0,
      });
    }
    await db().collection('categories').doc('plomberie').set({ names: { fr: 'Plomberie', en: 'Plumbing' } });
    await db().collection('listings').doc('l1').set({
      providerId: 'p1', title: 'Réparation de fuite', categoryId: 'plomberie',
      status: 'active', communes: ['gombe'], city: 'kinshasa', ...listing,
    });
  }
  const read = async () => (await db().collection('listings').doc('l1').get()).data()!;

  beforeEach(clear);
  afterAll(clear);

  it('makes an active listing of an approved provider visible with all derived fields', async () => {
    await seed('approved');
    expect(await reconcileListing(db(), 'l1')).toBe(true);
    const d = await read();
    expect(d).toMatchObject({
      visible: true, moderation: 'ok', providerStatus: 'approved',
      providerName: 'Jean Mukendi', providerVerified: true, ratingAvg: 4.5, ratingCount: 3,
      categoryName: { fr: 'Plomberie', en: 'Plumbing' },
    });
    expect(d.publishedAt).toBeDefined();
    expect(d.searchKeywords).toEqual(expect.arrayContaining(['reparation', 'fuite', 'plomberie', 'jean', 'gombe']));
  });

  it('is idempotent: the second run writes nothing (ends the trigger loop)', async () => {
    await seed('approved');
    await reconcileListing(db(), 'l1');
    expect(await reconcileListing(db(), 'l1')).toBe(false);
  });

  it('pause hides it, keeps publishedAt; resume shows it again', async () => {
    await seed('approved');
    await reconcileListing(db(), 'l1');
    const publishedAt = (await read()).publishedAt;

    await db().collection('listings').doc('l1').update({ status: 'paused' });
    await reconcileListing(db(), 'l1');
    expect((await read()).visible).toBe(false);

    await db().collection('listings').doc('l1').update({ status: 'active' });
    await reconcileListing(db(), 'l1');
    const d = await read();
    expect(d.visible).toBe(true);
    expect(d.publishedAt.isEqual(publishedAt)).toBe(true);
  });

  it.each(['pending', 'rejected', 'suspended'])('provider %s → not visible, no publishedAt', async (status) => {
    await seed(status);
    await reconcileListing(db(), 'l1');
    const d = await read();
    expect(d.visible).toBe(false);
    expect(d.providerStatus).toBe(status);
    expect(d.publishedAt).toBeUndefined();
  });

  it('missing provider → not visible', async () => {
    await seed(null);
    await reconcileListing(db(), 'l1');
    expect((await read()).visible).toBe(false);
  });

  it('phone number in title → hidden with auto_content, restored when removed', async () => {
    await seed('approved', { title: 'Plombier 0812345678' });
    await reconcileListing(db(), 'l1');
    expect(await read()).toMatchObject({ visible: false, moderation: 'hidden', moderationReason: 'auto_content' });

    await db().collection('listings').doc('l1').update({ title: 'Plombier rapide' });
    await reconcileListing(db(), 'l1');
    const d = await read();
    expect(d).toMatchObject({ visible: true, moderation: 'ok' });
    expect(d.moderationReason).toBeUndefined();
  });
});

describe.skipIf(!emulator)('config/limits (Firestore emulator)', () => {
  const db = () => getFirestore();
  beforeEach(async () => {
    const snap = await db().collection('config').get();
    await Promise.all(snap.docs.map((d) => d.ref.delete()));
  });

  it('reads config/limits, falling back to 10', async () => {
    expect(await getMaxListingsPerProvider(db())).toBe(10);
    await db().collection('config').doc('limits').set({ maxListingsPerProvider: 25 });
    expect(await getMaxListingsPerProvider(db())).toBe(25);
    await db().collection('config').doc('limits').set({ maxListingsPerProvider: 'x' });
    expect(await getMaxListingsPerProvider(db())).toBe(10);
  });
});
