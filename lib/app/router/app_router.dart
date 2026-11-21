import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/env.dart';
import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
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
import 'guards.dart';
import 'routes.dart';

GoRouter createAppRouter(
  SessionController session,
  GateController gate,
  OnboardingController onboarding, {
  bool? devToolsEnabled,
}) =>
    GoRouter(
  initialLocation: Routes.splash,
  refreshListenable: Listenable.merge([session, gate, onboarding]),
  redirect: (context, state) => resolveRedirect(
    location: state.matchedLocation,
    session: session,
    gate: gate,
    onboarding: onboarding,
  ),
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
      path: Routes.authPhone,
      builder: (context, state) => const PhoneScreen(
          ),
    ),
    GoRoute(
      path: Routes.authOtp,
      builder: (context, state) => const OtpScreen(),
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
    // Not registered at all in prod builds.
    if (devToolsEnabled ?? Env.isDev)
      GoRoute(
        path: Routes.devComponents,
        builder: (context, state) => const DevComponentsScreen(),
      ),
  ],
);
