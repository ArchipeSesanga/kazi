import { describe, expect, it } from 'vitest';

import { ratingAvgOf, ratingFieldsOf, ratingScoreOf } from '../../src/lib/ratings';

describe('rating math', () => {
  it('average has one decimal and is 0 without reviews', () => {
    expect(ratingAvgOf(0, 0)).toBe(0);
    expect(ratingAvgOf(5, 1)).toBe(5);
    expect(ratingAvgOf(14, 3)).toBe(4.7);
    expect(ratingAvgOf(153, 32)).toBe(4.8);
  });

  it('score = (4.0 * 5 + sum) / (5 + count)', () => {
    expect(ratingScoreOf(0, 0)).toBe(4);
    expect(ratingScoreOf(5, 1)).toBeCloseTo(25 / 6, 4);
    expect(ratingScoreOf(153, 32)).toBeCloseTo(173 / 37, 4);
  });

  it('one 5-star review does not outrank a long 4.8 record', () => {
    expect(ratingScoreOf(5, 1)).toBeLessThan(ratingScoreOf(153, 32));
  });

  it('bundles the four server fields', () => {
    expect(ratingFieldsOf(9, 2)).toEqual({
      ratingSum: 9, ratingCount: 2, ratingAvg: 4.5, ratingScore: Math.round((29 / 7) * 10000) / 10000,
    });
  });
});
