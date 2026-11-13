/**
 * Writes (overwrites) the config/locations document per TDD §4.11.
 * Idempotent: safe to run multiple times.
 *
 * Usage: tsx seed-locations.ts --project kazi-dev|kazi-prod
 */
import { initAdmin, parseArgs, db } from './_init.js';

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
  initAdmin(projectId);
  const firestore = db();

  console.log(`Writing config/locations → ${projectId} …`);
  await firestore.collection('config').doc('locations').set(LOCATIONS);
  console.log(`✓ config/locations written (${LOCATIONS.cities[0].communes.length} communes).`);
}

main().catch((err) => { console.error(err); process.exit(1); });
