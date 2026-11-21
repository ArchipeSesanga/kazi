/**
 * Seeds categories + locations + moderation + limits config using the Firestore
 * REST API. Works with Firebase CLI credentials (no gcloud / ADC needed).
 *
 * Usage: npx tsx seed-rest.ts --project kazi-dev
 */
import { parseArgs, restBatchWrite, restSetDocument } from './_init.js';

const CATEGORIES = [
  { id: 'plomberie',               name: { fr: 'Plomberie',                          en: 'Plumbing' },                    icon: 'wrench',          order: 1,  active: true, listingCount: 0 },
  { id: 'electricite',             name: { fr: 'Électricité',                        en: 'Electrical' },                  icon: 'zap',             order: 2,  active: true, listingCount: 0 },
  { id: 'coiffure_beaute',         name: { fr: 'Coiffure & beauté',                  en: 'Hair & beauty' },               icon: 'scissors',        order: 3,  active: true, listingCount: 0 },
  { id: 'couture',                 name: { fr: 'Couture',                            en: 'Tailoring' },                   icon: 'shirt',           order: 4,  active: true, listingCount: 0 },
  { id: 'menuiserie',              name: { fr: 'Menuiserie',                         en: 'Carpentry' },                   icon: 'hammer',          order: 5,  active: true, listingCount: 0 },
  { id: 'maconnerie',              name: { fr: 'Maçonnerie & construction',          en: 'Masonry & building' },          icon: 'brick-wall',      order: 6,  active: true, listingCount: 0 },
  { id: 'peinture',                name: { fr: 'Peinture',                           en: 'Painting' },                    icon: 'paint-roller',    order: 7,  active: true, listingCount: 0 },
  { id: 'mecanique_auto',          name: { fr: 'Mécanique auto',                     en: 'Car mechanics' },               icon: 'car',             order: 8,  active: true, listingCount: 0 },
  { id: 'reparation_telephones',   name: { fr: 'Réparation téléphones & électronique', en: 'Phone & electronics repair' }, icon: 'smartphone',     order: 9,  active: true, listingCount: 0 },
  { id: 'informatique',            name: { fr: 'Informatique',                       en: 'IT services' },                 icon: 'laptop',          order: 10, active: true, listingCount: 0 },
  { id: 'cours_particuliers',      name: { fr: 'Cours particuliers',                 en: 'Tutoring' },                    icon: 'graduation-cap', order: 11, active: true, listingCount: 0 },
  { id: 'menage',                  name: { fr: 'Ménage & nettoyage',                 en: 'Cleaning' },                    icon: 'sparkles',        order: 12, active: true, listingCount: 0 },
  { id: 'cuisine_traiteur',        name: { fr: 'Cuisine & traiteur',                 en: 'Cooking & catering' },          icon: 'chef-hat',        order: 13, active: true, listingCount: 0 },
  { id: 'transport_demenagement',  name: { fr: 'Transport & déménagement',           en: 'Transport & moving' },          icon: 'truck',           order: 14, active: true, listingCount: 0 },
  { id: 'evenementiel',            name: { fr: 'Événementiel',                       en: 'Events (DJ, décor, photo)' },   icon: 'party-popper',    order: 15, active: true, listingCount: 0 },
  { id: 'climatisation',           name: { fr: 'Climatisation & froid',              en: 'Air-con & refrigeration' },     icon: 'snowflake',       order: 16, active: true, listingCount: 0 },
  { id: 'soudure',                 name: { fr: 'Soudure',                            en: 'Welding' },                     icon: 'flame',           order: 17, active: true, listingCount: 0 },
  { id: 'jardinage',               name: { fr: 'Jardinage',                          en: 'Gardening' },                   icon: 'sprout',          order: 18, active: true, listingCount: 0 },
  { id: 'garde_enfants',           name: { fr: "Garde d'enfants",                   en: 'Childcare' },                   icon: 'baby',            order: 19, active: true, listingCount: 0 },
  { id: 'autres',                  name: { fr: 'Autres services',                    en: 'Other services' },              icon: 'ellipsis',        order: 20, active: true, listingCount: 0 },
];

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

  // 1. Seed categories
  console.log(`Seeding ${CATEGORIES.length} categories → ${projectId} …`);
  const writes = CATEGORIES.map((cat) => ({
    collection: 'categories',
    docId: cat.id,
    data: {
      name: cat.name,
      icon: cat.icon,
      order: cat.order,
      active: cat.active,
      listingCount: cat.listingCount,
    } as Record<string, unknown>,
  }));
  await restBatchWrite(projectId, writes);
  console.log(`✓ ${CATEGORIES.length} categories upserted.`);

  // 2. Seed locations
  console.log(`Seeding locations → ${projectId} …`);
  await restSetDocument(projectId, 'config/locations', LOCATIONS as unknown as Record<string, unknown>);
  console.log(`✓ config/locations written (${LOCATIONS.cities[0].communes.length} communes).`);

  // 3. Seed moderation config (v1: providers are auto-approved, no admin panel yet)
  console.log(`Seeding moderation config → ${projectId} …`);
  await restSetDocument(projectId, 'config/moderation', { autoApproveProviders: true });
  console.log('✓ config/moderation written (autoApproveProviders=true).');

  // 4. Seed listing limit (single source for rules, app and functions; TDD §4.11a)
  console.log(`Seeding limits config → ${projectId} …`);
  await restSetDocument(projectId, 'config/limits', { maxListingsPerProvider: 10 });
  console.log('✓ config/limits written (maxListingsPerProvider=10).');
}

main().catch((err) => { console.error(err); process.exit(1); });
