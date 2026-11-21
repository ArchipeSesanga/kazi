import 'dart:async';

import '../../features/auth/application/session_controller.dart';
import '../../features/gate/application/gate_controller.dart';
import '../../features/welcome/application/onboarding_controller.dart';
import 'routes.dart';

/// Access levels enforced by the router (KZ-023).
///
/// 1. No session: only the welcome flow and phone sign-in ([_guestRoutes]).
/// 2. Session but no `users/{uid}` profile: only profile setup.
/// 3. Complete profile: the app. Provider-space routes additionally need
///    `providers/{uid}`; `/admin` routes need the admin claim.
///
/// Every state redirects to exactly one fixed destination, and that
/// destination is itself allowed in that state, so redirects cannot loop.
const _adminPrefix = '/admin';

/// Routes a signed-out user may open, before the onboarding is completed.
const _preOnboardingRoutes = {
  Routes.welcome,
  Routes.myLanguage,
  Routes.legalTerms,
  Routes.legalPrivacy,
};

/// Routes a signed-out user may open after onboarding (phone sign-in flow;
/// the language and legal pages stay reachable from it).
const _guestRoutes = {
  Routes.welcome,
  Routes.authPhone,
  Routes.authOtp,
  Routes.myLanguage,
  Routes.legalTerms,
  Routes.legalPrivacy,
};

/// Provider-space routes that need an existing `providers/{uid}`.
/// `/provider/onboarding` is deliberately not listed: it creates the doc.
bool isProviderRoute(String location) =>
    location == Routes.providerDashboard ||
    location == Routes.providerNewListing ||
    location == Routes.providerVerification ||
    (location.startsWith('/provider/listings/') && location.endsWith('/edit'));

bool isAdminRoute(String location) =>
    location == _adminPrefix || location.startsWith('$_adminPrefix/');

bool _isAuthRoute(String location) => location.startsWith('/auth/');

/// Where a signed-in user without a provider profile is sent. The hub is
/// unguarded and shows the onboarding call to action.
const providerFallback = Routes.publish;

/// Computes the redirect for [location]. Returns null to stay.
FutureOr<String?> resolveRedirect({
  required String location,
  required SessionController session,
  required GateController gate,
  required OnboardingController onboarding,
  required bool emailAuthEnabled,
}) {
  // Stay on splash until both session and gate checks resolve.
  if (session.isLoading || gate.isChecking) {
    return location == Routes.splash ? null : Routes.splash;
  }

  // Gate checks come first and cannot be escaped.
  if (gate.isMaintenanceMode) {
    return location == Routes.maintenance ? null : Routes.maintenance;
  }
  if (gate.isUpdateRequired) {
    return location == Routes.updateRequired ? null : Routes.updateRequired;
  }

  final onboarded = onboarding.isComplete;

  // ── Level 1: no session ──────────────────────────────────────────────────
  if (!session.hasSession) {
    final entry = onboarded ? Routes.authPhone : Routes.welcome;
    if (location == Routes.authEmail && emailAuthEnabled) return null;
    final allowed = onboarded ? _guestRoutes : _preOnboardingRoutes;
    if (location == Routes.welcome && onboarded) return Routes.authPhone;
    return allowed.contains(location) ? null : entry;
  }

  // ── Level 2: session without a profile ───────────────────────────────────
  if (session.isProfileIncomplete) {
    return location == Routes.authSetupProfile ? null : Routes.authSetupProfile;
  }

  // ── Level 3: complete profile ────────────────────────────────────────────
  if (location == Routes.splash ||
      location == Routes.welcome ||
      location == Routes.maintenance ||
      location == Routes.updateRequired ||
      _isAuthRoute(location)) {
    return Routes.home;
  }
  if (isAdminRoute(location)) {
    return session.isAdmin ? null : Routes.home;
  }
  if (isProviderRoute(location)) {
    return session.hasProviderProfile().then(
          (ok) => ok ? null : providerFallback,
        );
  }
  return null;
}
