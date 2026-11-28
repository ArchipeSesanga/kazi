import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/core/widgets/kazi_button.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/domain/auth_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/settings/presentation/delete_account_screen.dart';
import 'package:provider/provider.dart';

import '../auth/fake_auth_repository.dart';

class _Users implements UserRepository {
  int deleted = 0;
  @override
  Future<void> deleteAccount() async => deleted++;
  @override
  Stream<AppUser?> watchUser(String uid) =>
      Stream.value(AppUser(uid: uid, displayName: 'Alice Mbuyi'));
  @override
  Future<void> createUser(AppUser user) async {}
  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {}
  @override
  Future<void> registerDevice(String uid, String fcmToken) async {}
}

Future<_Users> _pump(WidgetTester tester, {String? phone}) async {
  final auth = FakeAuthRepository(
    signedIn: AuthUser(uid: 'u1', phone: phone),
  );
  final users = _Users();
  final session = SessionController(users, auth);
  addTearDown(session.dispose);
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        Provider<UserRepository>.value(value: users),
        ChangeNotifierProvider<SessionController>.value(value: session),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('fr'),
        home: DeleteAccountScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return users;
}

void main() {
  testWidgets('the typed word, then an OTP, then the deletion', (tester) async {
    final users = await _pump(tester, phone: FakeAuthRepository.testPhone);

    // The continue button is disabled until the word is typed.
    expect(
      tester
          .widget<KaziButton>(find.widgetWithText(KaziButton, 'Continuer'))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'SUPPRIMER');
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Code à 6 chiffres'), findsOneWidget);
    expect(users.deleted, 0); // nothing is deleted before the OTP

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(KaziButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();
    expect(users.deleted, 1);
  });

  testWidgets('a wrong code shows the error and deletes nothing', (tester) async {
    final users = await _pump(tester, phone: FakeAuthRepository.testPhone);
    await tester.enterText(find.byType(TextField), 'SUPPRIMER');
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.widgetWithText(KaziButton, 'Supprimer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Code incorrect. Vérifiez et réessayez.'), findsOneWidget);
    expect(users.deleted, 0);
  });

  testWidgets('without a verified phone the app cannot delete', (tester) async {
    await _pump(tester);
    expect(find.byKey(const Key('delete-no-phone')), findsOneWidget);
    expect(find.text('Continuer'), findsNothing);
  });
}
