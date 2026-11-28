/**
 * Seeds the category taxonomy (TDD §4.10) from ONE file: assets/data/categories.json
 * (the app bundles the same file as its offline fallback).
 *
 *  - idempotent: run it as often as you like; it never resets `listingCount`;
 *  - ids are permanent slugs: edit names / synonyms freely, never an id; retire a
 *    category with `"active": false` (a category removed from the file is retired,
 *    never deleted);
 *  - DEV ONLY for now: refuses kazi-prod. In dev it also wipes the old placeholder
 *    data: placeholder categories, the `demo_*` documents of seed-demo, and
 *    remaps placeholder ids on real dev providers/listings to the new slugs; then
 *    gives every provider its server-only `ratingScore` (used by "best rated").
 *
 * Usage: npx tsx seed-categories.ts --project kazi-dev
 */
import { FieldValue } from 'firebase-admin/firestore';
import { CATEGORIES, seedCategories } from '../shared/categories.js';
import { initAdmin, parseArgs, db } from './_init.js';

const RATING_PRIOR = { mean: 4.0, weight: 5 };

async function wipeDemoData(firestore: FirebaseFirestore.Firestore): Promise<number> {
  let n = 0;
  for (const col of ['users', 'providers', 'listings', 'contacts']) {
    const snap = await firestore.collection(col).get();
    for (const d of snap.docs) {
      if (!d.id.startsWith('demo_')) continue;
      await firestore.recursiveDelete(d.ref);
      n++;
    }
  }
  return n;
}

/** Same formula as functions/src/lib/ratings.ts; the trigger keeps it right afterwards. */
async function backfillRatingScore(firestore: FirebaseFirestore.Firestore): Promise<number> {
  let n = 0;
  for (const d of (await firestore.collection('providers').get()).docs) {
    const sum = Number(d.get('ratingSum') ?? 0);
    const count = Number(d.get('ratingCount') ?? 0);
    const score = Math.round(((RATING_PRIOR.mean * RATING_PRIOR.weight + sum) / (RATING_PRIOR.weight + count)) * 10000) / 10000;
    if (d.get('ratingScore') === score) continue;
    await d.ref.update({ ratingScore: score });
    n++;
  }
  return n;
}

async function main() {
  const { projectId, isProd } = parseArgs();
  if (isProd) {
    console.error('✗  seed-categories is dev-only for now. Use --project kazi-dev.');
    process.exit(1);
  }
  initAdmin(projectId);
  const firestore = db();

  console.log(`Seeding ${CATEGORIES.length} categories → ${projectId} …`);
  const r = await seedCategories(firestore, { deleteField: FieldValue.delete(), wipeUnknown: true });
  console.log(`✓ ${r.upserted} categories upserted`);
  if (r.deleted.length) console.log(`✓ placeholder categories removed: ${r.deleted.join(', ')}`);
  if (r.remapped.providers || r.remapped.listings) {
    console.log(`✓ legacy ids remapped on ${r.remapped.providers} providers, ${r.remapped.listings} listings`);
  }
  const demo = await wipeDemoData(firestore);
  if (demo) console.log(`✓ ${demo} demo_* documents removed`);
  const scored = await backfillRatingScore(firestore);
  if (scored) console.log(`✓ ratingScore set on ${scored} providers`);
}

main().catch((err) => { console.error(err); process.exit(1); });
