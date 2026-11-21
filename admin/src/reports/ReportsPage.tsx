import { SUSPEND_REASON_MIN } from "@shared/moderation";
import { useCallback, useEffect, useRef, useState } from "react";
import { useI18n } from "../i18n/I18nProvider";
import { REPORTS_LIMIT, type AdminApi, type Target } from "../services/types";
import { ConfirmDialog, type DialogPhase } from "./ConfirmDialog";
import { describeError } from "./errors";
import { groupReports, type ReportGroup } from "./group";
import { ReportGroupCard, type GroupAction } from "./ReportGroupCard";

type Load =
  | { status: "loading" }
  | { status: "error" }
  | { status: "ready"; groups: ReportGroup[]; targets: Record<string, Target>; truncated: boolean };

interface Pending {
  group: ReportGroup;
  action: GroupAction;
}

export function ReportsPage({ api }: { api: AdminApi }) {
  const { t } = useI18n();
  const [load, setLoad] = useState<Load>({ status: "loading" });
  const [pending, setPending] = useState<Pending | null>(null);
  const [phase, setPhase] = useState<DialogPhase>("idle");
  const [dialogError, setDialogError] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const seq = useRef(0);

  const refresh = useCallback(async () => {
    const id = ++seq.current;
    setLoad({ status: "loading" });
    try {
      const reports = await api.listOpenReports();
      const groups = groupReports(reports);
      const loaded = await Promise.all(
        groups.map(async (g) => [g.key, await api.loadTarget(g.targetType, g.targetKey)] as const),
      );
      if (id !== seq.current) return;
      setLoad({
        status: "ready",
        groups,
        targets: Object.fromEntries(loaded),
        truncated: reports.length >= REPORTS_LIMIT,
      });
    } catch {
      if (id === seq.current) setLoad({ status: "error" });
    }
  }, [api]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  function open(group: ReportGroup, action: GroupAction) {
    setPending({ group, action });
    setPhase("idle");
    setDialogError(null);
  }

  async function confirm(note: string) {
    if (!pending) return;
    const { group, action } = pending;
    const noteArg = note || undefined;
    setPhase("loading");
    setDialogError(null);
    try {
      let message: string;
      if (action === "hide") {
        await api.hideListing(group.targetKey, noteArg);
        message = t.reports.toasts.hidden;
      } else if (action === "restore") {
        await api.restoreListing(group.targetKey, noteArg);
        message = t.reports.toasts.restored;
      } else if (action === "suspend") {
        await api.suspendProvider(group.targetKey, note);
        message = t.reports.toasts.suspended;
      } else {
        const r = await api.dismissReport(group.dismissReportId, noteArg);
        message = t.reports.toasts.dismissed(r.resolvedReports);
      }
      setPending(null);
      setPhase("idle");
      setToast(message);
      await refresh();
    } catch (err) {
      setPhase("error");
      setDialogError(describeError(err, t));
    }
  }

  const dialog = pending && describeDialog(pending, load, t);

  return (
    <section aria-labelledby="reports-title">
      <div className="row-between">
        <h1 id="reports-title">{t.reports.title}</h1>
        <button type="button" className="btn" onClick={() => void refresh()} disabled={load.status === "loading"}>
          {t.reports.refresh}
        </button>
      </div>

      {toast && (
        <p className="alert alert-ok" role="status" onClick={() => setToast(null)}>
          {toast}
        </p>
      )}

      {load.status === "loading" && <p role="status">{t.reports.loading}</p>}
      {load.status === "error" && (
        <div className="alert alert-error" role="alert">
          <p>{t.reports.loadFailed}</p>
          <button type="button" className="btn" onClick={() => void refresh()}>
            {t.reports.retry}
          </button>
        </div>
      )}
      {load.status === "ready" && (
        <>
          {load.truncated && <p className="muted small">{t.reports.truncated(REPORTS_LIMIT)}</p>}
          {load.groups.length === 0 ? (
            <p className="empty">{t.reports.empty}</p>
          ) : (
            <div className="list">
              {load.groups.map((g) => (
                <ReportGroupCard key={g.key} group={g} target={load.targets[g.key] ?? null} onAction={(a) => open(g, a)} />
              ))}
            </div>
          )}
        </>
      )}

      {pending && dialog && (
        <ConfirmDialog
          {...dialog}
          phase={phase}
          error={dialogError}
          onConfirm={(n) => void confirm(n)}
          onCancel={() => setPending(null)}
        />
      )}
    </section>
  );
}

function describeDialog(p: Pending, load: Load, t: ReturnType<typeof useI18n>["t"]) {
  const target = load.status === "ready" ? load.targets[p.group.key] ?? null : null;
  const name = !target ? t.reports.deletedTarget : target.kind === "listing" ? target.title : target.displayName;
  switch (p.action) {
    case "hide":
      return { title: t.dialog.hideTitle, body: t.dialog.hideBody(name), confirmLabel: t.reports.actions.hide, danger: true, noteMin: 0 };
    case "restore":
      return { title: t.dialog.restoreTitle, body: t.dialog.restoreBody(name), confirmLabel: t.reports.actions.restore, danger: false, noteMin: 0 };
    case "suspend":
      return { title: t.dialog.suspendTitle, body: t.dialog.suspendBody(name), confirmLabel: t.reports.actions.suspend, danger: true, noteMin: SUSPEND_REASON_MIN };
    case "dismiss":
      return { title: t.dialog.dismissTitle, body: t.dialog.dismissBody(p.group.count), confirmLabel: t.reports.actions.dismiss, danger: false, noteMin: 0 };
  }
}
