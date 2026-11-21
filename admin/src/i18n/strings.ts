import type { ReportReason } from "@shared/moderation";

export interface Strings {
  appName: string;
  language: string;
  signOut: string;
  signedInAs: (email: string) => string;
  roles: { admin: string; moderator: string };
  login: {
    title: string;
    subtitle: string;
    email: string;
    password: string;
    submit: string;
    submitting: string;
    checking: string;
    denied: string;
    errors: { credentials: string; tooMany: string; network: string; generic: string };
  };
  reports: {
    title: string;
    refresh: string;
    loading: string;
    empty: string;
    loadFailed: string;
    retry: string;
    truncated: (n: number) => string;
    count: (n: number) => string;
    latest: string;
    listing: string;
    provider: string;
    deletedTarget: string;
    reasons: Record<ReportReason, string>;
    status: { hidden: string; visible: string; suspended: string; approved: string; pending: string; rejected: string };
    hiddenBy: { admin: string; auto_reports: string; over_limit: string; auto_content: string };
    restoreBlocked: string;
    actions: { hide: string; restore: string; suspend: string; dismiss: string };
    toasts: { hidden: string; restored: string; suspended: string; dismissed: (n: number) => string };
  };
  dialog: {
    cancel: string;
    working: string;
    noteLabel: string;
    noteOptional: string;
    reasonRequired: (min: number) => string;
    hideTitle: string;
    hideBody: (name: string) => string;
    restoreTitle: string;
    restoreBody: (name: string) => string;
    suspendTitle: string;
    suspendBody: (name: string) => string;
    dismissTitle: string;
    dismissBody: (count: number) => string;
  };
  errors: {
    permission: string;
    notFound: string;
    overLimit: string;
    session: string;
    rateLimited: string;
    network: string;
    invalid: string;
    generic: string;
  };
}

export const fr: Strings = {
  appName: "Kazi Admin",
  language: "Langue",
  signOut: "Se déconnecter",
  signedInAs: (email) => `Connecté : ${email}`,
  roles: { admin: "Administrateur", moderator: "Modérateur" },
  login: {
    title: "Connexion",
    subtitle: "Réservé à l’équipe de modération.",
    email: "Adresse e-mail",
    password: "Mot de passe",
    submit: "Se connecter",
    submitting: "Connexion…",
    checking: "Vérification de vos droits…",
    denied: "Ce compte n’a pas accès à l’administration. Vous avez été déconnecté.",
    errors: {
      credentials: "E-mail ou mot de passe incorrect.",
      tooMany: "Trop de tentatives. Réessayez dans quelques minutes.",
      network: "Pas de connexion. Vérifiez votre réseau.",
      generic: "Connexion impossible. Réessayez.",
    },
  },
  reports: {
    title: "Signalements ouverts",
    refresh: "Actualiser",
    loading: "Chargement des signalements…",
    empty: "Aucun signalement ouvert. 🎉",
    loadFailed: "Impossible de charger les signalements.",
    retry: "Réessayer",
    truncated: (n) => `Affichage des ${n} signalements les plus récents.`,
    count: (n) => (n === 1 ? "1 signalement" : `${n} signalements`),
    latest: "Dernier",
    listing: "Annonce",
    provider: "Prestataire",
    deletedTarget: "Contenu supprimé",
    reasons: {
      scam: "Arnaque",
      inappropriate: "Inapproprié",
      fake: "Faux profil / fausse annonce",
      wrong_category: "Mauvaise catégorie",
      other: "Autre",
    },
    status: {
      hidden: "Masquée",
      visible: "Visible",
      suspended: "Suspendu",
      approved: "Approuvé",
      pending: "En attente",
      rejected: "Refusé",
    },
    hiddenBy: {
      admin: "masquée par un modérateur",
      auto_reports: "masquée automatiquement (signalements)",
      over_limit: "masquée : limite d’annonces atteinte",
      auto_content: "masquée automatiquement (contenu)",
    },
    restoreBlocked: "Masquée pour limite d’annonces : le prestataire doit libérer une place.",
    actions: { hide: "Masquer", restore: "Rétablir", suspend: "Suspendre", dismiss: "Ignorer" },
    toasts: {
      hidden: "Annonce masquée.",
      restored: "Annonce rétablie.",
      suspended: "Prestataire suspendu.",
      dismissed: (n) => (n === 1 ? "1 signalement ignoré." : `${n} signalements ignorés.`),
    },
  },
  dialog: {
    cancel: "Annuler",
    working: "En cours…",
    noteLabel: "Note (journal d’audit)",
    noteOptional: "facultative",
    reasonRequired: (min) => `Motif obligatoire (${min} caractères minimum)`,
    hideTitle: "Masquer cette annonce ?",
    hideBody: (name) => `« ${name} » ne sera plus visible. Les signalements ouverts seront clôturés.`,
    restoreTitle: "Rétablir cette annonce ?",
    restoreBody: (name) => `« ${name} » redeviendra visible. Les signalements ouverts seront ignorés.`,
    suspendTitle: "Suspendre ce prestataire ?",
    suspendBody: (name) => `${name} ne sera plus visible et ses annonces seront masquées.`,
    dismissTitle: "Ignorer les signalements ?",
    dismissBody: (n) => `${n} signalement(s) ouvert(s) sur ce contenu seront classés sans suite. Le contenu n’est pas modifié.`,
  },
  errors: {
    permission: "Vous n’avez pas le droit d’effectuer cette action.",
    notFound: "Ce contenu n’existe plus. Actualisez la liste.",
    overLimit: "Impossible : cette annonce est masquée pour limite d’annonces.",
    session: "Session expirée. Reconnectez-vous.",
    rateLimited: "Trop de requêtes. Réessayez dans un instant.",
    network: "Pas de connexion. Vérifiez votre réseau.",
    invalid: "Données invalides. Vérifiez le formulaire.",
    generic: "Une erreur est survenue. Réessayez.",
  },
};

