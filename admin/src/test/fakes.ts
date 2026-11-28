import { vi } from "vitest";
import type { AdminApi, AuthedUser, AuthService, OpenReport, Target } from "../services/types";

export class FakeAuth implements AuthService {
  user: AuthedUser | null = null;
  claimsValue: Record<string, unknown> = {};
  claimsError = false;
  signOutCalls = 0;
  private listener: ((u: AuthedUser | null) => void) | null = null;

  subscribe(l: (u: AuthedUser | null) => void) {
    this.listener = l;
    queueMicrotask(() => l(this.user));
    return () => {
      this.listener = null;
    };
  }
  async signIn(email: string, password: string) {
    if (password === "wrong") throw { code: "auth/invalid-credential" };
    this.user = { uid: "u1", email };
    this.listener?.(this.user);
  }
  async signOut() {
    this.signOutCalls++;
    this.user = null;
    this.listener?.(null);
  }
  async claims() {
    if (this.claimsError) throw new Error("offline");
    return this.claimsValue;
  }
}

export const report = (over: Partial<OpenReport> & { id: string }): OpenReport => ({
  targetType: "listing",
  targetKey: "l1",
  reason: "scam",
  details: "",
  createdAt: new Date("2026-11-20T10:00:00Z"),
  ...over,
});

export function fakeApi(opts: { reports?: OpenReport[]; targets?: Record<string, Target> } = {}) {
  const state = { reports: opts.reports ?? [], targets: opts.targets ?? {} };
  const api = {
    listOpenReports: vi.fn(async () => state.reports),
    loadTarget: vi.fn(async (type: string, key: string) => state.targets[`${type}:${key}`] ?? null),
    hideListing: vi.fn(async (_id: string, _note?: string) => ({ resolvedReports: 1 })),
    restoreListing: vi.fn(async (_id: string, _note?: string) => ({ resolvedReports: 1 })),
    suspendProvider: vi.fn(async (_id: string, _reason: string) => ({ resolvedReports: 1 })),
    dismissReport: vi.fn(async (_id: string, _note?: string) => ({ resolvedReports: 2 })),
  };
  return { api: api as unknown as AdminApi & typeof api, state };
}
