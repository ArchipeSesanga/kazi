// Listing-limit slots (TDD §4.11a). Only `active` and `paused` listings count
// toward `config/limits.maxListingsPerProvider`; drafts do not.
//
// State-based, not event-diff based: each listing carries a server-owned flag
// `countsTowardLimit`. The decision depends only on the stored state, so it is
// idempotent (duplicate or re-delivered events change nothing) and cannot loop.

export const OVER_LIMIT_REASON = "over_limit";

export function wantsSlot(status: string | undefined): boolean {
  return status === "active" || status === "paused";
}

export interface SlotInput {
  held: boolean; // listing.countsTowardLimit === true
  wants: boolean; // status is active | paused
  markedOverLimit: boolean; // moderation hidden with reason over_limit
  count: number; // providers.listingCount
  max: number; // config/limits.maxListingsPerProvider
}

export interface SlotDecision {
  countDelta: -1 | 0 | 1;
  countsTowardLimit: boolean;
  /** `over_limit` = hide the listing, `clear` = lift the over_limit hide. */
  mark: "over_limit" | "clear" | null;
}

export function decideSlot(i: SlotInput): SlotDecision {
  const clear = i.markedOverLimit ? "clear" : null;
  if (i.held && i.wants) return { countDelta: 0, countsTowardLimit: true, mark: null };
  if (i.held) return { countDelta: -1, countsTowardLimit: false, mark: clear };
  if (!i.wants) return { countDelta: 0, countsTowardLimit: false, mark: clear };
  if (i.count < i.max) return { countDelta: 1, countsTowardLimit: true, mark: clear };
  return {
    countDelta: 0,
    countsTowardLimit: false,
    mark: i.markedOverLimit ? null : "over_limit",
  };
}
