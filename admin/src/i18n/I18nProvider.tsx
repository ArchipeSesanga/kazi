import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from "react";
import { detectLang, dictionaries, type Lang, type Strings } from "./strings";

interface I18n {
  lang: Lang;
  t: Strings;
  setLang: (lang: Lang) => void;
}

const Ctx = createContext<I18n | null>(null);
const KEY = "kazi-admin-lang";

const readStored = (): string | null => {
  try {
    return localStorage.getItem(KEY);
  } catch {
    return null;
  }
};

export function I18nProvider({ children, initial }: { children: ReactNode; initial?: Lang }) {
  const [lang, setLangState] = useState<Lang>(
    () => initial ?? detectLang(navigator.language, readStored()),
  );
  const setLang = useCallback((l: Lang) => {
    setLangState(l);
    document.documentElement.lang = l;
    try {
      localStorage.setItem(KEY, l);
    } catch {
      /* storage unavailable: keep the choice for this session only */
    }
  }, []);
  const value = useMemo(() => ({ lang, t: dictionaries[lang], setLang }), [lang, setLang]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useI18n(): I18n {
  const v = useContext(Ctx);
  if (!v) throw new Error("useI18n outside I18nProvider");
  return v;
}
