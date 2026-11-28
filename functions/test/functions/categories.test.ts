import { describe, expect, it } from 'vitest';

import { CATEGORIES, FEATURED_COUNT, validateCategories } from '../../../shared/categories';
import { computeListingDerived } from '../../src/lib/listingDerived';
import { MAX_SEARCH_KEYWORDS, tokens } from '../../src/lib/search';

describe('category taxonomy (assets/data/categories.json)', () => {
  it('is valid: slugs, orders, 4–8 fr/en synonyms, ln/sw empty, 8 featured, autres last', () => {
    expect(validateCategories()).toEqual([]);
    expect(CATEGORIES).toHaveLength(23);
    expect(CATEGORIES.filter((c) => c.featured)).toHaveLength(FEATURED_COUNT);
    expect(CATEGORIES.at(-1)!.id).toBe('autres');
  });

  it('keeps the agreed slugs (ids are permanent)', () => {
    expect(CATEGORIES.map((c) => c.id)).toEqual([
      'plomberie', 'electricite', 'maconnerie', 'peinture', 'menuiserie', 'soudure', 'froid-clim',
      'menage', 'jardinage', 'coiffure', 'beaute', 'couture', 'telephones', 'informatique',
      'electromenager', 'mecanique-auto', 'transport', 'livraison', 'cours', 'evenements',
      'photo-video', 'securite', 'autres',
    ]);
  });

  it('rejects a broken taxonomy', () => {
    const bad = structuredClone(CATEGORIES);
    bad[0].synonyms.fr = ['seul'];
    bad[1].id = bad[2].id;
    expect(validateCategories(bad).join('\n')).toMatch(/1 fr synonyms/);
    expect(validateCategories(bad).join('\n')).toMatch(/duplicate id/);
  });
});

describe('synonyms feed searchKeywords', () => {
  const provider = { status: 'approved', displayName: 'Jean-Baptiste Mukendi Kabongo', verified: true };
  const communes = (id: string) => ({ ngaliema: 'Ngaliema', mont_ngafula: 'Mont-Ngafula', limete: 'Limete' }[id] ?? id);

  it('"plombier" finds Plomberie even when the title never says it', () => {
    const plomberie = CATEGORIES.find((c) => c.id === 'plomberie')!;
    const d = computeListingDerived(
      { status: 'active', title: 'Dépannage rapide à domicile', communes: ['gombe'] },
      provider, plomberie, communes,
    );
    expect(d.searchKeywords).toContain('plombier');
    expect(d.searchKeywords).toContain('fuite');
    expect(d.searchKeywords).toContain('robinet');
    expect(d.searchKeywords).toContain('plumber');
  });

  it('every synonym of every category survives the keyword cap (worst-case listing)', () => {
    for (const c of CATEGORIES) {
      const d = computeListingDerived(
        {
          status: 'active',
          title: 'Intervention professionnelle rapide et garantie à Kinshasa',
          communes: ['ngaliema', 'mont_ngafula', 'limete'],
        },
        provider, c, communes,
      );
      expect(d.searchKeywords.length).toBeLessThanOrEqual(MAX_SEARCH_KEYWORDS);
      for (const syn of [...c.synonyms.fr, ...c.synonyms.en]) {
        for (const t of tokens(syn)) {
          // The app searches with the longest token, cut to 15 characters.
          expect(d.searchKeywords, `${c.id}: ${syn}`).toContain(t.slice(0, 15));
        }
      }
    }
  });
});
