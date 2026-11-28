import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc } from '@firebase/firestore';
import { afterAll, beforeAll, describe, it } from 'vitest';

const uid = 'provider-uid';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-provider-create-rules-test',
    firestore: {
      rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

describe('providers/{uid} create contract', () => {
  it('allows the exact create payload emitted by ProviderProfile.toCreateMap', async () => {
    await seedActiveUser();
    const db = testEnv.authenticatedContext(uid, { phone_number: '+243810000001' }).firestore();

    await assertSucceeds(
      setDoc(doc(db, 'providers', uid), providerCreatePayload()),
    );
  });

  it('rejects extra keys on the provider create payload', async () => {
    await seedActiveUser();
    const db = testEnv.authenticatedContext(uid, { phone_number: '+243810000001' }).firestore();

    await assertFails(
      setDoc(doc(db, 'providers', uid), {
        ...providerCreatePayload(),
        unexpectedFromToJson: true,
      }),
    );
  });
});

async function seedActiveUser(): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', uid), { status: 'active' });
  });
}

function providerCreatePayload() {
  // Mirrors every entry of ProviderProfile.toCreateMap, including nullable keys.
  return {
    displayName: 'Jean Mukendi',
    bio: 'Plombier depuis 8 ans',
    photoUrl:
      'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/avatar.jpg?alt=media&token=test',
    coverUrl:
      'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/cover.jpg?alt=media&token=test',
    categoryIds: ['plomberie'],
    city: 'kinshasa',
    baseCommune: 'gombe',
    communes: ['gombe', 'lingwala'],
    whatsappNumber: '+243812345678',
    callNumber: null,
    yearsExperience: 8,
    portfolio: [],
    status: 'pending',
    verified: false,
    ratingAvg: 0,
    ratingCount: 0,
    ratingSum: 0,
    listingCount: 0,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}
