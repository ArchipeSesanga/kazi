import { auth, db, functions } from "./firebase";
import { AuthGate } from "./auth/AuthGate";
import { useI18n } from "./i18n/I18nProvider";
import { LanguageSwitch } from "./LanguageSwitch";
import { ReportsPage } from "./reports/ReportsPage";
import { createFirebaseAdminApi } from "./services/firebaseAdminApi";
import { createFirebaseAuthService } from "./services/firebaseAuthService";
import type { AdminApi, AuthService } from "./services/types";

const defaultAuth = createFirebaseAuthService(auth);
const defaultApi = createFirebaseAdminApi(db, functions);

export function App({ authService = defaultAuth, api = defaultApi }: { authService?: AuthService; api?: AdminApi }) {
  const { t } = useI18n();
  return (
    <AuthGate auth={authService}>
      {(session) => (
        <>
          <header className="topbar">
            <strong>{t.appName}</strong>
            <span className="muted small grow">
              {t.signedInAs(session.user.email ?? session.user.uid)} · {t.roles[session.role]}
            </span>
            <LanguageSwitch />
            <button type="button" className="btn" onClick={() => void session.signOut()}>
              {t.signOut}
            </button>
          </header>
          <main className="page">
            <ReportsPage api={api} />
          </main>
        </>
      )}
    </AuthGate>
  );
}
