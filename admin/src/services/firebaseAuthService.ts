import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
  type Auth,
} from "firebase/auth";
import type { AuthService } from "./types";

export function createFirebaseAuthService(auth: Auth): AuthService {
  return {
    subscribe: (listener) =>
      onAuthStateChanged(auth, (u) => listener(u ? { uid: u.uid, email: u.email } : null)),
    signIn: async (email, password) => {
      await signInWithEmailAndPassword(auth, email, password);
    },
    signOut: () => signOut(auth),
    claims: async () => {
      const user = auth.currentUser;
      if (!user) return {};
      // Force a refresh so a claim granted after sign-in is seen, and a
      // revoked one is not.
      const token = await user.getIdTokenResult(true);
      return token.claims as Record<string, unknown>;
    },
  };
}
