// Runs against the Firestore emulator (see reconcile.emulator.test.ts).
import { getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import {
  authoriseOperator,
  findAccount,
  normalisePhone,
  OperatorError,
  operatorDeleteAccount,
  planDeletion,
  validateReason,
  type AccountLookup,
} from '../../src/lib/operatorDelete';
import type { DeleteAccountDeps } from '../../src/lib/deleteAccount';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;
const PHONE = '+243810000001';
const UID = 'u1';

async function code(p: Promise<unknown>): Promise<string> {
  try {
    await p;
  } catch (e) {
    return e instanceof OperatorError ? e.code : `other:${(e as Error).message}`;
  }
  return 'ok';
}

describe('normalisePhone / validateReason', () => {
  it('normalises spaces and rejects non-E.164', () => {
    expect(normalisePhone('+243 81 000 0001')).toBe(PHONE);
    expect(normalisePhone('+243-81-000-0001')).toBe(PHONE);
    for (const bad of ['0810000001', '243810000001', '+0123', '+12', 'abc', '']) {
      expect(normalisePhone(bad)).toBeNull();
    }
  });

  it('the reason is a short reference without personal data', () => {
    expect(validateReason('  ticket-123 ')).toBe('ticket-123');
    for (const bad of ['', 'ab', 'x'.repeat(201), 'call +243810000001', 'mail me@x.cd', 'tel 0810000001']) {
      expect(() => validateReason(bad)).toThrow(OperatorError);
    }
  });
});

describe.skipIf(!emulator)('operator account deletion (Firestore emulator)', () => {
  const db = () => getFirestore();
  const exists = async (path: string) => (await db().doc(path).get()).exists;

  async function clear() {
    for (const c of ['users', 'providers', 'listings', 'contacts', 'reports', 'reportQuota', 'verificationRequests', 'adminLogs']) {
      await db().recursiveDelete(db().collection(c));
    }
  }

  const lookup = (over: Partial<{ phones: Record<string, string>; staff: Record<string, { uid: string; claims: Record<string, unknown> }> }> = {}): AccountLookup => ({
    userByPhone: async (p) => (over.phones ?? { [PHONE]: UID })[p] ? { uid: (over.phones ?? { [PHONE]: UID })[p] } : null,
    userByEmail: async (e) => (over.staff ?? { 'mod@kazi.test': { uid: 'mod1', claims: { moderator: true } } })[e] ?? null,
  });

  const deps = () => {
    const calls = { prefixes: [] as string[], auth: [] as string[], failAuth: false };
    const d: DeleteAccountDeps = {
      deleteStoragePrefix: async (p) => void calls.prefixes.push(p),
      deleteAuthUser: async (id) => {
        if (calls.failAuth) {
          calls.failAuth = false;
          throw new Error('auth unavailable');
        }
        calls.auth.push(id);
      },
    };
    return { d, calls };
  };

  const opts = (over: Record<string, unknown> = {}) => ({
    phone: PHONE, operatorEmail: 'mod@kazi.test', reason: 'ticket-42', execute: false, ...over,
  });

  beforeEach(async () => {
    await clear();
    const d = db();
    await d.doc(`users/${UID}`).set({ displayName: 'Alice', phone: PHONE, status: 'active' });
    await d.doc(`providers/${UID}`).set({ displayName: 'Alice P', status: 'approved' });
    await d.doc('listings/l1').set({ providerId: UID, status: 'active' });
    await d.doc('listings/l2').set({ providerId: UID, status: 'draft' });
    await d.doc('providers/p9/reviews/u1').set({ authorUid: UID, rating: 4 });
    await d.doc(`reports/${UID}_provider_p9`).set({ reporterUid: UID, status: 'open' });
    await d.doc(`contacts/${UID}_p9`).set({ clientUid: UID, providerId: 'p9' });
    await d.doc(`contacts/bob_${UID}`).set({ clientUid: 'bob', providerId: UID });
    await d.doc(`users/bob/favorites/${UID}`).set({ providerId: UID });
    await d.doc(`reportQuota/${UID}`).set({ windowStart: 1, count: 1 });
    await d.doc('users/bob').set({ displayName: 'Bob', phone: '+243810000002' });
  });
  afterAll(clear);

  describe('staff only', () => {
    it('accepts an admin or a moderator', async () => {
      const staff = { 'a@kazi.test': { uid: 'a1', claims: { admin: true } }, 'mod@kazi.test': { uid: 'mod1', claims: { moderator: true } } };
      expect(await authoriseOperator(lookup({ staff }), 'a@kazi.test')).toEqual({ uid: 'a1' });
      expect(await authoriseOperator(lookup({ staff }), 'mod@kazi.test')).toEqual({ uid: 'mod1' });
    });

    it('rejects an ordinary user, an unknown email and falsy claims', async () => {
      const staff = { 'user@x.cd': { uid: 'u9', claims: { phone_number: PHONE } }, 'f@x.cd': { uid: 'f1', claims: { admin: false, moderator: 'yes' } } };
      expect(await code(authoriseOperator(lookup({ staff }), 'user@x.cd'))).toBe('operator-not-staff');
      expect(await code(authoriseOperator(lookup({ staff }), 'f@x.cd'))).toBe('operator-not-staff');
      expect(await code(authoriseOperator(lookup({ staff }), 'nobody@x.cd'))).toBe('operator-not-found');
    });

    it('a non-staff operator cannot even dry-run, and nothing changes', async () => {
      const staff = { 'user@x.cd': { uid: 'u9', claims: {} } };
      const { d } = deps();
      expect(await code(operatorDeleteAccount(db(), lookup({ staff }), d, opts({ operatorEmail: 'user@x.cd', execute: true })))).toBe('operator-not-staff');
      expect(await exists(`users/${UID}`)).toBe(true);
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });
  });

  describe('finding the account by phone number', () => {
    it('uses the Auth user first', async () => {
      expect(await findAccount(db(), lookup(), PHONE)).toEqual({ uid: UID, via: 'auth' });
    });

    it('falls back to the profile when the Auth user is already gone (earlier partial deletion)', async () => {
      expect(await findAccount(db(), lookup({ phones: {} }), PHONE)).toEqual({ uid: UID, via: 'profile' });
    });

    it('reports an unknown number and an ambiguous one', async () => {
      expect(await code(findAccount(db(), lookup({ phones: {} }), '+243819999999'))).toBe('account-not-found');
      await db().doc('users/dup').set({ displayName: 'Dup', phone: PHONE });
      expect(await code(findAccount(db(), lookup({ phones: {} }), PHONE))).toBe('ambiguous-account');
    });
  });

  it('planDeletion counts what would be touched and writes nothing', async () => {
    const plan = await planDeletion(db(), UID, async (prefix) => (prefix.startsWith('media/') ? 7 : 0));
    expect(plan).toMatchObject({
      userProfile: true, providerProfile: true, listings: 2, reviewsToAnonymise: 1,
      reportsToAnonymise: 1, contactsAsClient: 1, contactsAsProvider: 1, favouritesOfProvider: 1,
      verificationRequest: false, reportQuota: true,
      storageFiles: { [`media/${UID}/`]: 7, [`private/verification/${UID}/`]: 0 },
    });
  });

  describe('dry run (the default)', () => {
    it('returns the plan and changes nothing, not even a log', async () => {
      const { d, calls } = deps();
      const r = await operatorDeleteAccount(db(), lookup(), d, opts());
      expect(r).toMatchObject({ uid: UID, via: 'auth', dryRun: true });
      expect(r.report).toBeUndefined();
      expect(r.plan.listings).toBe(2);
      expect(calls.prefixes).toEqual([]);
      expect(calls.auth).toEqual([]);
      for (const p of [`users/${UID}`, `providers/${UID}`, 'listings/l1', `contacts/${UID}_p9`, 'providers/p9/reviews/u1']) {
        expect(await exists(p)).toBe(true);
      }
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });
  });

  describe('execute', () => {
    it('runs the same deletion as the app and writes an audit entry without the phone number', async () => {
      const { d, calls } = deps();
      const r = await operatorDeleteAccount(db(), lookup(), d, opts({ execute: true }));
      expect(r.dryRun).toBe(false);
      expect(r.report).toMatchObject({ listingsDeleted: 2, reviewsAnonymised: 1, reportsAnonymised: 1, contactsDeleted: 2, favoritesOfProviderDeleted: 1 });

      for (const p of [`users/${UID}`, `providers/${UID}`, 'listings/l1', `contacts/${UID}_p9`, `contacts/bob_${UID}`, `users/bob/favorites/${UID}`, `reportQuota/${UID}`, 'providers/p9/reviews/u1']) {
        expect(await exists(p)).toBe(false);
      }
      expect(await exists('users/bob')).toBe(true);
      expect(calls.prefixes).toEqual([`media/${UID}/`, `private/verification/${UID}/`]);
      expect(calls.auth).toEqual([UID]);

      const logs = await db().collection('adminLogs').get();
      expect(logs.size).toBe(1);
      const log = logs.docs[0].data();
      expect(log).toMatchObject({ actorUid: 'mod1', action: 'operator_delete_account', targetType: 'user', targetId: UID, note: 'ticket-42' });
      expect(JSON.stringify(log)).not.toContain(PHONE);
      expect(JSON.stringify(log)).not.toContain('Alice');
    });

    it('a failure is logged, rethrown, and a second run finishes the job', async () => {
      const first = deps();
      first.calls.failAuth = true;
      await expect(operatorDeleteAccount(db(), lookup(), first.d, opts({ execute: true }))).rejects.toThrow('auth unavailable');
      let logs = (await db().collection('adminLogs').get()).docs.map((x) => x.data());
      expect(logs).toHaveLength(1);
      expect(logs[0]).toMatchObject({ action: 'operator_delete_account_failed', targetId: UID });
      expect(String(logs[0].note)).toContain('auth unavailable');

      // The Auth user is still there, so the phone lookup still works.
      const second = deps();
      await operatorDeleteAccount(db(), lookup(), second.d, opts({ execute: true }));
      expect(second.calls.auth).toEqual([UID]);
      logs = (await db().collection('adminLogs').get()).docs.map((x) => x.data());
      expect(logs.map((l) => l.action).sort()).toEqual(['operator_delete_account', 'operator_delete_account_failed']);
    });

    it('rejects a bad phone number or reason before touching anything', async () => {
      const { d } = deps();
      expect(await code(operatorDeleteAccount(db(), lookup(), d, opts({ phone: '0810000001', execute: true })))).toBe('invalid-phone');
      expect(await code(operatorDeleteAccount(db(), lookup(), d, opts({ reason: 'for +243810000001', execute: true })))).toBe('invalid-reason');
      expect(await exists(`users/${UID}`)).toBe(true);
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });

    it('an unknown number does nothing', async () => {
      const { d } = deps();
      expect(await code(operatorDeleteAccount(db(), lookup({ phones: {} }), d, opts({ phone: '+243819999999', execute: true })))).toBe('account-not-found');
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });
  });
});
