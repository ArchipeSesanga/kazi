import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi/core/config/app_defaults.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/core/services/launcher_service.dart';
import 'package:kazi/core/widgets/kazi_button.dart';
import 'package:kazi/features/auth/application/phone_auth_controller.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/domain/auth_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/auth/presentation/phone_screen.dart';
import 'package:kazi/features/auth/presentation/setup_profile_screen.dart';
import 'package:kazi/features/legal/presentation/legal_notice.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'fake_auth_repository.dart';

class _Launcher implements LauncherService {
  final urls = <String>[];
  @override
  Future<void> launchUrl(String url) async => urls.add(url);
  @override
  Future<void> launchWhatsApp(String e164Phone, {String? message}) async {}
  @override
  Future<void> launchPhone(String e164Phone) async {}
}

class _Users implements UserRepository {
  AppUser? created;
  @override
  Future<void> createUser(AppUser user) async => created = user;
  @override
  Stream<AppUser?> watchUser(String uid) => Stream.value(null);
  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> registerDevice(String uid, String fcmToken) async {}
}

Widget _app(Widget home, {required String lang, required List<SingleChildWidget> providers}) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => home),
    GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
  ]);
  return MultiProvider(
    providers: providers,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(lang),
    ),
  );
}

void main() {
  group('phone screen', () {
    for (final entry in {
      'fr': ['En continuant, vous acceptez les ', "Conditions d'utilisation", ' et la ', 'Politique de confidentialité'],
      'en': ['By continuing you accept the ', 'Terms', ' and ', 'Privacy Policy'],
    }.entries) {
      testWidgets('shows the notice in ${entry.key} and the links open the ${entry.key} pages',
          (tester) async {
        final launcher = _Launcher();
        await tester.pumpWidget(_app(
          const PhoneScreen(emailAuthEnabled: false),
          lang: entry.key,
          providers: [
            Provider<LauncherService>.value(value: launcher),
            ChangeNotifierProvider(create: (_) => PhoneAuthController(FakeAuthRepository())),
          ],
        ));
        await tester.pumpAndSettle();

        expect(find.text(entry.value[0]), findsOneWidget);
        expect(find.text(entry.value[1]), findsOneWidget);
        expect(find.text(entry.value[3]), findsOneWidget);

        await tester.tap(find.byKey(LegalNotice.termsKey));
        await tester.tap(find.byKey(LegalNotice.privacyKey));
        expect(launcher.urls.length, 2);
        expect(launcher.urls[0], endsWith('/${entry.key}/terms'));
        expect(launcher.urls[1], endsWith('/${entry.key}/privacy'));
        expect(launcher.urls.every((u) => u.startsWith(AppDefaults.legalBaseUrl)), isTrue);
      });
    }
  });

  group('profile setup', () {
    Future<_Users> pump(WidgetTester tester, _Launcher launcher) async {
      final users = _Users();
      final auth = FakeAuthRepository(
        signedIn: const AuthUser(uid: 'u1', phone: FakeAuthRepository.testPhone),
      );
      final session = SessionController(users, auth);
      addTearDown(session.dispose);
      await tester.pumpWidget(_app(
        const SetupProfileScreen(),
        lang: 'fr',
        providers: [
          Provider<LauncherService>.value(value: launcher),
          Provider<UserRepository>.value(value: users),
          ChangeNotifierProvider<SessionController>.value(value: session),
        ],
      ));
      await tester.pump(const Duration(seconds: 6)); // session timeout -> profile incomplete
      await tester.pumpAndSettle();
      return users;
    }

    testWidgets('shows the notice with working links', (tester) async {
      final launcher = _Launcher();
      await pump(tester, launcher);
      await tester.ensureVisible(find.byKey(LegalNotice.termsKey));
      await tester.tap(find.byKey(LegalNotice.termsKey));
      await tester.ensureVisible(find.byKey(LegalNotice.privacyKey));
      await tester.tap(find.byKey(LegalNotice.privacyKey));
      expect(launcher.urls.map((u) => u.split('/').skip(3).join('/')), ['fr/terms', 'fr/privacy']);
    });

    testWidgets('saving stores the accepted terms version and a server timestamp',
        (tester) async {
      final users = await pump(tester, _Launcher());
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Mbuyi');
      await tester.ensureVisible(find.widgetWithText(KaziButton, 'Enregistrer mon profil'));
      await tester.tap(find.widgetWithText(KaziButton, 'Enregistrer mon profil'));
      await tester.pumpAndSettle();

      final user = users.created!;
      expect(user.termsVersion, AppDefaults.termsVersion);
      expect(user.phone, FakeAuthRepository.testPhone);
      final map = user.toCreateMap();
      expect(map['termsVersion'], AppDefaults.termsVersion);
      // The timestamp is written by the server, so it cannot be forged.
      expect(map['termsAcceptedAt'], isA<FieldValue>());
    });
  });
}
