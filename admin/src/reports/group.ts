import type { ReportReason, ReportTarget } from "@shared/moderation";
import type { OpenReport } from "../services/types";

export interface ReportGroup {
  /** `${targetType}:${targetKey}` */
  key: string;
  targetType: ReportTarget;
  targetKey: string;
  count: number;
  reasons: Partial<Record<ReportReason, number>>;
  /** Up to three non-empty details, newest first. */
  details: string[];
  latestAt: Date | null;
  /** Any one report of the group; `moderator_dismissReport` resolves them all. */
  dismissReportId: string;
}

const time = (d: Date | null) => d?.getTime() ?? 0;

/**
 * Groups open reports by target. Most reported first; ties broken by the most
 * recent report.
 */
export function groupReports(reports: OpenReport[]): ReportGroup[] {
  const groups = new Map<string, ReportGroup>();
  const newestFirst = [...reports].sort((a, b) => time(b.createdAt) - time(a.createdAt));
  for (const r of newestFirst) {
    const key = `${r.targetType}:${r.targetKey}`;
    let g = groups.get(key);
    if (!g) {
      g = {
        key,
        targetType: r.targetType,
        targetKey: r.targetKey,
        count: 0,
        reasons: {},
        details: [],
        latestAt: r.createdAt,
        dismissReportId: r.id,
      };
      groups.set(key, g);
    }
    g.count++;
    g.reasons[r.reason] = (g.reasons[r.reason] ?? 0) + 1;
    if (r.details.trim() && g.details.length < 3) g.details.push(r.details.trim());
  }
  return [...groups.values()].sort(
    (a, b) => b.count - a.count || time(b.latestAt) - time(a.latestAt),
  );
}
