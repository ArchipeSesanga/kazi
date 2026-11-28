import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi/app/router/routes.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/services/connectivity_controller.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/listings/data/firestore_listing_repository.dart';
import 'package:kazi/features/listings/domain/listing_repository.dart';
import 'package:kazi/features/provider_profile/data/firestore_provider_repository.dart';
import 'package:kazi/features/provider_profile/domain/provider_repository.dart';
import 'package:kazi/features/provider_profile/presentation/provider_dashboard_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

void main() {
  late FakeFirebaseFirestore db;
  late SessionController session;

  setUp(() async {
    db = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    session = SessionController(
      FirebaseUserRepository(db, auth),
      FirebaseAuthRepository(auth),
    );
    await Future<void>.delayed(Duration.zero);
  });

  Future<GoRouter> pump(WidgetTester tester, {required String initial}) async {
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: Routes.providerDashboard,
          builder: (_, __) => const ProviderDashboardScreen(),
        ),
        GoRoute(
          path: '/p/:id',
          builder: (_, s) => Scaffold(body: Text('PROFILE ${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProviderRepository>.value(value: FirestoreProviderRepository(db)),
          Provider<ListingRepository>.value(value: FirestoreListingRepository(db)),
          ChangeNotifierProvider<SessionController>.value(value: session),
          ChangeNotifierProvider(create: (_) => ConnectivityController()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  testWidgets('back arrow returns to the previous screen when pushed', (tester) async {
    final router = await pump(tester, initial: Routes.home);
    unawaited(router.push(Routes.providerDashboard));
    await tester.pump();
    await tester.pump();
    expect(find.text('Mon espace'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.arrowLeft));
    await tester.pump();
    await tester.pump();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('back arrow goes Home when the dashboard was entered with go (empty stack)',
      (tester) async {
    await pump(tester, initial: Routes.providerDashboard);
    expect(find.text('Mon espace'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.arrowLeft));
    await tester.pump();
    await tester.pump();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('system back goes Home instead of being swallowed (empty stack)',
      (tester) async {
    await pump(tester, initial: Routes.providerDashboard);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('the app-bar action opens the provider\'s public profile', (tester) async {
    await pump(tester, initial: Routes.providerDashboard);

    await tester.tap(find.byTooltip('Voir mon profil public'));
    await tester.pump();
    await tester.pump();
    expect(find.text('PROFILE uid1'), findsOneWidget);
  });
}
