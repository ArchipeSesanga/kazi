import { MODERATION_REASON, REPORT_REASONS } from "@shared/moderation";
import { useI18n } from "../i18n/I18nProvider";
import type { Target } from "../services/types";
import type { ReportGroup } from "./group";

export type GroupAction = "hide" | "restore" | "suspend" | "dismiss";

/** Which actions make sense for a group, given its target's current state. */
export function availableActions(target: Target): GroupAction[] {
  if (!target) return ["dismiss"];
  if (target.kind === "listing") {
    return target.moderation === "hidden" ? ["restore", "dismiss"] : ["hide", "dismiss"];
  }
  return target.status === "suspended" ? ["dismiss"] : ["suspend", "dismiss"];
}

export function ReportGroupCard({
  group,
  target,
  onAction,
}: {
  group: ReportGroup;
  target: Target;
  onAction: (action: GroupAction) => void;
}) {
  const { t, lang } = useI18n();
  const actions = availableActions(target);
  const restoreBlocked =
    target?.kind === "listing" && target.moderation === "hidden" && target.moderationReason === MODERATION_REASON.overLimit;
  const name = !target ? t.reports.deletedTarget : target.kind === "listing" ? target.title : target.displayName;
  const photo = target?.photoUrl ?? null;
  const date = group.latestAt
    ? new Intl.DateTimeFormat(lang, { dateStyle: "medium", timeStyle: "short" }).format(group.latestAt)
    : "—";
  const hiddenReason =
    target?.kind === "listing" && target.moderation === "hidden"
      ? (t.reports.hiddenBy as Record<string, string>)[target.moderationReason ?? ""] ?? t.reports.status.hidden
      : null;

  return (
    <article className="card report" aria-label={name}>
      {photo ? <img className="thumb" src={photo} alt="" loading="lazy" /> : <div className="thumb thumb-empty" aria-hidden />}
      <div className="report-main">
        <div className="chips">
          <span className="chip chip-kind">{group.targetType === "listing" ? t.reports.listing : t.reports.provider}</span>
          <span className="chip chip-count">{t.reports.count(group.count)}</span>
          {target?.kind === "listing" && (
            <span className={`chip ${target.moderation === "hidden" ? "chip-warn" : "chip-ok"}`}>
              {target.moderation === "hidden" ? t.reports.status.hidden : t.reports.status.visible}
            </span>
          )}
          {target?.kind === "provider" && (
            <span className={`chip ${target.status === "suspended" ? "chip-warn" : "chip-ok"}`}>
              {t.reports.status[target.status]}
            </span>
          )}
        </div>
        <h3>{name}</h3>
        {hiddenReason && <p className="muted small">{hiddenReason}</p>}
        <p className="reasons">
          {REPORT_REASONS.filter((r) => group.reasons[r]).map((r) => (
            <span key={r} className="chip">
              {t.reports.reasons[r]} · {group.reasons[r]}
            </span>
          ))}
        </p>
        {group.details.length > 0 && (
          <ul className="details">
            {group.details.map((d, i) => (
              <li key={i}>“{d}”</li>
            ))}
          </ul>
        )}
        <p className="muted small">
          {t.reports.latest} : {date}
        </p>
        {restoreBlocked && <p className="muted small">{t.reports.restoreBlocked}</p>}
        <div className="actions">
          {actions.map((a) => (
            <button
              key={a}
              type="button"
              className={`btn ${a === "suspend" || a === "hide" ? "btn-danger" : a === "restore" ? "btn-primary" : ""}`}
              disabled={a === "restore" && restoreBlocked}
              onClick={() => onAction(a)}
            >
              {t.reports.actions[a]}
            </button>
          ))}
        </div>
      </div>
    </article>
  );
}
