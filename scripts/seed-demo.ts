/**
 * Seeds 10 fake providers, 25 listings, contacts and reviews in dev/emulator only.
 * REFUSES TO RUN AGAINST PROD.
 *
 * Usage: tsx seed-demo.ts --project kazi-dev
 */
import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { faker } from '@faker-js/faker/locale/fr';
import { initAdmin, parseArgs, db } from './_init.js';

// ── constants ────────────────────────────────────────────────────────────────

const CATEGORY_IDS = [
  'plomberie', 'electricite', 'coiffure_beaute', 'couture', 'menuiserie',
  'maconnerie', 'peinture', 'mecanique_auto', 'reparation_telephones', 'informatique',
];

const COMMUNE_IDS = [
  'gombe', 'lingwala', 'kinshasa', 'barumbu', 'kintambo',
  'lemba', 'limete', 'ngaliema', 'kalamu', 'kasa_vubu',
  'ngiri_ngiri', 'bandalungwa', 'selembao', 'bumbu', 'matete',
];

const PLACEHOLDER_AVATAR = 'https://picsum.photos/seed/SEED/200/200';
const PLACEHOLDER_PHOTO  = 'https://picsum.photos/seed/SEED/800/600';

const PRICE_TYPES = ['fixed', 'from', 'quote'] as const;
const CURRENCIES  = ['USD', 'CDF'] as const;

// ── types ────────────────────────────────────────────────────────────────────

type WriteOp = { ref: admin.firestore.DocumentReference; data: Record<string, unknown>; merge: boolean };

// ── helpers ──────────────────────────────────────────────────────────────────

