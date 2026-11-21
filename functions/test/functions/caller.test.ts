import { describe, expect, it } from 'vitest';

import {
  ADMIN_ONLY_ACTIONS,
  MODERATION_ACTIONS,
  canPerform,
  isAdminCaller,
  isModeratorCaller,
  isStaffCaller,
  isVerifiedCaller,
} from '../../src/lib/caller';

const phoneUser = { phone_number: '+243810000001' };
const emailOnly = { email: 'dev@example.com' };
const moderator = { moderator: true, email: 'm@kazi.test' };
const admin = { admin: true, email: 'a@kazi.test' };

describe('isVerifiedCaller', () => {
  it('accepts a verified phone, a moderator and an admin', () => {
    expect(isVerifiedCaller(phoneUser)).toBe(true);
    expect(isVerifiedCaller(moderator)).toBe(true);
    expect(isVerifiedCaller(admin)).toBe(true);
  });
  it('rejects an email-only account, even with falsy claims', () => {
    expect(isVerifiedCaller(emailOnly)).toBe(false);
    expect(isVerifiedCaller({ ...emailOnly, admin: false, moderator: false })).toBe(false);
  });
  it('rejects missing tokens and non-boolean claims', () => {
    expect(isVerifiedCaller(undefined)).toBe(false);
    expect(isVerifiedCaller(null)).toBe(false);
    expect(isVerifiedCaller({ phone_number: '' })).toBe(false);
    expect(isVerifiedCaller({ admin: 'true' })).toBe(false);
    expect(isVerifiedCaller({ moderator: 1 })).toBe(false);
  });
});

describe('staff roles', () => {
  it('admin is also a moderator; moderator is not an admin', () => {
    expect(isModeratorCaller(admin)).toBe(true);
    expect(isModeratorCaller(moderator)).toBe(true);
    expect(isAdminCaller(moderator)).toBe(false);
    expect(isAdminCaller(admin)).toBe(true);
  });
  it('a verified phone alone is not staff', () => {
    expect(isStaffCaller(phoneUser)).toBe(false);
    expect(isModeratorCaller(phoneUser)).toBe(false);
    expect(isAdminCaller(phoneUser)).toBe(false);
  });
});

describe('canPerform', () => {
  it.each(MODERATION_ACTIONS)('%s: moderator and admin yes; phone user and email no', (a) => {
    expect(canPerform(moderator, a)).toBe(true);
    expect(canPerform(admin, a)).toBe(true);
    expect(canPerform(phoneUser, a)).toBe(false);
    expect(canPerform(emailOnly, a)).toBe(false);
  });
  it.each(ADMIN_ONLY_ACTIONS)('%s: admin only', (a) => {
    expect(canPerform(admin, a)).toBe(true);
    expect(canPerform(moderator, a)).toBe(false);
    expect(canPerform(phoneUser, a)).toBe(false);
    expect(canPerform(undefined, a)).toBe(false);
  });
});