export const en: Strings = {
  appName: "Kazi Admin",
  language: "Language",
  signOut: "Sign out",
  signedInAs: (email) => `Signed in: ${email}`,
  roles: { admin: "Administrator", moderator: "Moderator" },
  login: {
    title: "Sign in",
    subtitle: "Moderation team only.",
    email: "Email address",
    password: "Password",
    submit: "Sign in",
    submitting: "Signing in…",
    checking: "Checking your access…",
    denied: "This account has no access to the admin panel. You have been signed out.",
    errors: {
      credentials: "Wrong email or password.",
      tooMany: "Too many attempts. Try again in a few minutes.",
      network: "No connection. Check your network.",
      generic: "Could not sign in. Try again.",
    },
  },
  reports: {
    title: "Open reports",
    refresh: "Refresh",
    loading: "Loading reports…",
    empty: "No open reports. 🎉",
    loadFailed: "Could not load the reports.",
    retry: "Try again",
    truncated: (n) => `Showing the ${n} most recent reports.`,
    count: (n) => (n === 1 ? "1 report" : `${n} reports`),
    latest: "Latest",
    listing: "Listing",
    provider: "Provider",
    deletedTarget: "Content deleted",
    reasons: {
      scam: "Scam",
      inappropriate: "Inappropriate",
      fake: "Fake profile / listing",
      wrong_category: "Wrong category",
      other: "Other",
    },
    status: {
      hidden: "Hidden",
      visible: "Visible",
      suspended: "Suspended",
      approved: "Approved",
      pending: "Pending",
      rejected: "Rejected",
    },
    hiddenBy: {
      admin: "hidden by a moderator",
      auto_reports: "hidden automatically (reports)",
      over_limit: "hidden: listing limit reached",
      auto_content: "hidden automatically (content)",
    },
    restoreBlocked: "Hidden for the listing limit: the provider must free a slot.",
    actions: { hide: "Hide", restore: "Restore", suspend: "Suspend", dismiss: "Dismiss" },
    toasts: {
      hidden: "Listing hidden.",
      restored: "Listing restored.",
      suspended: "Provider suspended.",
      dismissed: (n) => (n === 1 ? "1 report dismissed." : `${n} reports dismissed.`),
    },
  },
  dialog: {
    cancel: "Cancel",
    working: "Working…",
    noteLabel: "Note (audit log)",
    noteOptional: "optional",
    reasonRequired: (min) => `Reason required (at least ${min} characters)`,
    hideTitle: "Hide this listing?",
    hideBody: (name) => `“${name}” will no longer be visible. Its open reports will be closed.`,
    restoreTitle: "Restore this listing?",
    restoreBody: (name) => `“${name}” will be visible again. Its open reports will be dismissed.`,
    suspendTitle: "Suspend this provider?",
    suspendBody: (name) => `${name} will no longer be visible and their listings will be hidden.`,
    dismissTitle: "Dismiss the reports?",
    dismissBody: (n) => `${n} open report(s) on this content will be closed without action. The content is not changed.`,
  },
  errors: {
    permission: "You are not allowed to do this.",
    notFound: "This content no longer exists. Refresh the list.",
    overLimit: "Not possible: this listing is hidden for the listing limit.",
    session: "Session expired. Sign in again.",
    rateLimited: "Too many requests. Try again in a moment.",
    network: "No connection. Check your network.",
    invalid: "Invalid data. Check the form.",
    generic: "Something went wrong. Try again.",
  },
};

export type Lang = "fr" | "en";
export const dictionaries: Record<Lang, Strings> = { fr, en };

export function detectLang(navigatorLanguage: string | undefined, stored: string | null): Lang {
  if (stored === "fr" || stored === "en") return stored;
  return navigatorLanguage?.toLowerCase().startsWith("en") ? "en" : "fr";
}
