import { describe, expect, it } from 'vitest';

import { decideSlot, wantsSlot } from '../../src/lib/slots';

const base = { held: false, wants: true, markedOverLimit: false, count: 0, max: 10 };

describe('wantsSlot: only active + paused count', () => {
  it.each([['active', true], ['paused', true], ['draft', false], [undefined, false]])(
    '%s → %s',
    (status, expected) => expect(wantsSlot(status as string | undefined)).toBe(expected),
  );
});

describe('decideSlot', () => {
  it('acquires a slot below the limit (9 of 10)', () => {
    expect(decideSlot({ ...base, count: 9 })).toEqual({ countDelta: 1, countsTowardLimit: true, mark: null });
  });

  it('hides instead of counting at the limit (10 of 10)', () => {
    expect(decideSlot({ ...base, count: 10 })).toEqual({ countDelta: 0, countsTowardLimit: false, mark: 'over_limit' });
  });

  it('over the limit and already marked → nothing to write', () => {
    expect(decideSlot({ ...base, count: 10, markedOverLimit: true })).toEqual({
      countDelta: 0, countsTowardLimit: false, mark: null,
    });
  });

  it('a marked listing is restored when a slot is free', () => {
    expect(decideSlot({ ...base, count: 9, markedOverLimit: true })).toEqual({
      countDelta: 1, countsTowardLimit: true, mark: 'clear',
    });
  });

  it('a held listing that stays active/paused changes nothing (idempotent)', () => {
    expect(decideSlot({ ...base, held: true, count: 10 })).toEqual({ countDelta: 0, countsTowardLimit: true, mark: null });
  });

  it('moving a held listing to draft frees the slot', () => {
    expect(decideSlot({ ...base, held: true, wants: false, count: 10 })).toEqual({
      countDelta: -1, countsTowardLimit: false, mark: null,
    });
  });

  it('a draft never counts, and a stale over_limit mark is lifted', () => {
    expect(decideSlot({ ...base, wants: false, count: 10 })).toEqual({ countDelta: 0, countsTowardLimit: false, mark: null });
    expect(decideSlot({ ...base, wants: false, count: 10, markedOverLimit: true }).mark).toBe('clear');
  });

  it('honours a configured max', () => {
    expect(decideSlot({ ...base, count: 2, max: 3 }).countDelta).toBe(1);
    expect(decideSlot({ ...base, count: 3, max: 3 }).mark).toBe('over_limit');
  });
});
