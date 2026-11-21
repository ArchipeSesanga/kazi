import { MODERATION_ERRORS } from "@shared/moderation";
import type { Strings } from "../i18n/strings";

/** Maps a Firebase Functions / network error to a localised message. */
export function describeError(err: unknown, t: Strings): string {
  const e = err as { code?: unknown; message?: unknown } | null;
  const code = typeof e?.code === "string" ? e.code.replace(/^functions\//, "") : "";
  const message = typeof e?.message === "string" ? e.message : "";
  switch (code) {
    case "permission-denied":
      return t.errors.permission;
    case "unauthenticated":
      return t.errors.session;
    case "not-found":
      return t.errors.notFound;
    case "failed-precondition":
      return message.includes(MODERATION_ERRORS.overLimit) ? t.errors.overLimit : t.errors.generic;
    case "invalid-argument":
      return t.errors.invalid;
    case "resource-exhausted":
      return t.errors.rateLimited;
    case "unavailable":
    case "deadline-exceeded":
    case "network-request-failed":
      return t.errors.network;
    default:
      return t.errors.generic;
  }
}
