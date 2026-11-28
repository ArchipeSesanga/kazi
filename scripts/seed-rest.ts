/**
 * Seeds locations + moderation + limits config using the Firestore REST API.
 * Works with Firebase CLI credentials (no gcloud / ADC needed).
 * Categories are seeded by `seed-categories.ts` (merge-safe: it keeps `listingCount`).
 *
 * Usage: npx tsx seed-rest.ts --project kazi-dev
 */
import { parseArgs, restBatchWrite, restSetDocument } from './_init.js';

const LOCATIONS = {
  cities: [
    {
      id: 'kinshasa',
      name: 'Kinshasa',
      active: true,
      communes: [
        { id: 'bandalungwa',  name: 'Bandalungwa' },
        { id: 'barumbu',      name: 'Barumbu' },
        { id: 'bumbu',        name: 'Bumbu' },
        { id: 'gombe',        name: 'Gombe' },
        { id: 'kalamu',       name: 'Kalamu' },
        { id: 'kasa_vubu',    name: 'Kasa-Vubu' },
        { id: 'kimbanseke',   name: 'Kimbanseke' },
        { id: 'kinshasa',     name: 'Kinshasa' },
        { id: 'kintambo',     name: 'Kintambo' },
        { id: 'kisenso',      name: 'Kisenso' },
        { id: 'lemba',        name: 'Lemba' },
        { id: 'limete',       name: 'Limete' },
        { id: 'lingwala',     name: 'Lingwala' },
        { id: 'makala',       name: 'Makala' },
        { id: 'maluku',       name: 'Maluku' },
        { id: 'masina',       name: 'Masina' },
        { id: 'matete',       name: 'Matete' },
        { id: 'mont_ngafula', name: 'Mont-Ngafula' },
        { id: 'ndjili',       name: "N'djili" },
        { id: 'ngaba',        name: 'Ngaba' },
        { id: 'ngaliema',     name: 'Ngaliema' },
        { id: 'ngiri_ngiri',  name: 'Ngiri-Ngiri' },
        { id: 'nsele',        name: 'Nsele' },
        { id: 'selembao',     name: 'Selembao' },
      ],
    },
  ],
};

async function main() {
  const { projectId } = parseArgs();

  // 1. Seed locations
  console.log(`Seeding locations → ${projectId} …`);
  await restSetDocument(projectId, 'config/locations', LOCATIONS as unknown as Record<string, unknown>);
  console.log(`✓ config/locations written (${LOCATIONS.cities[0].communes.length} communes).`);

  // 2. Seed moderation config (v1: providers are auto-approved, no admin panel yet)
  console.log(`Seeding moderation config → ${projectId} …`);
  await restSetDocument(projectId, 'config/moderation', { autoApproveProviders: true });
  console.log('✓ config/moderation written (autoApproveProviders=true).');

  // 3. Seed listing limit (single source for rules, app and functions; TDD §4.11a)
  console.log(`Seeding limits config → ${projectId} …`);
  await restSetDocument(projectId, 'config/limits', { maxListingsPerProvider: 10 });
  console.log('✓ config/limits written (maxListingsPerProvider=10).');
}

main().catch((err) => { console.error(err); process.exit(1); });
