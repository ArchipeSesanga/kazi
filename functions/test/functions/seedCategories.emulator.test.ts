// Runs against the Firestore emulator:
//   firebase emulators:exec --only firestore "npm --prefix functions test"
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { CATEGORIES, seedCategories } from '../../../shared/categories';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;

describe.skipIf(!emulator)('seedCategories (Firestore emulator)', () => {
  const db = () => getFirestore();
  const opts = { deleteField: FieldValue.delete() };
  const snapshot = async () => {
    const s = await db().collection('categories').orderBy('order').get();
    return Object.fromEntries(s.docs.map((d) => [d.id, d.data()]));
  };

  async function clear() {
    for (const c of ['categories', 'listings', 'providers']) await db().recursiveDelete(db().collection(c));
  }
  beforeEach(clear);
  afterAll(clear);

  it('writes the whole taxonomy with the documented shape', async () => {
    const r = await seedCategories(db(), opts);
    expect(r.upserted).toBe(CATEGORIES.length);
    const docs = await snapshot();
    expect(Object.keys(docs)).toHaveLength(23);
    expect(docs.plomberie).toEqual({
      names: { fr: 'Plomberie', en: 'Plumbing' }, iconKey: 'plumbing', order: 1, featured: true, active: true,
      synonyms: expect.objectContaining({ ln: [], sw: [] }), listingCount: 0,
    });
    expect(docs.plomberie.synonyms.fr).toContain('plombier');
  });

  it('is idempotent: a second and third run change nothing', async () => {
    await seedCategories(db(), opts);
    const once = await snapshot();
    await seedCategories(db(), opts);
    await seedCategories(db(), opts);
    expect(await snapshot()).toEqual(once);
  });

  it('never resets the server-managed listingCount', async () => {
    await seedCategories(db(), opts);
    await db().doc('categories/plomberie').update({ listingCount: 7 });
    await seedCategories(db(), opts);
    expect((await db().doc('categories/plomberie').get()).data()!.listingCount).toBe(7);
  });

  it('renames only display names and keeps the id; retired categories are deactivated, not deleted', async () => {
    await seedCategories(db(), opts);
    const renamed = CATEGORIES.map((c) => (c.id === 'cours' ? { ...c, names: { fr: 'Soutien', en: 'Tutoring' } } : c));
    await seedCategories(db(), { ...opts, list: renamed });
    expect((await db().doc('categories/cours').get()).data()!.names.fr).toBe('Soutien');
    const without = renamed.filter((c) => c.id !== 'photo-video');
    const r = await seedCategories(db(), { ...opts, list: without });
    expect(r.retired).toEqual(['photo-video']);
    expect((await db().doc('categories/photo-video').get()).data()!.active).toBe(false);
  });

  it('dev wipe: removes placeholder categories and legacy fields, remaps legacy ids on data', async () => {
    await db().doc('categories/coiffure_beaute').set({ name: { fr: 'x', en: 'x' }, icon: 'scissors', order: 3, active: true });
    await db().doc('categories/plomberie').set({ name: { fr: 'Plomberie', en: 'Plumbing' }, icon: 'wrench', order: 1, active: true, listingCount: 2 });
    await db().doc('listings/l1').set({ categoryId: 'coiffure_beaute' });
    await db().doc('listings/l2').set({ categoryId: 'plomberie' });
    await db().doc('providers/p1').set({ categoryIds: ['coiffure_beaute', 'mecanique_auto', 'plomberie'] });

    const r = await seedCategories(db(), { ...opts, wipeUnknown: true });
    expect(r.deleted).toEqual(['coiffure_beaute']);
    expect(r.remapped).toEqual({ providers: 1, listings: 1 });
    const docs = await snapshot();
    expect(docs.coiffure_beaute).toBeUndefined();
    expect(docs.plomberie).not.toHaveProperty('name');
    expect(docs.plomberie).not.toHaveProperty('icon');
    expect(docs.plomberie.listingCount).toBe(2);
    expect((await db().doc('listings/l1').get()).data()!.categoryId).toBe('coiffure');
    expect((await db().doc('providers/p1').get()).data()!.categoryIds).toEqual(['coiffure', 'mecanique-auto', 'plomberie']);
    // and again: nothing left to do
    expect(await seedCategories(db(), { ...opts, wipeUnknown: true })).toMatchObject({ deleted: [], remapped: { providers: 0, listings: 0 } });
  });
});
