export type ListingStatus = "draft" | "active" | "paused";
export type ProviderStatus = "pending" | "approved" | "rejected" | "suspended";
export type Moderation = "ok" | "hidden";

/**
 * TDD §4.6: `visible = status == active && providerStatus == approved
 * && moderation == ok`. Anything unknown (missing provider, missing field)
 * is NOT visible.
 */
export function computeVisible(
  status: string | undefined,
  providerStatus: string | undefined,
  moderation: string | undefined,
): boolean {
  return (
    status === "active" &&
    providerStatus === "approved" &&
    (moderation ?? "ok") === "ok"
  );
}

export const AUTO_CONTENT_REASON = "auto_content";

/** A title must not contain a phone number (8+ digits, separators ignored). */
export function titleHasPhoneNumber(title: string): boolean {
  return /\d{8,}/.test(title.replace(/[\s.\-()+]/g, ""));
}
