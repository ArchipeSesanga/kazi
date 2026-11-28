import type {
  ListingModeration,
  ModerationResult,
  ProviderStatus,
  ReportReason,
  ReportTarget,
} from "@shared/moderation";

export interface AuthedUser {
  uid: string;
  email: string | null;
}

/** Everything the UI needs from Firebase Auth (faked in tests). */
export interface AuthService {
  subscribe(listener: (user: AuthedUser | null) => void): () => void;
  signIn(email: string, password: string): Promise<void>;
  signOut(): Promise<void>;
  /** The signed-in user's custom claims, from a force-refreshed ID token. */
  claims(): Promise<Record<string, unknown>>;
}

export interface OpenReport {
  id: string;
  targetType: ReportTarget;
  targetKey: string;
  reason: ReportReason;
  details: string;
  createdAt: Date | null;
}

export interface ListingTarget {
  kind: "listing";
  id: string;
  title: string;
  photoUrl: string | null;
  status: string;
  moderation: ListingModeration;
  moderationReason: string | null;
  providerId: string;
}

export interface ProviderTarget {
  kind: "provider";
  id: string;
  displayName: string;
  photoUrl: string | null;
  status: ProviderStatus;
}

/** A review is identified by `{providerId}__{reviewerUid}` (TDD §4.8). */
export interface ReviewTarget {
  kind: "review";
  id: string;
  providerId: string;
  authorName: string;
  rating: number;
  text: string;
  photoUrl: null;
}

/** `null` when the target no longer exists. */
export type Target = ListingTarget | ProviderTarget | ReviewTarget | null;

/** Reads from Firestore and calls the moderator callables (never writes). */
export interface AdminApi {
  /** Open reports, newest first, at most `REPORTS_LIMIT`. */
  listOpenReports(): Promise<OpenReport[]>;
  loadTarget(type: ReportTarget, key: string): Promise<Target>;
  hideListing(listingId: string, note?: string): Promise<ModerationResult>;
  restoreListing(listingId: string, note?: string): Promise<ModerationResult>;
  suspendProvider(providerId: string, reason: string): Promise<ModerationResult>;
  dismissReport(reportId: string, note?: string): Promise<ModerationResult>;
}

export const REPORTS_LIMIT = 500;
