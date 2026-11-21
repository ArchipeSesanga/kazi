import { useI18n } from "./i18n/I18nProvider";

export function LanguageSwitch() {
  const { lang, setLang, t } = useI18n();
  return (
    <div className="seg" role="group" aria-label={t.language}>
      {(["fr", "en"] as const).map((l) => (
        <button
          key={l}
          type="button"
          className={l === lang ? "seg-on" : ""}
          aria-pressed={l === lang}
          onClick={() => setLang(l)}
        >
          {l.toUpperCase()}
        </button>
      ))}
    </div>
  );
}
