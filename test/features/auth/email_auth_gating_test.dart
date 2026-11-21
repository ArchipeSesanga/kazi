import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/app/router/app_router.dart';
import 'package:kazi/app/router/routes.dart';
import 'package:kazi/core/config/env.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/features/auth/application/auth_controller.dart';
import 'package:kazi/features/auth/application/phone_auth_controller.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/auth/presentation/phone_screen.dart';
import 'package:kazi/features/gate/application/gate_controller.dart';
import 'package:kazi/features/gate/domain/gate_service.dart';
import 'package:kazi/features/welcome/application/onboarding_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';

class _NoUsers implements UserRepository {
  @override
  Stream<AppUser?> watchUser(String uid) => const Stream.empty();
  @override
  Future<void> createUser(AppUser user) async {}
  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> registerDevice(String uid, String fcmToken) async {}
}

class _OpenGate implements GateService {
  @override
  Future<bool> isMaintenanceMode() async => false;
  @override
  Future<bool> isUpdateRequired() async => false;
  @override
  String get storeUrl => '';
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required bool emailAuthEnabled,
  required String start,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_complete': true});
  final prefs = await SharedPreferences.getInstance();
  final auth = FakeAuthRepository();
  final session = SessionController(_NoUsers(), auth);
  final gate = GateController(_OpenGate());
  final onboarding = OnboardingController(prefs);
  final router = createAppRouter(
    session,
    gate,
    onboarding,
    emailAuthEnabled: emailAuthEnabled,
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PhoneAuthController(auth)),
        ChangeNotifierProvider.value(value: AuthController(auth)),
        ChangeNotifierProvider.value(value: session),
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
  await tester.pumpAndSettle();
  router.go(start);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('prod: /auth/email is blocked and lands on phone sign-in',
      (tester) async {
    await _pumpApp(tester, emailAuthEnabled: false, start: Routes.authEmail);
    expect(find.byType(PhoneScreen), findsOneWidget);
    expect(find.text('Connexion par e-mail (test)'), findsNothing);
  });

  testWidgets('dev/test: /auth/email stays reachable', (tester) async {
    await _pumpApp(tester, emailAuthEnabled: true, start: Routes.authEmail);
    expect(find.byType(PhoneScreen), findsNothing);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
  });

  testWidgets('phone screen hides the email button when disabled',
      (tester) async {
    await _pumpApp(tester, emailAuthEnabled: false, start: Routes.authPhone);
    expect(find.byKey(const Key('use-email-sign-in')), findsNothing);
  });

  testWidgets('phone screen shows the email button in dev', (tester) async {
    await _pumpApp(tester, emailAuthEnabled: true, start: Routes.authPhone);
    expect(find.byKey(const Key('use-email-sign-in')), findsOneWidget);
  });

  test('Env.emailAuthEnabled is true for the default (dev) flavor', () {
    expect(Env.emailAuthEnabled, isTrue);
  });
}
