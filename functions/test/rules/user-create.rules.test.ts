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

// Firebase "test phone numbers": no real SMS is involved.
const PHONE = '+243810000001';
const uid = 'phone-user';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-user-create-rules-test',
    firestore: { rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());
beforeEach(async () => testEnv.clearFirestore());

const phoneUser = () =>
  testEnv.authenticatedContext(uid, { phone_number: PHONE }).firestore();
const emailUser = () =>
  testEnv.authenticatedContext(uid, { email: 'dev@example.com' }).firestore();

// Mirrors AppUser.toCreateMap().
const payload = (over: Record<string, unknown> = {}) => ({
  displayName: 'Alice Mbuyi',
  phone: PHONE,
  locale: 'fr',
  city: 'kinshasa',
  termsVersion: '1',
  termsAcceptedAt: serverTimestamp(),
  status: 'active',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...over,
});

describe('users/{uid} create — phone is the identity', () => {
  it('allows the create payload when phone matches the verified number', async () => {
    await assertSucceeds(setDoc(doc(phoneUser(), 'users', uid), payload()));
  });

  it('allows an optional email', async () => {
    await assertSucceeds(
      setDoc(doc(phoneUser(), 'users', uid), payload({ email: 'alice@example.com' })),
    );
  });

  it('denies a phone different from the verified number', async () => {
    await assertFails(
      setDoc(doc(phoneUser(), 'users', uid), payload({ phone: '+243810000002' })),
    );
  });

  it('denies an empty phone for a phone-verified account', async () => {
    await assertFails(setDoc(doc(phoneUser(), 'users', uid), payload({ phone: '' })));
  });

  it('denies an email/password account (no verified phone)', async () => {
    await assertFails(setDoc(doc(emailUser(), 'users', uid), payload({ phone: '' })));
    await assertFails(setDoc(doc(emailUser(), 'users', uid), payload()));
  });

  it('denies an invalid email value', async () => {
    await assertFails(setDoc(doc(phoneUser(), 'users', uid), payload({ email: 'a' })));
  });

  it('denies creating another user’s document', async () => {
    await assertFails(setDoc(doc(phoneUser(), 'users', 'someone-else'), payload()));
  });
});

describe('users/{uid} update', () => {
  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users', uid), {
        displayName: 'Alice Mbuyi', phone: PHONE, locale: 'fr', city: 'kinshasa',
        termsVersion: '1', status: 'active',
      });
    });
  });

  it('owner can set and change the optional email', async () => {
    await assertSucceeds(
      updateDoc(doc(phoneUser(), 'users', uid), { email: 'a@b.cd', updatedAt: serverTimestamp() }),
    );
  });

  it('owner cannot change the phone to a number they have not verified', async () => {
    await assertFails(
      updateDoc(doc(phoneUser(), 'users', uid), { phone: '+243810000009', updatedAt: serverTimestamp() }),
    );
  });
});
