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

const uid = 'u1';
const URL = 'https://firebasestorage.googleapis.com/v0/b/kazi/o/media%2Fu1%2Favatar%2Fa.jpg?alt=media&token=t';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-profile-photo-rules-test',
    firestore: { rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', uid), {
      displayName: 'Alice Mbuyi', phone: '', locale: 'fr', city: 'kinshasa',
      termsVersion: '1', status: 'active',
    });
    await setDoc(doc(db, 'providers', uid), {
      displayName: 'Alice Plomberie', categoryIds: ['plomberie'], city: 'kinshasa',
      baseCommune: 'gombe', communes: ['gombe'], whatsappNumber: '+243810000000',
      yearsExperience: 2, portfolio: [], status: 'approved', verified: false,
      ratingAvg: 0, ratingCount: 0, ratingSum: 0, listingCount: 0,
    });
  });
});

const db = (id = uid) => testEnv.authenticatedContext(id).firestore();

describe('profile picture — users/{uid}.photoUrl', () => {
  it('owner can set the picture', async () => {
    await assertSucceeds(updateDoc(doc(db(), 'users', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
  });

  it('owner can clear the picture (null)', async () => {
    await assertSucceeds(updateDoc(doc(db(), 'users', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(db(), 'users', uid), { photoUrl: null, updatedAt: serverTimestamp() }));
  });

  it('owner can change name, commune and picture together', async () => {
    await assertSucceeds(updateDoc(doc(db(), 'users', uid), {
      displayName: 'Alice Kabila', commune: 'gombe', photoUrl: URL, updatedAt: serverTimestamp(),
    }));
  });

  it('denies a too-short picture URL', async () => {
    await assertFails(updateDoc(doc(db(), 'users', uid), { photoUrl: 'x', updatedAt: serverTimestamp() }));
  });

  it('denies another user changing the picture', async () => {
    await assertFails(updateDoc(doc(db('other'), 'users', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
  });
});

describe('profile picture — providers/{uid}.photoUrl', () => {
  it('owner can set and clear the picture', async () => {
    await assertSucceeds(updateDoc(doc(db(), 'providers', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(db(), 'providers', uid), { photoUrl: null, updatedAt: serverTimestamp() }));
  });

  it('cannot smuggle a status change along with the picture', async () => {
    await assertFails(updateDoc(doc(db(), 'providers', uid), {
      photoUrl: URL, status: 'pending', updatedAt: serverTimestamp(),
    }));
  });

  it('a suspended provider cannot change the picture', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await updateDoc(doc(ctx.firestore(), 'providers', uid), { status: 'suspended' });
    });
    await assertFails(updateDoc(doc(db(), 'providers', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
  });

  it('another user cannot change the picture', async () => {
    await assertFails(updateDoc(doc(db('other'), 'providers', uid), { photoUrl: URL, updatedAt: serverTimestamp() }));
  });
});
