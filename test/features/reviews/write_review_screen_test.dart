import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/theme/kazi_typography.dart';
import 'package:kazi/core/widgets/kazi_button.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/contact/data/firestore_contact_repository.dart';
import 'package:kazi/features/contact/domain/contact_repository.dart';
import 'package:kazi/features/reviews/data/firestore_review_repository.dart';
import 'package:kazi/features/reviews/domain/review_repository.dart';
import 'package:kazi/features/reviews/presentation/write_review_screen.dart';
import 'package:provider/provider.dart';

Future<FakeFirebaseFirestore> _pump(
  WidgetTester tester, {
  required bool contacted,
}) async {
  final db = FakeFirebaseFirestore();
  await db.collection('users').doc('alice').set({
    'displayName': 'Alice Mbuyi',
    'phone': '',
    'locale': 'fr',
    'city': 'kinshasa',
    'status': 'active',
  });
  final auth = MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: 'alice'),
  );
  final session = SessionController(
    FirebaseUserRepository(db, auth),
    FirebaseAuthRepository(auth),
  );
  addTearDown(session.dispose);
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  final contactRepo = FirestoreContactRepository(db);
  if (contacted) {
    await contactRepo.record(
      const ContactDraft(
        clientUid: 'alice',
        providerId: 'p1',
        providerName: 'Jean',
        channel: 'call',
        whatsappNumber: '+243812345678',
      ),
    );
  }
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<ReviewRepository>.value(value: FirestoreReviewRepository(db)),
        Provider<ContactRepository>.value(value: contactRepo),
        ChangeNotifierProvider<SessionController>.value(value: session),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        theme: ThemeData(textTheme: KaziTypography.textTheme),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WriteReviewScreen(providerId: 'p1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  testWidgets(
    'no prior contact: "Contactez ce prestataire pour laisser un avis", no form',
    (tester) async {
      await _pump(tester, contacted: false);
      expect(
        find.text('Contactez ce prestataire pour laisser un avis'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('review-submit')), findsNothing);
      expect(find.byKey(const ValueKey('rating-input-1')), findsNothing);
    },
  );

  testWidgets(
    'after a contact: stars + comment, publish is disabled until a star is chosen',
    (tester) async {
      final db = await _pump(tester, contacted: true);
      expect(
        find.text('Contactez ce prestataire pour laisser un avis'),
        findsNothing,
      );
      KaziButton submit() => tester.widget<KaziButton>(
        find.byKey(const ValueKey('review-submit')),
      );
      expect(submit().onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('rating-input-5')));
      await tester.pump();
      expect(submit().onPressed, isNotNull);
      await tester.enterText(find.byType(TextField), 'Rapide et propre');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('review-submit')));
      await tester.pumpAndSettle();

      final doc = await db
          .collection('providers')
          .doc('p1')
          .collection('reviews')
          .doc('alice')
          .get();
      expect(doc.data(), containsPair('rating', 5));
      expect(doc.data(), containsPair('text', 'Rapide et propre'));
    },
  );
}
