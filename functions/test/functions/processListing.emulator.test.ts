// Runs against the Firestore emulator (see reconcile.emulator.test.ts).
import { getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { processListingWrite } from '../../src/lib/processListing';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;

describe.skipIf(!emulator)('processListingWrite (Firestore emulator)', () => {
  const db = () => getFirestore();
  const listing = (id: string) => db().collection('listings').doc(id);
  const providerCount = async () =>
    (await db().collection('providers').doc('p1').get()).data()!.listingCount as number;

  async function clear() {
    for (const c of ['listings', 'providers', 'categories', 'config']) {
      const snap = await db().collection(c).get();
      await Promise.all(snap.docs.map((d) => d.ref.delete()));
    }
  }

  async function setup(listingCount: number, max?: number) {
    await db().collection('providers').doc('p1').set({
      status: 'approved', displayName: 'Jean', listingCount,
    });
    await db().collection('categories').doc('plomberie').set({ name: { fr: 'Plomberie', en: 'Plumbing' } });
    if (max !== undefined) await db().collection('config').doc('limits').set({ maxListingsPerProvider: max });
  }

  /** Creates the doc and runs the handler as the trigger would on create. */
  async function create(id: string, extra: Record<string, unknown> = {}) {
    const data = {
      providerId: 'p1', title: 'Réparation de fuite', categoryId: 'plomberie',
      status: 'active', communes: ['gombe'], city: 'kinshasa',
      photos: [{ id: 'a', path: 'media/p1/listings/' + id + '/a.jpg', url: 'https://x/a' }],
      ...extra,
    };
    await listing(id).set(data);
    return processListingWrite(db(), id, undefined, data);
  }

  beforeEach(clear);
  afterAll(clear);

  describe('over the limit', () => {
    it('hides with over_limit, keeps the doc and photos, does not count', async () => {
      await setup(10, 10);
      const r = await create('l1');
      expect(r.wrote).toBe(true);

      const d = (await listing('l1').get()).data()!;
      expect(d).toMatchObject({
        status: 'active', moderation: 'hidden', moderationReason: 'over_limit', visible: false,
      });
      expect(d.countsTowardLimit).not.toBe(true);
      expect(d.photos).toHaveLength(1); // photos kept
      expect(await providerCount()).toBe(10); // not incremented
    });

    it('at 9 of 10 the listing is visible and counted', async () => {
      await setup(9, 10);
      await create('l1');
      const d = (await listing('l1').get()).data()!;
      expect(d).toMatchObject({ visible: true, moderation: 'ok', countsTowardLimit: true });
      expect(await providerCount()).toBe(10);
    });

    it('a draft does not count and is not blocked at the limit', async () => {
      await setup(10, 10);
      await create('l1', { status: 'draft' });
      const d = (await listing('l1').get()).data()!;
      expect(d.moderation).not.toBe('hidden');
      expect(await providerCount()).toBe(10);
    });

    it('re-saving after a slot frees up restores the listing', async () => {
      await setup(10, 10);
      await create('l1'); // hidden over_limit
      await db().collection('providers').doc('p1').update({ listingCount: 9 }); // another listing deleted

      const after = { ...(await listing('l1').get()).data(), title: 'Réparation de fuite urgente' };
      await listing('l1').update({ title: after.title }); // user edit
      await processListingWrite(db(), 'l1', undefined, after);

      const d = (await listing('l1').get()).data()!;
      expect(d).toMatchObject({ visible: true, moderation: 'ok', countsTowardLimit: true });
      expect(d.moderationReason).toBeUndefined();
      expect(await providerCount()).toBe(10);
    });

    it('is not an admin/report hide: those stay hidden even with a free slot', async () => {
      await setup(0, 10);
      await create('l1', { moderation: 'hidden', moderationReason: 'auto_reports' });
      const d = (await listing('l1').get()).data()!;
      expect(d).toMatchObject({ visible: false, moderation: 'hidden', moderationReason: 'auto_reports' });
    });

    it('respects a lowered configured limit', async () => {
      await setup(3, 3);
      await create('l1');
      expect((await listing('l1').get()).data()).toMatchObject({ moderationReason: 'over_limit' });
    });
  });

  describe('counting only active + paused', () => {
    it('pause keeps the slot; moving to draft frees it; delete frees it', async () => {
      await setup(0, 10);
      await create('l1');
      expect(await providerCount()).toBe(1);

      await listing('l1').update({ status: 'paused' });
      await processListingWrite(db(), 'l1', undefined, (await listing('l1').get()).data());
      expect(await providerCount()).toBe(1);

      await listing('l1').update({ status: 'draft' });
      await processListingWrite(db(), 'l1', undefined, (await listing('l1').get()).data());
      expect(await providerCount()).toBe(0);
      expect((await listing('l1').get()).data()!.countsTowardLimit).toBe(false);

      await listing('l1').update({ status: 'active' });
      await processListingWrite(db(), 'l1', undefined, (await listing('l1').get()).data());
      expect(await providerCount()).toBe(1);

      const before = (await listing('l1').get()).data();
      await listing('l1').delete();
      await processListingWrite(db(), 'l1', before, undefined);
      expect(await providerCount()).toBe(0);
    });

    it('deleting a listing that never held a slot does not decrement', async () => {
      await setup(10, 10);
      await create('l1'); // over_limit, not counted
      const before = (await listing('l1').get()).data();
      await listing('l1').delete();
      await processListingWrite(db(), 'l1', before, undefined);
      expect(await providerCount()).toBe(10);
    });
  });

  describe('no self-trigger loop', () => {
    /**
     * Replays what Firestore does: each write by the handler produces another
     * event, which the handler must answer with `wrote: false`.
     */
    async function runUntilQuiet(id: string, firstBefore: Record<string, unknown> | undefined) {
      let before = firstBefore;
      const wrote: boolean[] = [];
      for (let i = 0; i < 5; i++) {
        const after = (await listing(id).get()).data();
        const r = await processListingWrite(db(), id, before, after);
        wrote.push(r.wrote);
        if (!r.wrote) break;
        before = after;
      }
      return wrote;
    }

    it('one save → one handler write, then the self-triggered run is a no-op', async () => {
      await setup(0, 10);
      const data = {
        providerId: 'p1', title: 'Réparation de fuite', categoryId: 'plomberie',
        status: 'active', communes: ['gombe'], city: 'kinshasa', photos: [],
      };
      await listing('l1').set(data);
      const wrote = await runUntilQuiet('l1', undefined);
      expect(wrote).toEqual([true, false]); // invocations: 2, writes: 1
      expect(await providerCount()).toBe(1);
    });

    it('over-limit marking also settles after one write', async () => {
      await setup(10, 10);
      await listing('l1').set({
        providerId: 'p1', title: 'Réparation de fuite', categoryId: 'plomberie',
        status: 'active', communes: ['gombe'], city: 'kinshasa', photos: [],
      });
      expect(await runUntilQuiet('l1', undefined)).toEqual([true, false]);
      expect(await providerCount()).toBe(10);
    });

    it('re-delivering the same event changes nothing (no double count)', async () => {
      await setup(0, 10);
      await create('l1');
      for (let i = 0; i < 3; i++) {
        const r = await processListingWrite(db(), 'l1', undefined, (await listing('l1').get()).data());
        expect(r.wrote).toBe(false);
      }
      expect(await providerCount()).toBe(1);
    });

    it('an unchanged re-save (same fields) writes nothing', async () => {
      await setup(0, 10);
      await create('l1');
      const same = (await listing('l1').get()).data();
      const r = await processListingWrite(db(), 'l1', same, same);
      expect(r.wrote).toBe(false);
    });
  });
});
