import { buildSearchKeywords } from "./search.js";
import {
  AUTO_CONTENT_REASON,
  computeVisible,
  titleHasPhoneNumber,
} from "./visibility.js";

export interface ListingInput {
  status?: string;
  title?: string;
  communes?: string[];
  moderation?: string;
  moderationReason?: string | null;
  publishedAt?: unknown;
}

export interface ProviderInput {
  status?: string;
  displayName?: string;
  photoUrl?: string | null;
  verified?: boolean;
  ratingAvg?: number;
  ratingCount?: number;
}

export interface CategoryInput {
  name?: { fr?: string; en?: string };
}

/** Server-owned listing fields (TDD §4.6). `null` means "remove the field". */
export interface Derived {
  visible: boolean;
  moderation: "ok" | "hidden";
  moderationReason: string | null;
  providerStatus: string | null;
  providerName: string | null;
  providerPhotoUrl: string | null;
  providerVerified: boolean;
  ratingAvg: number;
  ratingCount: number;
  categoryName: { fr: string; en: string } | null;
  searchKeywords: string[];
}

export function computeListingDerived(
  listing: ListingInput,
  provider: ProviderInput | undefined,
  category: CategoryInput | undefined,
  communeNames: (id: string) => string,
): Derived {
  // Moderation: auto_content is owned by this function (set and cleared);
  // any other hidden reason (auto_reports, admin) is sticky.
  let moderation: "ok" | "hidden" = listing.moderation === "hidden" ? "hidden" : "ok";
  let moderationReason = listing.moderationReason ?? null;
  if (titleHasPhoneNumber(listing.title ?? "")) {
    moderation = "hidden";
    moderationReason = AUTO_CONTENT_REASON;
  } else if (moderation === "hidden" && moderationReason === AUTO_CONTENT_REASON) {
    moderation = "ok";
    moderationReason = null;
  }
  if (moderation === "ok") moderationReason = null;

  const categoryName =
    category?.name?.fr !== undefined || category?.name?.en !== undefined
      ? { fr: category?.name?.fr ?? "", en: category?.name?.en ?? "" }
      : null;

  return {
    visible: computeVisible(listing.status, provider?.status, moderation),
    moderation,
    moderationReason,
    providerStatus: provider?.status ?? null,
    providerName: provider?.displayName ?? null,
    providerPhotoUrl: provider?.photoUrl ?? null,
    providerVerified: provider?.verified === true,
    ratingAvg: provider?.ratingAvg ?? 0,
    ratingCount: provider?.ratingCount ?? 0,
    categoryName,
    searchKeywords: buildSearchKeywords([
      listing.title,
      categoryName?.fr,
      categoryName?.en,
      provider?.displayName,
      ...(listing.communes ?? []).map(communeNames),
    ]),
  };
}

/** Fields of `derived` that differ from what is stored (loop guard). */
export function changedFields(
  existing: Record<string, unknown>,
  derived: Derived,
): Partial<Record<keyof Derived, unknown>> {
  const out: Partial<Record<keyof Derived, unknown>> = {};
  for (const key of Object.keys(derived) as Array<keyof Derived>) {
    const next = derived[key];
    const prev = existing[key] ?? null;
    if (JSON.stringify(prev) !== JSON.stringify(next)) out[key] = next;
  }
  return out;
}

/** publishedAt is set the first time the listing becomes visible. */
export function shouldSetPublishedAt(
  existing: ListingInput,
  derived: Derived,
): boolean {
  return derived.visible && !existing.publishedAt;
}

/** Storage objects may only be deleted from the owner's own listing folder. */
export function isOwnedListingMedia(path: unknown, providerId: string): path is string {
  return (
    typeof path === "string" &&
    path.startsWith(`media/${providerId}/listings/`) &&
    !path.includes("..")
  );
}

export function removedPhotoPaths(
  before: Array<{ path?: string }> | undefined,
  after: Array<{ path?: string }> | undefined,
): string[] {
  const kept = new Set((after ?? []).map((p) => p.path));
  return (before ?? [])
    .map((p) => p.path)
    .filter((p): p is string => typeof p === "string" && !kept.has(p));
}