function pick<T>(arr: readonly T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

function pickN<T>(arr: T[], n: number): T[] {
  const copy = [...arr];
  copy.sort(() => Math.random() - 0.5);
  return copy.slice(0, n);
}

function daysAgo(n: number): Timestamp {
  return Timestamp.fromDate(new Date(Date.now() - n * 86_400_000));
}

function providerId(i: number): string {
  return `demo_provider_${String(i).padStart(2, '0')}`;
}

function userId(i: number): string {
  return `demo_user_${String(i).padStart(2, '0')}`;
}

function avatar(seed: string): string {
  return PLACEHOLDER_AVATAR.replace('SEED', seed);
}

function photo(seed: string): string {
  return PLACEHOLDER_PHOTO.replace('SEED', seed);
}

// ── builders ─────────────────────────────────────────────────────────────────

function buildUser(i: number) {
  return {
    uid: userId(i),
    displayName: faker.person.fullName(),
    phoneNumber: `+2438${faker.string.numeric(8)}`,
    photoURL: null,
    commune: pick(COMMUNE_IDS),
    termsVersion: '2026-11',
    termsAcceptedAt: daysAgo(faker.number.int({ min: 30, max: 180 })),
    status: 'active',
    isProvider: false,
    createdAt: daysAgo(faker.number.int({ min: 30, max: 180 })),
  };
}

function buildProvider(i: number) {
  const uid = providerId(i);
  const categoryIds = pickN(CATEGORY_IDS, faker.number.int({ min: 1, max: 3 }));
  const communes = pickN(COMMUNE_IDS, faker.number.int({ min: 2, max: 6 }));
  const baseCommune = communes[0];
  const seed = `provider${i}`;

  return {
    uid,
    displayName: faker.person.fullName(),
    phoneNumber: `+2438${faker.string.numeric(8)}`,
    photoURL: avatar(seed),
    commune: baseCommune,
    termsVersion: '2026-11',
    termsAcceptedAt: daysAgo(faker.number.int({ min: 60, max: 365 })),
    status: 'active',
    isProvider: true,
    createdAt: daysAgo(faker.number.int({ min: 60, max: 365 })),
    providerName: faker.company.name(),
    bio: faker.lorem.sentences(2),
    categoryIds,
    baseCommune,
    communes,
    publicPhone: `+2438${faker.string.numeric(8)}`,
    publicPhoneConsent: true,
    coverURL: photo(`${seed}_cover`),
    providerStatus: 'approved',
    verified: false,
    ratingAvg: parseFloat(faker.number.float({ min: 3.5, max: 5.0, fractionDigits: 1 }).toFixed(1)),
    ratingCount: faker.number.int({ min: 1, max: 40 }),
    listingCount: 0,
    contactCount: faker.number.int({ min: 0, max: 200 }),
    createdProviderAt: daysAgo(faker.number.int({ min: 60, max: 365 })),
  };
}

function buildListing(
  listingIdx: number,
  provider: ReturnType<typeof buildProvider>,
) {
  const id = `demo_listing_${String(listingIdx).padStart(2, '0')}`;
  const categoryId = pick(provider.categoryIds);
  const priceType = pick(PRICE_TYPES);
  const currency = pick(CURRENCIES);
  const photoCount = faker.number.int({ min: 1, max: 4 });

  return {
    id,
    providerUid: provider.uid,
    providerName: provider.providerName,
    categoryId,
    title: faker.commerce.productName(),
    description: faker.lorem.paragraph(),
    priceType,
    amount: priceType !== 'quote'
      ? faker.number.int({ min: 5, max: 500 }) * (currency === 'USD' ? 1 : 2000)
      : null,
    currency,
    communes: provider.communes,
    photos: Array.from({ length: photoCount }, (_, k) =>
      photo(`listing${listingIdx}_${k}`)),
    visible: true,
    status: 'active',
    publishedAt: daysAgo(faker.number.int({ min: 1, max: 60 })),
    createdAt: daysAgo(faker.number.int({ min: 1, max: 90 })),
  };
}

function buildContact(userIdx: number, providerIdx: number) {
  const uid = userId(userIdx);
  const pid = providerId(providerIdx);
  return {
    id: `${uid}_${pid}`,
    uid,
    providerUid: pid,
    channel: pick(['whatsapp', 'phone'] as const),
    listingId: null,
    lastAt: daysAgo(faker.number.int({ min: 0, max: 30 })),
    createdAt: daysAgo(faker.number.int({ min: 1, max: 60 })),
  };
}

function buildReview(userIdx: number, providerIdx: number) {
  const uid = userId(userIdx);
  const pid = providerId(providerIdx);
  return {
    id: uid, // per rules: rid = auth.uid
    reviewerUid: uid,
    providerUid: pid,
    rating: faker.number.int({ min: 3, max: 5 }),
    text: faker.lorem.sentences(faker.number.int({ min: 1, max: 3 })),
    reply: null,
    createdAt: daysAgo(faker.number.int({ min: 1, max: 90 })),
  };
}

// ── batch writer ─────────────────────────────────────────────────────────────

async function commitInChunks(firestore: admin.firestore.Firestore, ops: WriteOp[]): Promise<number> {
  const CHUNK = 400;
  let batchCount = 0;
  for (let i = 0; i < ops.length; i += CHUNK) {
    const chunk = ops.slice(i, i + CHUNK);
    const batch = firestore.batch();
    for (const op of chunk) {
      batch.set(op.ref, op.data, { merge: op.merge });
    }
    await batch.commit();
    batchCount++;
  }
  return batchCount;
}

// ── main ──────────────────────────────────────────────────────────────────────

async function main() {
  const { projectId, isProd } = parseArgs();

  if (isProd) {
    console.error('✗  seed-demo REFUSES to run against prod. Use --project kazi-dev.');
    process.exit(1);
  }

  initAdmin(projectId);
  const firestore = db();

  console.log(`Seeding demo data → ${projectId} …`);

  const providers = Array.from({ length: 10 }, (_, i) => buildProvider(i + 1));
  const users     = Array.from({ length: 10 }, (_, i) => buildUser(i + 1));

  const listings: ReturnType<typeof buildListing>[] = [];
  for (let i = 0; i < 25; i++) {
    listings.push(buildListing(i + 1, providers[i % providers.length]));
  }

  const listingCounts: Record<string, number> = {};
  for (const l of listings) {
    listingCounts[l.providerUid] = (listingCounts[l.providerUid] ?? 0) + 1;
  }

  const contacts = users.flatMap((_, ui) => [
    buildContact(ui + 1, (ui % 10) + 1),
    buildContact(ui + 1, ((ui + 1) % 10) + 1),
  ]);

  const reviews = Array.from({ length: 10 }, (_, i) =>
    buildReview(i + 1, (i % 10) + 1));

  const ops: WriteOp[] = [];

  for (const u of users) {
    const { uid, ...data } = u;
    ops.push({ ref: firestore.collection('users').doc(uid), data, merge: true });
  }

  for (const p of providers) {
    const { uid, ...data } = p;
    ops.push({ ref: firestore.collection('users').doc(uid), data: { ...data, isProvider: true }, merge: true });
    ops.push({ ref: firestore.collection('providers').doc(uid), data: { ...data, listingCount: listingCounts[uid] ?? 0 }, merge: true });
  }

  for (const l of listings) {
    const { id, ...data } = l;
    ops.push({ ref: firestore.collection('listings').doc(id), data, merge: true });
  }

  for (const c of contacts) {
    const { id, ...data } = c;
    ops.push({ ref: firestore.collection('contacts').doc(id), data, merge: true });
  }

  for (const r of reviews) {
    const { id, ...data } = r;
    ops.push({
      ref: firestore.collection('providers').doc(r.providerUid).collection('reviews').doc(id),
      data,
      merge: true,
    });
  }

  const batchCount = await commitInChunks(firestore, ops);

  console.log(
    `✓ Demo seed complete (${batchCount} batch(es)):\n` +
    `  · ${users.length} users\n` +
    `  · ${providers.length} providers\n` +
    `  · ${listings.length} listings\n` +
    `  · ${contacts.length} contacts\n` +
    `  · ${reviews.length} reviews`,
  );
}

main().catch((err) => { console.error(err); process.exit(1); });
