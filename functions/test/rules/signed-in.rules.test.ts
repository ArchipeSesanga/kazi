import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
} from '@firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

// signedIn() = verified phone number or the admin claim. An email/password
// account with neither is treated like a guest.
const uid = 'u1';
let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'kazi-signed-in-rules-test',
    firestore: { rules: readFileSync(resolve(process.cwd(), '../firestore.rules'), 'utf8') },
  });
});
afterAll(async () => testEnv.cleanup());

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users', uid), {
      displayName: 'Alice Mbuyi', phone: '+243810000001', locale: 'fr', city: 'kinshasa',
      termsVersion: '1', status: 'active',
    });
    await setDoc(doc(db, 'users', 'other'), {
      displayName: 'Bob', phone: '+243810000002', locale: 'fr', city: 'kinshasa',
      termsVersion: '1', status: 'active',
    });
    await setDoc(doc(db, 'users', uid, 'favorites', 'p1'), { providerId: 'p1', displayName: 'P' });
    await setDoc(doc(db, 'adminLogs', 'log1'), { action: 'x' });
    await setDoc(doc(db, 'categories', 'plomberie'), { name: 'Plomberie' });
  });
});

const phone = () => testEnv.authenticatedContext(uid, { phone_number: '+243810000001' }).firestore();
const emailOnly = () => testEnv.authenticatedContext(uid, { email: 'dev@example.com' }).firestore();
const admin = () => testEnv.authenticatedContext('admin1', { admin: true, email: 'admin@kazi.test' }).firestore();
const guest = () => testEnv.unauthenticatedContext().firestore();

const favorite = () => ({ providerId: 'p2', displayName: 'Plombier', createdAt: serverTimestamp() });

describe('email-only account (no verified phone, no admin claim)', () => {
  it('cannot read its own users doc, nor anyone else’s', async () => {
    await assertSucceeds(getDoc(doc(phone(), 'users', uid))); // control: same uid with a phone
    await assertFails(getDoc(doc(emailOnly(), 'users', uid)));
    await assertFails(getDoc(doc(emailOnly(), 'users', 'other')));
  });

  it('cannot read its subcollections', async () => {
    await assertSucceeds(getDocs(collection(phone(), 'users', uid, 'favorites')));
    await assertFails(getDocs(collection(emailOnly(), 'users', uid, 'favorites')));
  });

  it('cannot create anything the phone account can', async () => {
    await assertSucceeds(setDoc(doc(phone(), 'users', uid, 'favorites', 'p2'), favorite()));
    await assertFails(setDoc(doc(emailOnly(), 'users', uid, 'favorites', 'p2'), favorite()));
    await assertFails(
      setDoc(doc(emailOnly(), 'users', uid, 'blocks', 'x'), { createdAt: serverTimestamp() }),
    );
    await assertFails(
      setDoc(doc(emailOnly(), 'contacts', `${uid}_p1`), { userId: uid, providerId: 'p1' }),
    );
    await assertFails(
      setDoc(doc(emailOnly(), 'reports', 'r1'), { reporterId: uid, status: 'open' }),
    );
  });

  it('cannot read admin data', async () => {
    await assertFails(getDoc(doc(emailOnly(), 'adminLogs', 'log1')));
  });

  it('has no more access than a guest on public reference data', async () => {
    await assertSucceeds(getDoc(doc(guest(), 'categories', 'plomberie')));
    await assertSucceeds(getDoc(doc(emailOnly(), 'categories', 'plomberie')));
  });
});

describe('admin claim without a phone number', () => {
  it('is signed in: reads users docs and the audit log', async () => {
    await assertSucceeds(getDoc(doc(admin(), 'users', 'other')));
    await assertSucceeds(getDoc(doc(admin(), 'adminLogs', 'log1')));
  });

  it('cannot write the server-only audit log', async () => {
    await assertFails(setDoc(doc(admin(), 'adminLogs', 'log2'), { action: 'y' }));
  });
});

describe('guests and non-admin phone users', () => {
  it('guest cannot read users docs or the audit log', async () => {
    await assertFails(getDoc(doc(guest(), 'users', uid)));
    await assertFails(getDoc(doc(guest(), 'adminLogs', 'log1')));
  });

  it('a phone user is not an admin', async () => {
    await assertFails(getDoc(doc(phone(), 'adminLogs', 'log1')));
    await assertFails(getDoc(doc(phone(), 'users', 'other')));
  });
});
