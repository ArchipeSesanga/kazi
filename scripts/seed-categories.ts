/**
 * Upserts the 20 service categories defined in TDD §4.10.
 * Idempotent: sets only the static fields; preserves server-managed `listingCount`.
 *
 * Usage: tsx seed-categories.ts --project kazi-dev|kazi-prod
 */
import { FieldValue } from 'firebase-admin/firestore';
import { initAdmin, parseArgs, db } from './_init.js';

interface Category {
  id: string;
  name: { fr: string; en: string };
  icon: string;
  order: number;
  active: boolean;
}

const CATEGORIES: Category[] = [
  { id: 'plomberie',               name: { fr: 'Plomberie',                          en: 'Plumbing' },                    icon: 'wrench',          order: 1,  active: true },
  { id: 'electricite',             name: { fr: 'Électricité',                        en: 'Electrical' },                  icon: 'zap',             order: 2,  active: true },
  { id: 'coiffure_beaute',         name: { fr: 'Coiffure & beauté',                  en: 'Hair & beauty' },               icon: 'scissors',        order: 3,  active: true },
  { id: 'couture',                 name: { fr: 'Couture',                            en: 'Tailoring' },                   icon: 'shirt',           order: 4,  active: true },
  { id: 'menuiserie',              name: { fr: 'Menuiserie',                         en: 'Carpentry' },                   icon: 'hammer',          order: 5,  active: true },
  { id: 'maconnerie',              name: { fr: 'Maçonnerie & construction',          en: 'Masonry & building' },          icon: 'brick-wall',      order: 6,  active: true },
  { id: 'peinture',                name: { fr: 'Peinture',                           en: 'Painting' },                    icon: 'paint-roller',    order: 7,  active: true },
  { id: 'mecanique_auto',          name: { fr: 'Mécanique auto',                     en: 'Car mechanics' },               icon: 'car',             order: 8,  active: true },
  { id: 'reparation_telephones',   name: { fr: 'Réparation téléphones & électronique', en: 'Phone & electronics repair' }, icon: 'smartphone',     order: 9,  active: true },
  { id: 'informatique',            name: { fr: 'Informatique',                       en: 'IT services' },                 icon: 'laptop',          order: 10, active: true },
  { id: 'cours_particuliers',      name: { fr: 'Cours particuliers',                 en: 'Tutoring' },                    icon: 'graduation-cap', order: 11, active: true },
  { id: 'menage',                  name: { fr: 'Ménage & nettoyage',                 en: 'Cleaning' },                    icon: 'sparkles',        order: 12, active: true },
  { id: 'cuisine_traiteur',        name: { fr: 'Cuisine & traiteur',                 en: 'Cooking & catering' },          icon: 'chef-hat',        order: 13, active: true },
  { id: 'transport_demenagement',  name: { fr: 'Transport & déménagement',           en: 'Transport & moving' },          icon: 'truck',           order: 14, active: true },
  { id: 'evenementiel',            name: { fr: 'Événementiel',                       en: 'Events (DJ, décor, photo)' },   icon: 'party-popper',    order: 15, active: true },
  { id: 'climatisation',           name: { fr: 'Climatisation & froid',              en: 'Air-con & refrigeration' },     icon: 'snowflake',       order: 16, active: true },
  { id: 'soudure',                 name: { fr: 'Soudure',                            en: 'Welding' },                     icon: 'flame',           order: 17, active: true },
  { id: 'jardinage',               name: { fr: 'Jardinage',                          en: 'Gardening' },                   icon: 'sprout',          order: 18, active: true },
  { id: 'garde_enfants',           name: { fr: "Garde d'enfants",                   en: 'Childcare' },                   icon: 'baby',            order: 19, active: true },
  { id: 'autres',                  name: { fr: 'Autres services',                    en: 'Other services' },              icon: 'ellipsis',        order: 20, active: true },
];

async function main() {
  const { projectId } = parseArgs();
  initAdmin(projectId);
  const firestore = db();

  console.log(`Seeding ${CATEGORIES.length} categories → ${projectId} …`);

  const batch = firestore.batch();
  for (const cat of CATEGORIES) {
    const ref = firestore.collection('categories').doc(cat.id);
    // merge: preserves server-managed listingCount
    batch.set(ref, {
      name: cat.name,
      icon: cat.icon,
      order: cat.order,
      active: cat.active,
      listingCount: FieldValue.increment(0), // initialises to 0 on create, leaves existing value
    }, { merge: true });
  }
  await batch.commit();

  console.log(`✓ ${CATEGORIES.length} categories upserted.`);
}

main().catch((err) => { console.error(err); process.exit(1); });
