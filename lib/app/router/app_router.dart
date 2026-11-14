import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/email_screen.dart';
import '../../features/auth/presentation/setup_profile_screen.dart';
import '../../features/catalog/presentation/category_screen.dart';
import '../../features/dev/presentation/dev_components_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/gate/application/gate_controller.dart';
import '../../features/gate/presentation/maintenance_screen.dart';
import '../../features/gate/presentation/update_required_screen.dart';
import '../../features/help/presentation/help_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/legal/presentation/legal_screen.dart';
import '../../features/listings/application/listing_form_controller.dart';
import '../../features/listings/presentation/listing_detail_screen.dart';
import '../../features/listings/presentation/listing_form_screen.dart';
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/provider_profile/presentation/provider_dashboard_screen.dart';
import '../../features/provider_profile/presentation/provider_onboarding_screen.dart';
import '../../features/provider_profile/presentation/provider_profile_screen.dart';
import '../../features/publish/presentation/publish_screen.dart';
import '../../features/reviews/presentation/provider_reviews_screen.dart';
import '../../features/reviews/presentation/write_review_screen.dart';
import '../../features/search/domain/search_repository.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/delete_account_screen.dart';
import '../../features/settings/presentation/language_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/verification/presentation/verification_screen.dart';
import '../../features/welcome/application/onboarding_controller.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../shell/app_shell.dart';
import 'routes.dart';

// Routes that unauthenticated users may visit freely.
const _publicRoutes = {
  Routes.splash,
  Routes.welcome,
  Routes.authEmail,
  Routes.authSetupProfile,
  Routes.myLanguage,
  Routes.legalTerms,
  Routes.legalPrivacy,
  Routes.updateRequired,
  Routes.maintenance,
};

GoRouter createAppRouter(
  SessionController session,
  GateController gate,
  OnboardingController onboarding,
) =>
    GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: Listenable.merge([session, gate, onboarding]),
  redirect: (context, state) {
    final location = state.matchedLocation;

    // Stay on splash until both session and gate checks resolve.
    if (session.isLoading || gate.isChecking) return Routes.splash;

    // Gate checks are highest priority and un-escapable.
    if (gate.isMaintenanceMode) {
      return location == Routes.maintenance ? null : Routes.maintenance;
    }
    if (gate.isUpdateRequired) {
      return location == Routes.updateRequired ? null : Routes.updateRequired;
    }

    // If sitting on a gate screen but gates are open, redirect away.
    if (location == Routes.maintenance || location == Routes.updateRequired) {
      return onboarding.isComplete ? Routes.authEmail : Routes.welcome;
    }

    final authed = session.isAuthenticated;
    final incomplete = session.isProfileIncomplete;
    final completedOnboarding = onboarding.isComplete;

    // Always leave the splash screen once session is resolved.
    if (location == Routes.splash) {
      if (authed) return Routes.home;
      if (incomplete) return Routes.authSetupProfile;
      return completedOnboarding ? Routes.authEmail : Routes.welcome;
    }

    final isPublic = _publicRoutes.any((r) => location.startsWith(r));

    if (!authed && !incomplete && !completedOnboarding &&
        location != Routes.welcome &&
        location != Routes.myLanguage &&
        location != Routes.legalTerms &&
        location != Routes.legalPrivacy) {
      return Routes.welcome;
    }
    if (!authed && !incomplete && completedOnboarding &&
        location == Routes.welcome) {
      return Routes.authEmail;
    }

    if (!authed && !incomplete && !isPublic) return Routes.welcome;
    if (incomplete && location != Routes.authSetupProfile) {
      return Routes.authSetupProfile;
    }
    if (authed && (location == Routes.welcome ||
        location.startsWith('/auth/'))) {
      return Routes.home;
    }
    return null;
  },
  routes: [
    // ── Splash & Welcome ────────────────────────────────────────────────────
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),

    // ── Auth flow ────────────────────────────────────────────────────────────
    GoRoute(
      path: Routes.authEmail,
      builder: (context, state) => const EmailScreen(),
    ),
    GoRoute(
      path: Routes.authSetupProfile,
      builder: (context, state) => const SetupProfileScreen(),
    ),
    GoRoute(
      path: Routes.myLanguage,
      builder: (context, state) => const LanguageScreen(),
    ),

    // ── 5-tab shell ──────────────────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.publish,
            builder: (context, state) => const PublishScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.messages,
            builder: (context, state) => const MessagesScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'delete',
                builder: (context, state) => const DeleteAccountScreen(),
              ),
            ],
          ),
        ]),
      ],
    ),

    // ── Search & discovery ───────────────────────────────────────────────────
    GoRoute(
      path: Routes.search,
      builder: (context, state) =>
          SearchScreen(initialQuery: SearchQuery.fromUri(state.uri)),
    ),
    GoRoute(
      path: '/category/:categoryId',
      builder: (context, state) => CategoryScreen(
        categoryId: state.pathParameters['categoryId']!,
      ),
    ),

    // ── Provider profile ─────────────────────────────────────────────────────
    GoRoute(
      path: '/p/:providerId',
      builder: (context, state) => ProviderProfileScreen(
        providerId: state.pathParameters['providerId']!,
      ),
      routes: [
        GoRoute(
          path: 'reviews',
          builder: (context, state) => ProviderReviewsScreen(
            providerId: state.pathParameters['providerId']!,
          ),
        ),
        GoRoute(
          path: 'review',
          builder: (context, state) => WriteReviewScreen(
            providerId: state.pathParameters['providerId']!,
          ),
        ),
      ],
    ),

    // ── Listing ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/l/:listingId',
      builder: (context, state) => ListingDetailScreen(
        listingId: state.pathParameters['listingId']!,
      ),
    ),

    // ── Provider space ───────────────────────────────────────────────────────
    GoRoute(
      path: Routes.providerOnboarding,
      builder: (context, state) => const ProviderOnboardingScreen(),
    ),
    GoRoute(
      path: Routes.providerDashboard,
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: Routes.providerNewListing,
      builder: (context, state) => ChangeNotifierProvider(
        create: (c) => ListingFormController(
          c.read(),
          c.read(),
          c.read(),
        )..init(),
        child: const ListingFormScreen(),
      ),
    ),
    GoRoute(
      path: '/provider/listings/:listingId/edit',
      builder: (context, state) => ChangeNotifierProvider(
        create: (c) => ListingFormController(
          c.read(),
          c.read(),
          c.read(),
          listingId: state.pathParameters['listingId'],
        )..init(),
        child: const ListingFormScreen(),
      ),
    ),
    GoRoute(
      path: Routes.providerVerification,
      builder: (context, state) => const VerificationScreen(),
    ),

    // ── Static & gate ────────────────────────────────────────────────────────
    GoRoute(
      path: Routes.legalTerms,
      builder: (context, state) => const LegalScreen(kind: LegalPageKind.terms),
    ),
    GoRoute(
      path: Routes.legalPrivacy,
      builder: (context, state) =>
          const LegalScreen(kind: LegalPageKind.privacy),
    ),
    GoRoute(
      path: Routes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: Routes.updateRequired,
      builder: (context, state) => const UpdateRequiredScreen(),
    ),
    GoRoute(
      path: Routes.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),

    // ── Dev only ─────────────────────────────────────────────────────────────
    GoRoute(
      path: Routes.devComponents,
      builder: (context, state) => const DevComponentsScreen(),
    ),
  ],
);
