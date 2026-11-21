import { describe, expect, it } from 'vitest';

import {
  changedFields,
  computeListingDerived,
  isOwnedListingMedia,
  removedPhotoPaths,
  shouldSetPublishedAt,
} from '../../src/lib/listingDerived';
import { buildSearchKeywords, tokens } from '../../src/lib/search';
import { computeVisible, titleHasPhoneNumber } from '../../src/lib/visibility';

const STATUSES = ['draft', 'active', 'paused'] as const;
const PROVIDER_STATUSES = ['pending', 'approved', 'rejected', 'suspended', undefined] as const;
const MODERATIONS = ['ok', 'hidden'] as const;

const names = (id: string) => id;
const category = { name: { fr: 'Plomberie', en: 'Plumbing' } };

describe('visibility matrix: status × providerStatus × moderation', () => {
  for (const status of STATUSES) {
    for (const providerStatus of PROVIDER_STATUSES) {
      for (const moderation of MODERATIONS) {
        const expected =
          status === 'active' && providerStatus === 'approved' && moderation === 'ok';
        it(`${status} / ${providerStatus ?? 'no provider'} / ${moderation} → visible=${expected}`, () => {
          expect(computeVisible(status, providerStatus, moderation)).toBe(expected);

          // Same matrix through the full derivation (title is clean, so the
          // content check never overrides the stored moderation).
          const derived = computeListingDerived(
            { status, title: 'Plomberie rapide', moderation },
            providerStatus ? { status: providerStatus, displayName: 'Jean' } : undefined,
            category,
            names,
          );
          expect(derived.visible).toBe(expected);
        });
      }
    }
  }

  it('treats a missing moderation field as ok', () => {
    expect(computeVisible('active', 'approved', undefined)).toBe(true);
  });
});

describe('computeListingDerived', () => {
  const listing = { status: 'active', title: 'Réparation de fuite', communes: ['gombe', 'mont_ngafula'] };
  const provider = {
    status: 'approved', displayName: 'Jean Mukendi', photoUrl: 'https://x/y.jpg',
    verified: true, ratingAvg: 4.5, ratingCount: 10,
  };

  it('denormalises provider and category fields', () => {
    const d = computeListingDerived(listing, provider, category, names);
    expect(d).toMatchObject({
      providerStatus: 'approved', providerName: 'Jean Mukendi',
      providerPhotoUrl: 'https://x/y.jpg', providerVerified: true,
      ratingAvg: 4.5, ratingCount: 10, categoryName: { fr: 'Plomberie', en: 'Plumbing' },
    });
  });

  it('builds searchKeywords from title, category, provider and communes', () => {
    const k = computeListingDerived(listing, provider, category, (id) => id.replace('_', ' ')).searchKeywords;
    for (const expected of ['re', 'reparation', 'fuite', 'plomberie', 'plumbing', 'jean', 'mukendi', 'gombe', 'mont', 'ngafula']) {
      expect(k).toContain(expected);
    }
    expect(k).not.toContain('de');
  });

  it('is not visible and has null provider fields when the provider is missing', () => {
    const d = computeListingDerived(listing, undefined, category, names);
    expect(d.visible).toBe(false);
    expect(d.providerStatus).toBeNull();
    expect(d.providerName).toBeNull();
  });

  it('hides a listing whose title contains a phone number (auto_content)', () => {
    const d = computeListingDerived(
      { ...listing, title: 'Plombier appelez 0812 345 678' }, provider, category, names,
    );
    expect(d).toMatchObject({ visible: false, moderation: 'hidden', moderationReason: 'auto_content' });
  });

  it('restores a listing once the offending phone number is removed', () => {
    const d = computeListingDerived(
      { ...listing, moderation: 'hidden', moderationReason: 'auto_content' }, provider, category, names,
    );
    expect(d).toMatchObject({ visible: true, moderation: 'ok', moderationReason: null });
  });

  it('keeps a listing hidden by reports or an admin hidden', () => {
    for (const reason of ['auto_reports', 'admin']) {
      const d = computeListingDerived(
        { ...listing, moderation: 'hidden', moderationReason: reason }, provider, category, names,
      );
      expect(d).toMatchObject({ visible: false, moderation: 'hidden', moderationReason: reason });
    }
  });
});

describe('loop guard and publishedAt', () => {
  const provider = { status: 'approved', displayName: 'Jean' };
  const derive = (listing: object) =>
    computeListingDerived({ title: 'Plomberie', ...listing }, provider, category, names);

  it('changedFields is empty once derived values are stored', () => {
    const d = derive({ status: 'active' });
    expect(changedFields({ ...d }, d)).toEqual({});
  });

  it('changedFields lists only what differs', () => {
    const d = derive({ status: 'active' });
    expect(Object.keys(changedFields({ ...d, visible: false }, d))).toEqual(['visible']);
  });

  it('sets publishedAt only the first time the listing is visible', () => {
    const visible = derive({ status: 'active' });
    const hidden = derive({ status: 'paused' });
    expect(shouldSetPublishedAt({}, visible)).toBe(true);
    expect(shouldSetPublishedAt({ publishedAt: new Date() }, visible)).toBe(false);
    expect(shouldSetPublishedAt({}, hidden)).toBe(false);
  });
});

describe('search normalisation (TDD §8.1 test vectors)', () => {
  it.each([
    ["Réparation de fuite d'eau", ['reparation', 'fuite', 'eau']],
    ['Électricité générale', ['electricite', 'generale']],
    ['Coiffure & beauté à Gombe', ['coiffure', 'beaute', 'gombe']],
  ])('%s', (input, expected) => {
    expect(tokens(input)).toEqual(expected);
  });

  it('emits prefixes of length 2..15 and caps at 200, dropping longest first', () => {
    expect(buildSearchKeywords(['plomberie'])).toEqual(
      ['pl', 'plo', 'plom', 'plomb', 'plombe', 'plomber', 'plomberi', 'plomberie'],
    );
    const many = Array.from({ length: 60 }, (_, i) => `mot${String.fromCharCode(97 + (i % 26))}${i}xyzxyzxyz`);
    const k = buildSearchKeywords(many);
    expect(k.length).toBeLessThanOrEqual(200);
    expect(k).toContain('mo');
  });

  it('detects phone numbers in titles', () => {
    expect(titleHasPhoneNumber('Appelez +243 812 345 678')).toBe(true);
    expect(titleHasPhoneNumber('Maçon 10 ans, 3 chantiers')).toBe(false);
  });
});

describe('storage deletion guards', () => {
  it('only deletes objects inside the owner’s listings folder', () => {
    expect(isOwnedListingMedia('media/u1/listings/l1/a.jpg', 'u1')).toBe(true);
    expect(isOwnedListingMedia('media/u2/listings/l1/a.jpg', 'u1')).toBe(false);
    expect(isOwnedListingMedia('media/u1/avatar/a.jpg', 'u1')).toBe(false);
    expect(isOwnedListingMedia('media/u1/listings/../avatar/a.jpg', 'u1')).toBe(false);
    expect(isOwnedListingMedia(undefined, 'u1')).toBe(false);
  });

  it('computes removed photo paths', () => {
    expect(removedPhotoPaths([{ path: 'a' }, { path: 'b' }], [{ path: 'b' }])).toEqual(['a']);
    expect(removedPhotoPaths(undefined, undefined)).toEqual([]);
  });
});
