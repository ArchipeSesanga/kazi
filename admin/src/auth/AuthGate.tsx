import { useCallback, useEffect, useRef, useState, type ReactNode } from "react";
import { useI18n } from "../i18n/I18nProvider";
import type { AuthService, AuthedUser } from "../services/types";
import { roleOf, type StaffRole } from "./claims";
import { LoginPage } from "./LoginPage";

export interface Session {
  user: AuthedUser;
  role: StaffRole;
  signOut: () => Promise<void>;
}

type State =
  | { phase: "loading" }
  | { phase: "signedOut" }
  | { phase: "checking" }
  | { phase: "staff"; user: AuthedUser; role: StaffRole };

/**
 * Shows the app only to staff. After every sign-in (and on page reload) the ID
 * token claims are re-read; a user who is neither `admin` nor `moderator` is
 * signed out immediately with a message.
 */
export function AuthGate({
  auth,
  children,
}: {
  auth: AuthService;
  children: (session: Session) => ReactNode;
}) {
  const { t } = useI18n();
  const [state, setState] = useState<State>({ phase: "loading" });
  const [denied, setDenied] = useState(false);
  // Ignore results of a check superseded by a newer auth event.
  const run = useRef(0);

  useEffect(
    () =>
      auth.subscribe((user) => {
        const id = ++run.current;
        if (!user) {
          setState({ phase: "signedOut" });
          return;
        }
        setState({ phase: "checking" });
        auth
          .claims()
          .then(async (claims) => {
            if (id !== run.current) return;
            const role = roleOf(claims);
            if (role) {
              setDenied(false);
              setState({ phase: "staff", user, role });
            } else {
              setDenied(true);
              await auth.signOut();
            }
          })
          .catch(async () => {
            if (id !== run.current) return;
            // Cannot prove staff status: fail closed.
            setDenied(true);
            await auth.signOut();
          });
      }),
    [auth],
  );

  const signOut = useCallback(async () => {
    setDenied(false);
    await auth.signOut();
  }, [auth]);

  if (state.phase === "loading" || state.phase === "checking") {
    return (
      <main className="center" role="status">
        {t.login.checking}
      </main>
    );
  }
  if (state.phase === "signedOut") {
    return <LoginPage auth={auth} notice={denied ? t.login.denied : null} />;
  }
  return <>{children({ user: state.user, role: state.role, signOut })}</>;
}
