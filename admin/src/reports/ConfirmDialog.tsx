import { useEffect, useId, useRef, useState } from "react";
import { useI18n } from "../i18n/I18nProvider";

export type DialogPhase = "idle" | "loading" | "error";

interface Props {
  title: string;
  body: string;
  confirmLabel: string;
  danger?: boolean;
  /** Minimum note length; 0 = optional. */
  noteMin: number;
  phase: DialogPhase;
  error: string | null;
  onConfirm: (note: string) => void;
  onCancel: () => void;
}

/** Modal confirm dialog with a note, a loading state and an inline error. */
export function ConfirmDialog(p: Props) {
  const { t } = useI18n();
  const [note, setNote] = useState("");
  const id = useId();
  const noteRef = useRef<HTMLTextAreaElement>(null);
  const loading = p.phase === "loading";
  const noteOk = note.trim().length >= p.noteMin;

  useEffect(() => noteRef.current?.focus(), []);
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !loading) p.onCancel();
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [loading, p]);

  return (
    <div className="backdrop" onClick={() => !loading && p.onCancel()}>
      <div
        className="dialog card"
        role="dialog"
        aria-modal="true"
        aria-labelledby={`${id}-title`}
        aria-describedby={`${id}-body`}
        onClick={(e) => e.stopPropagation()}
      >
        <h2 id={`${id}-title`}>{p.title}</h2>
        <p id={`${id}-body`}>{p.body}</p>
        <label>
          {p.noteMin > 0 ? t.dialog.reasonRequired(p.noteMin) : `${t.dialog.noteLabel} (${t.dialog.noteOptional})`}
          <textarea
            ref={noteRef}
            rows={3}
            maxLength={500}
            value={note}
            disabled={loading}
            onChange={(e) => setNote(e.target.value)}
          />
        </label>
        {p.phase === "error" && p.error && (
          <p className="alert alert-error" role="alert">
            {p.error}
          </p>
        )}
        <div className="row-end">
          <button type="button" className="btn" disabled={loading} onClick={p.onCancel}>
            {t.dialog.cancel}
          </button>
          <button
            type="button"
            className={`btn ${p.danger ? "btn-danger" : "btn-primary"}`}
            disabled={loading || !noteOk}
            onClick={() => p.onConfirm(note.trim())}
          >
            {loading ? t.dialog.working : p.confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
