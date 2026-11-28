// Runs against the Firestore emulator (see reconcile.emulator.test.ts).
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import '../../src/lib/firebaseAdmin';
import { REPORTS_PER_DAY, REPORT_WINDOW_MS } from '../../src/config';
import { AUTO_REPORTS_REASON, applyAutoHide } from '../../src/lib/autoHide';
import { cleanupDraftListings } from '../../src/lib/cleanupDrafts';
import {
  dismissReport, hideListing, restoreListing, suspendProvider,
} from '../../src/lib/moderation';
import { reportId, submitReport } from '../../src/lib/reports';

const emulator = !!process.env.FIRESTORE_EMULATOR_HOST;

async function code(p: Promise<unknown>): Promise<string> {
  try {
    await p;
  } catch (e) {
    return `${(e as HttpsError).code}:${(e as HttpsError).message}`;
  }
  return 'ok';
}

describe.skipIf(!emulator)('reports, moderation and draft cleanup (Firestore emulator)', () => {
  const db = () => getFirestore();
  const data = async (path: string) => (await db().doc(path).get()).data();
  const exists = async (path: string) => (await db().doc(path).get()).exists;

  async function clear() {
    for (const c of ['reports', 'reportQuota', 'listings', 'providers', 'adminLogs']) {
      await db().recursiveDelete(db().collection(c));
    }
  }
  beforeEach(async () => {
    await clear();
    await db().doc('providers/p1').set({ displayName: 'Jean', status: 'approved' });
    await db().doc('listings/l1').set({ providerId: 'p1', status: 'active', moderation: 'ok' });
    await db().doc('listings/l2').set({ providerId: 'p1', status: 'active', moderation: 'ok' });
  });
  afterAll(clear);

  const report = (uid: string, key = 'l1', type: 'listing' | 'provider' | 'review' = 'listing', now?: number) =>
    submitReport(db(), uid, { targetType: type, targetKey: key, reason: 'scam', details: ' arnaque ' }, now);

  describe('submitReport', () => {
    it('creates an open report with a deterministic id and trimmed details', async () => {
      const r = await report('u1');
      expect(r).toEqual({ status: 'created', reportId: reportId('u1', 'listing', 'l1') });
      expect(await data(`reports/${r.reportId}`)).toMatchObject({
        reporterUid: 'u1', targetType: 'listing', targetKey: 'l1', reason: 'scam',
        details: 'arnaque', status: 'open',
      });
    });

    it('reports a provider as well', async () => {
      const r = await report('u1', 'p1', 'provider');
      expect(r.status).toBe('created');
    });

    it('reports a review (key "{providerId}__{reviewerUid}"); not your own, not a missing one', async () => {
      await db().doc('providers/p1/reviews/rev1').set({ authorUid: 'rev1', rating: 1, text: 'insulte' });
      const r = await report('u1', 'p1__rev1', 'review');
      expect(r).toEqual({ status: 'created', reportId: reportId('u1', 'review', 'p1__rev1') });
      expect(await code(report('rev1', 'p1__rev1', 'review'))).toBe('failed-precondition:own-target');
      expect(await code(report('u1', 'p1__ghost', 'review'))).toBe('not-found:target-not-found');
      expect(await code(report('u1', 'malformed', 'review'))).toBe('invalid-argument:invalid-input');
    });

    it('a second report on the same target is "already reported" and costs no quota', async () => {
      await report('u1');
      expect((await report('u1')).status).toBe('already_reported');
      expect((await data('reportQuota/u1'))!.count).toBe(1);
      const all = await db().collection('reports').get();
      expect(all.size).toBe(1);
    });

    it('rejects a missing target and your own content', async () => {
      expect(await code(report('u1', 'nope'))).toBe('not-found:target-not-found');
      expect(await code(report('p1', 'l1'))).toBe('failed-precondition:own-target');
      expect(await code(report('p1', 'p1', 'provider'))).toBe('failed-precondition:own-target');
      expect((await db().collection('reports').get()).size).toBe(0);
    });

    it('rejects over-long details', async () => {
      const p = submitReport(db(), 'u1', { targetType: 'listing', targetKey: 'l1', reason: 'scam', details: 'x'.repeat(501) });
      expect(await code(p)).toBe('invalid-argument:details-too-long');
    });

    describe('rate limit', () => {
      const seedTargets = async () => {
        for (let i = 0; i < REPORTS_PER_DAY + 2; i++) {
          await db().doc(`listings/t${i}`).set({ providerId: 'p1', status: 'active' });
        }
      };

      it(`allows ${REPORTS_PER_DAY} new reports per 24 h, then refuses`, async () => {
        await seedTargets();
        const t0 = 1_800_000_000_000;
        for (let i = 0; i < REPORTS_PER_DAY; i++) {
          expect((await report('u1', `t${i}`, 'listing', t0 + i)).status).toBe('created');
        }
        expect(await code(report('u1', `t${REPORTS_PER_DAY}`, 'listing', t0 + 100))).toBe(
          'resource-exhausted:rate-limited',
        );
        expect(await exists(`reports/${reportId('u1', 'listing', `t${REPORTS_PER_DAY}`)}`)).toBe(false);
      });

      it('is per user: another user is unaffected', async () => {
        await seedTargets();
        for (let i = 0; i < REPORTS_PER_DAY; i++) await report('u1', `t${i}`);
        expect((await report('u2', `t${REPORTS_PER_DAY}`)).status).toBe('created');
      });

      it('the window rolls over after 24 hours', async () => {
        await seedTargets();
        const t0 = 1_800_000_000_000;
        for (let i = 0; i < REPORTS_PER_DAY; i++) await report('u1', `t${i}`, 'listing', t0);
        expect(await code(report('u1', 'l1', 'listing', t0 + REPORT_WINDOW_MS - 1))).toContain('rate-limited');
        expect((await report('u1', 'l1', 'listing', t0 + REPORT_WINDOW_MS)).status).toBe('created');
        expect((await data('reportQuota/u1'))!.count).toBe(1);
      });

      it('concurrent calls cannot exceed the limit', async () => {
        await seedTargets();
        const results = await Promise.allSettled(
          Array.from({ length: REPORTS_PER_DAY + 2 }, (_, i) => report('u1', `t${i}`)),
        );
        const created = results.filter((r) => r.status === 'fulfilled').length;
        expect(created).toBeLessThanOrEqual(REPORTS_PER_DAY);
        expect((await data('reportQuota/u1'))!.count).toBeLessThanOrEqual(REPORTS_PER_DAY);
      }, 30_000);
    });
  });

  describe('applyAutoHide (onReportCreated)', () => {
    const open = (n: number, key = 'l1', type: 'listing' | 'provider' = 'listing') =>
      Promise.all(Array.from({ length: n }, (_, i) => report(`r${i}`, key, type)));

    it('does nothing below the threshold', async () => {
      await open(2);
      expect(await applyAutoHide(db(), { targetType: 'listing', targetKey: 'l1' })).toEqual({ openReports: 2, hidden: 0 });
      expect((await data('listings/l1'))!.moderation).toBe('ok');
    });

    it('hides a listing at 3 distinct reports and logs it', async () => {
      await open(3);
      const r = await applyAutoHide(db(), { targetType: 'listing', targetKey: 'l1' });
      expect(r).toEqual({ openReports: 3, hidden: 1 });
      expect(await data('listings/l1')).toMatchObject({ moderation: 'hidden', moderationReason: AUTO_REPORTS_REASON });
      const logs = await db().collection('adminLogs').get();
      expect(logs.docs[0].data()).toMatchObject({ actorUid: 'system', action: 'auto_hide', targetId: 'l1' });
    });

    it('the same user cannot count three times', async () => {
      await report('r0'); await report('r0'); await report('r0');
      expect((await applyAutoHide(db(), { targetType: 'listing', targetKey: 'l1' })).hidden).toBe(0);
    });

    it('a provider at 3 reports: all listings hidden, provider stays approved', async () => {
      await open(3, 'p1', 'provider');
      const r = await applyAutoHide(db(), { targetType: 'provider', targetKey: 'p1' });
      expect(r.hidden).toBe(2);
      expect((await data('listings/l1'))!.moderationReason).toBe(AUTO_REPORTS_REASON);
      expect((await data('listings/l2'))!.moderation).toBe('hidden');
      expect((await data('providers/p1'))!.status).toBe('approved');
    });

    it('is idempotent and leaves a listing hidden for another reason alone', async () => {
      await db().doc('listings/l1').update({ moderation: 'hidden', moderationReason: 'admin' });
      await open(3);
      expect((await applyAutoHide(db(), { targetType: 'listing', targetKey: 'l1' })).hidden).toBe(0);
      expect((await data('listings/l1'))!.moderationReason).toBe('admin');
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });

    it('dismissed reports no longer count', async () => {
      await open(3);
      const id = reportId('r0', 'listing', 'l1');
      await dismissReport(db(), 'mod1', { reportId: id });
      expect((await applyAutoHide(db(), { targetType: 'listing', targetKey: 'l1' })).hidden).toBe(0);
    });
  });

  describe('moderator actions', () => {
    it('hideListing hides it, resolves its reports as actioned and logs', async () => {
      await report('r0'); await report('r1');
      const r = await hideListing(db(), 'mod1', { listingId: 'l1', note: 'arnaque' });
      expect(r.resolvedReports).toBe(2);
      expect(await data('listings/l1')).toMatchObject({ moderation: 'hidden', moderationReason: 'admin' });
      const rep = await data(`reports/${reportId('r0', 'listing', 'l1')}`);
      expect(rep).toMatchObject({ status: 'actioned', resolution: { action: 'hide_target', by: 'mod1', note: 'arnaque' } });
      const log = (await db().collection('adminLogs').get()).docs[0].data();
      expect(log).toMatchObject({ actorUid: 'mod1', action: 'hide_listing', targetId: 'l1' });
    });

    it('restoreListing clears an auto or admin hide and dismisses open reports', async () => {
      await db().doc('listings/l1').update({ moderation: 'hidden', moderationReason: AUTO_REPORTS_REASON });
      await report('r0');
      await restoreListing(db(), 'mod1', { listingId: 'l1' });
      const l = (await data('listings/l1'))!;
      expect(l.moderation).toBe('ok');
      expect(l.moderationReason).toBeUndefined();
      expect((await data(`reports/${reportId('r0', 'listing', 'l1')}`))!.status).toBe('dismissed');
    });

    it('restoreListing refuses a listing hidden for over_limit', async () => {
      await db().doc('listings/l1').update({ moderation: 'hidden', moderationReason: 'over_limit' });
      expect(await code(restoreListing(db(), 'mod1', { listingId: 'l1' }))).toBe('failed-precondition:over-limit');
      expect((await data('listings/l1'))!.moderation).toBe('hidden');
    });

    it('suspendProvider suspends, resolves provider reports and logs the reason', async () => {
      await report('r0', 'p1', 'provider');
      const r = await suspendProvider(db(), 'mod1', { providerId: 'p1', reason: 'fraude confirmée' });
      expect(r.resolvedReports).toBe(1);
      expect((await data('providers/p1'))!.status).toBe('suspended');
      const log = (await db().collection('adminLogs').get()).docs[0].data();
      expect(log).toMatchObject({ action: 'suspend_provider', before: { status: 'approved' }, after: { status: 'suspended' }, note: 'fraude confirmée' });
    });

    it('dismissReport dismisses every open report on the same target only', async () => {
      await report('r0'); await report('r1'); await report('r2', 'l2');
      const r = await dismissReport(db(), 'mod1', { reportId: reportId('r0', 'listing', 'l1'), note: 'infondé' });
      expect(r.resolvedReports).toBe(2);
      expect((await data(`reports/${reportId('r1', 'listing', 'l1')}`))!.status).toBe('dismissed');
      expect((await data(`reports/${reportId('r2', 'listing', 'l2')}`))!.status).toBe('open');
      // Dismissing does not change the listing.
      expect((await data('listings/l1'))!.moderation).toBe('ok');
    });

    it('unknown targets are not-found and write no log', async () => {
      expect(await code(hideListing(db(), 'mod1', { listingId: 'zzz' }))).toBe('not-found:listing-not-found');
      expect(await code(restoreListing(db(), 'mod1', { listingId: 'zzz' }))).toBe('not-found:listing-not-found');
      expect(await code(suspendProvider(db(), 'mod1', { providerId: 'zzz', reason: 'abc' }))).toBe('not-found:provider-not-found');
      expect(await code(dismissReport(db(), 'mod1', { reportId: 'zzz' }))).toBe('not-found:report-not-found');
      expect((await db().collection('adminLogs').get()).size).toBe(0);
    });
  });

  describe('cleanupDraftListings (KZ-078)', () => {
    const DAY = 24 * 60 * 60 * 1000;
    const now = 1_800_000_000_000;
    const ts = (daysAgo: number) => new Date(now - daysAgo * DAY);

    it('deletes drafts older than 30 days and keeps everything else', async () => {
      await db().doc('listings/old-draft').set({ providerId: 'p1', status: 'draft', updatedAt: ts(31) });
      await db().doc('listings/edge-draft').set({ providerId: 'p1', status: 'draft', updatedAt: ts(30) });
      await db().doc('listings/new-draft').set({ providerId: 'p1', status: 'draft', updatedAt: ts(29) });
      await db().doc('listings/old-active').set({ providerId: 'p1', status: 'active', updatedAt: ts(200) });
      await db().doc('listings/old-paused').set({ providerId: 'p1', status: 'paused', updatedAt: ts(200) });

      expect(await cleanupDraftListings(db(), now)).toBe(1);
      expect(await exists('listings/old-draft')).toBe(false);
      for (const id of ['edge-draft', 'new-draft', 'old-active', 'old-paused', 'l1']) {
        expect(await exists(`listings/${id}`)).toBe(true);
      }
    });

    it('is idempotent and handles more than one page', async () => {
      const batch = db().batch();
      for (let i = 0; i < 450; i++) {
        batch.set(db().doc(`listings/d${i}`), { providerId: 'p1', status: 'draft', updatedAt: ts(60) });
      }
      await batch.commit();
      expect(await cleanupDraftListings(db(), now)).toBe(450);
      expect(await cleanupDraftListings(db(), now)).toBe(0);
    });

    it('leaves provider counters alone (drafts never held a slot)', async () => {
      await db().doc('providers/p1').update({ listingCount: 2 });
      await db().doc('listings/old-draft').set({ providerId: 'p1', status: 'draft', updatedAt: ts(90) });
      await cleanupDraftListings(db(), now);
      expect((await data('providers/p1'))!.listingCount).toBe(2);
    });
  });
});
