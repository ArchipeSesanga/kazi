import { describe, expect, it } from 'vitest';

import { isAdminCaller, isVerifiedCaller } from '../../src/lib/caller';

describe('isVerifiedCaller', () => {
  it('accepts a verified phone number', () => {
    expect(isVerifiedCaller({ phone_number: '+243810000001' })).toBe(true);
  });
  it('accepts the admin claim without a phone', () => {
    expect(isVerifiedCaller({ admin: true, email: 'a@kazi.test' })).toBe(true);
  });
  it('rejects an email-only account', () => {
    expect(isVerifiedCaller({ email: 'dev@example.com' })).toBe(false);
    expect(isVerifiedCaller({ email: 'dev@example.com', admin: false })).toBe(false);
  });
  it('rejects missing tokens and falsy claims', () => {
    expect(isVerifiedCaller(undefined)).toBe(false);
    expect(isVerifiedCaller(null)).toBe(false);
    expect(isVerifiedCaller({ phone_number: '' })).toBe(false);
    expect(isVerifiedCaller({ admin: 'true' })).toBe(false);
  });
});

describe('isAdminCaller', () => {
  it('needs the admin claim; a phone is not enough', () => {
    expect(isAdminCaller({ admin: true })).toBe(true);
    expect(isAdminCaller({ phone_number: '+243810000001' })).toBe(false);
  });
});
