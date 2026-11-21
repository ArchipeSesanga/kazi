import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, updateDoc } from '@firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

const uid = 'provider-uid';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-listing-limit-rules-test',
    firestore: {
      rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

async function seed(opts: { listingCount: number; max?: number; status?: string }) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'providers', uid), {
      status: opts.status ?? 'approved',
      listingCount: opts.listingCount,
    });
    if (opts.max !== undefined) {
      await setDoc(doc(db, 'config', 'limits'), { maxListingsPerProvider: opts.max });
    }
  });
}

function listingPayload() {
  return {
    providerId: uid,
    title: 'Plomberie rapide',
    description: '',
    categoryId: 'plomberie',
    priceType: 'quote',
    currency: 'USD',
    photos: [],
    city: 'kinshasa',
    communes: ['gombe'],
    status: 'draft',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

const create = (id = 'l1') =>
  setDoc(
    doc(testEnv.authenticatedContext(uid, { phone_number: '+243810000001' }).firestore(), 'listings', id),
    listingPayload(),
  );

describe('listings create — configurable limit (config/limits)', () => {
  it('allows creating at listingCount 9 with max 10', async () => {
    await seed({ listingCount: 9, max: 10 });
    await assertSucceeds(create());
  });

  it('denies creating at listingCount 10 with max 10', async () => {
    await seed({ listingCount: 10, max: 10 });
    await assertFails(create());
  });

  it('follows the configured value: allowed at 10 when max is raised to 25', async () => {
    await seed({ listingCount: 10, max: 25 });
    await assertSucceeds(create());
  });

  it('follows the configured value: denied at 3 when max is lowered to 3', async () => {
    await seed({ listingCount: 3, max: 3 });
    await assertFails(create());
  });

  it('falls back to 10 while config/limits does not exist', async () => {
    await seed({ listingCount: 9 });
    await assertSucceeds(create());
    await seed({ listingCount: 10 });
    await assertFails(create());
  });

  it('still denies a suspended provider even under the limit', async () => {
    await seed({ listingCount: 0, max: 10, status: 'suspended' });
    await assertFails(create());
  });

  it('does not let a client write config/limits', async () => {
    await seed({ listingCount: 0, max: 10 });
    const db = testEnv.authenticatedContext(uid, { phone_number: '+243810000001' }).firestore();
    await assertFails(
      updateDoc(doc(db, 'config', 'limits'), { maxListingsPerProvider: 1000 }),
    );
  });
});
