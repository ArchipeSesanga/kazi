import {
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  where,
  type Firestore,
} from "firebase/firestore";
import { httpsCallable, type Functions } from "firebase/functions";
import {
  MODERATOR_CALLABLES,
  type DismissReportInput,
  type HideListingInput,
  type ModerationResult,
  type ReportReason,
  type ReportTarget,
  type RestoreListingInput,
  type SuspendProviderInput,
} from "@shared/moderation";
import { REPORTS_LIMIT, type AdminApi, type OpenReport, type Target } from "./types";

const str = (v: unknown): string | null => (typeof v === "string" && v.length > 0 ? v : null);

export function createFirebaseAdminApi(db: Firestore, functions: Functions): AdminApi {
  const call = async <I, O>(name: string, input: I): Promise<O> =>
    (await httpsCallable<I, O>(functions, name)(input)).data;

  return {
    async listOpenReports() {
      const snap = await getDocs(
        query(
          collection(db, "reports"),
          where("status", "==", "open"),
          orderBy("createdAt", "desc"),
          limit(REPORTS_LIMIT),
        ),
      );
      return snap.docs.map((d): OpenReport => {
        const r = d.data();
        const ts = r.createdAt as { toDate?: () => Date } | undefined;
        return {
          id: d.id,
          targetType: r.targetType as ReportTarget,
          targetKey: String(r.targetKey),
          reason: r.reason as ReportReason,
          details: typeof r.details === "string" ? r.details : "",
          createdAt: ts?.toDate?.() ?? null,
        };
      });
    },

    async loadTarget(type, key): Promise<Target> {
      if (type === "listing") {
        const snap = await getDoc(doc(db, "listings", key));
        if (!snap.exists()) return null;
        const l = snap.data();
        const photos = Array.isArray(l.photos) ? (l.photos as Array<{ url?: string }>) : [];
        return {
          kind: "listing",
          id: snap.id,
          title: str(l.title) ?? snap.id,
          photoUrl: str(photos[0]?.url),
          status: str(l.status) ?? "unknown",
          moderation: l.moderation === "hidden" ? "hidden" : "ok",
          moderationReason: str(l.moderationReason),
          providerId: str(l.providerId) ?? "",
        };
      }
      if (type === "review") {
        const [providerId, reviewerUid] = key.split("__");
        if (!providerId || !reviewerUid) return null;
        const snap = await getDoc(doc(db, "providers", providerId, "reviews", reviewerUid));
        if (!snap.exists()) return null;
        const r = snap.data();
        return {
          kind: "review",
          id: snap.id,
          providerId,
          authorName: str(r.authorName) ?? snap.id,
          rating: typeof r.rating === "number" ? r.rating : 0,
          text: typeof r.text === "string" ? r.text : "",
          photoUrl: null,
        };
      }
      const snap = await getDoc(doc(db, "providers", key));
      if (!snap.exists()) return null;
      const p = snap.data();
      return {
        kind: "provider",
        id: snap.id,
        displayName: str(p.displayName) ?? snap.id,
        photoUrl: str(p.photoUrl),
        status: (str(p.status) ?? "pending") as "pending" | "approved" | "rejected" | "suspended",
      };
    },

    hideListing: (listingId, note) =>
      call<HideListingInput, ModerationResult>(MODERATOR_CALLABLES.hideListing, { listingId, note }),
    restoreListing: (listingId, note) =>
      call<RestoreListingInput, ModerationResult>(MODERATOR_CALLABLES.restoreListing, { listingId, note }),
    suspendProvider: (providerId, reason) =>
      call<SuspendProviderInput, ModerationResult>(MODERATOR_CALLABLES.suspendProvider, { providerId, reason }),
    dismissReport: (reportId, note) =>
      call<DismissReportInput, ModerationResult>(MODERATOR_CALLABLES.dismissReport, { reportId, note }),
  };
}
