import { useState, type FormEvent } from "react";
import { useI18n } from "../i18n/I18nProvider";
import { LanguageSwitch } from "../LanguageSwitch";
import type { AuthService } from "../services/types";

export function loginErrorKey(err: unknown): "credentials" | "tooMany" | "network" | "generic" {
  const code = (err as { code?: unknown } | null)?.code;
  switch (code) {
    case "auth/invalid-credential":
    case "auth/wrong-password":
    case "auth/user-not-found":
    case "auth/invalid-email":
      return "credentials";
    case "auth/too-many-requests":
      return "tooMany";
    case "auth/network-request-failed":
      return "network";
    default:
      return "generic";
  }
}

export function LoginPage({ auth, notice }: { auth: AuthService; notice: string | null }) {
  const { t } = useI18n();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await auth.signIn(email.trim(), password);
    } catch (err) {
      setError(t.login.errors[loginErrorKey(err)]);
      setBusy(false);
    }
    // On success the auth subscription takes over (claims check).
  }

  return (
    <main className="center">
      <form className="card login" onSubmit={submit} aria-labelledby="login-title">
        <div className="row-between">
          <h1 id="login-title">{t.login.title}</h1>
          <LanguageSwitch />
        </div>
        <p className="muted">{t.login.subtitle}</p>
        {notice && (
          <p className="alert alert-error" role="alert">
            {notice}
          </p>
        )}
        <label>
          {t.login.email}
          <input
            type="email"
            autoComplete="username"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </label>
        <label>
          {t.login.password}
          <input
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </label>
        {error && (
          <p className="alert alert-error" role="alert">
            {error}
          </p>
        )}
        <button className="btn btn-primary" type="submit" disabled={busy}>
          {busy ? t.login.submitting : t.login.submit}
        </button>
      </form>
    </main>
  );
}
