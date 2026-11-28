import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/limits.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/contact/data/firestore_contact_repository.dart';
import 'package:kazi/features/contact/domain/contact_repository.dart';
import 'package:kazi/features/reviews/application/write_review_controller.dart';
import 'package:kazi/features/reviews/data/firestore_review_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late SessionController session;
  late FirestoreReviewRepository reviews;
  late FirestoreContactRepository contacts;

  Future<void> boot({String uid = 'alice', bool signedIn = true}) async {
    db = FakeFirebaseFirestore();
    await db.collection('users').doc(uid).set({
      'displayName': 'Alice Mbuyi',
      'phone': '',
      'locale': 'fr',
      'city': 'kinshasa',
      'status': 'active',
    });
    final auth = MockFirebaseAuth(
      signedIn: signedIn,
      mockUser: MockUser(uid: uid),
    );
    session = SessionController(
      FirebaseUserRepository(db, auth),
      FirebaseAuthRepository(auth),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    reviews = FirestoreReviewRepository(db);
    contacts = FirestoreContactRepository(db);
  }

  WriteReviewController make(String providerId) =>
      WriteReviewController(reviews, contacts, session, providerId: providerId);

  Future<void> contact(String providerId) => contacts.record(
    ContactDraft(
      clientUid: 'alice',
      providerId: providerId,
      providerName: 'Jean',
      channel: 'whatsapp',
      whatsappNumber: '+243812345678',
    ),
  );

  tearDown(() => session.dispose());

  group('gating', () {
    test('never contacted → "Contactez ce prestataire…" and nothing can be submitted', () async {
      await boot();
      final c = make('p1');
      await c.init();
      expect(c.status, WriteReviewStatus.needsContact);
      c.setRating(5);
      expect(c.canSubmit, isFalse);
      await c.submit();
      expect(
        (await db.collection('providers').doc('p1').collection('reviews').get())
            .docs,
        isEmpty,
      );
      c.dispose();
    });

    test(
      'contacted → ready; a contact with another provider does not count',
      () async {
        await boot();
        await contact('p2');
        final other = make('p1');
        await other.init();
        expect(other.status, WriteReviewStatus.needsContact);
        final mine = make('p2');
        await mine.init();
        expect(mine.status, WriteReviewStatus.ready);
        other.dispose();
        mine.dispose();
      },
    );

    test('a provider cannot review their own profile', () async {
      await boot();
      final c = make('alice');
      await c.init();
      expect(c.status, WriteReviewStatus.ownProfile);
      c.dispose();
    });

    test('signed out → sign-in required', () async {
      await boot(signedIn: false);
      final c = make('p1');
      await c.init();
      expect(c.status, WriteReviewStatus.signInRequired);
      c.dispose();
    });
  });

  group('writing', () {
    test(
      'needs 1–5 stars; the comment is optional and capped at 300',
      () async {
        await boot();
        await contact('p1');
        final c = make('p1');
        await c.init();
        expect(c.canSubmit, isFalse); // no stars yet
        c.setRating(4);
        expect(c.canSubmit, isTrue);
        c.setText('x' * Limits.maxReviewTextChars);
        expect(c.canSubmit, isTrue);
        c.setText('x' * (Limits.maxReviewTextChars + 1));
        expect(c.textTooLong, isTrue);
        expect(c.canSubmit, isFalse);
        expect(Limits.maxReviewTextChars, 300);
        c.dispose();
      },
    );

    test(
      'publishes one review as the signed-in user, then it is an edit',
      () async {
        await boot();
        await contact('p1');
        final c = make('p1');
        await c.init();
        c.setRating(5);
        c.setText('  Très bon travail  ');
        await c.submit();
        expect(c.done, isTrue);
        final doc = await db
            .collection('providers')
            .doc('p1')
            .collection('reviews')
            .doc('alice')
            .get();
        expect(doc.data(), containsPair('rating', 5));
        expect(doc.data(), containsPair('text', 'Très bon travail'));
        expect(doc.data(), containsPair('authorName', 'Alice Mbuyi'));

        // Opening the screen again loads the existing review for editing.
        final again = make('p1');
        await again.init();
        expect(again.isEditing, isTrue);
        expect(again.rating, 5);
        again.setRating(2);
        await again.submit();
        final all = await db
            .collection('providers')
            .doc('p1')
            .collection('reviews')
            .get();
        expect(all.docs, hasLength(1)); // one review per user per provider
        expect(all.docs.single.data()['rating'], 2);
        c.dispose();
        again.dispose();
      },
    );

    test(
      'an author can edit even when the contact is gone, and delete',
      () async {
        await boot();
        await db
            .collection('providers')
            .doc('p1')
            .collection('reviews')
            .doc('alice')
            .set({
              'authorUid': 'alice',
              'authorName': 'Alice Mbuyi',
              'rating': 3,
              'text': '',
            });
        final c = make('p1');
        await c.init();
        expect(c.status, WriteReviewStatus.ready);
        expect(c.isEditing, isTrue);
        await c.delete();
        expect(c.done, isTrue);
        expect(
          (await db
                  .collection('providers')
                  .doc('p1')
                  .collection('reviews')
                  .get())
              .docs,
          isEmpty,
        );
        c.dispose();
      },
    );

    test('a failed write surfaces the error and keeps the form', () async {
      await boot();
      await contact('p1');
      final failing = WriteReviewController(
        _Failing(),
        contacts,
        session,
        providerId: 'p1',
      );
      await failing.init();
      failing.setRating(4);
      await failing.submit();
      expect(failing.done, isFalse);
      expect(failing.error, isA<PermissionDeniedException>());
      expect(failing.isSaving, isFalse);
      failing.dispose();
    });
  });
}

class _Failing extends FirestoreReviewRepository {
  _Failing() : super(FakeFirebaseFirestore());

  @override
  Future<void> upsert(String providerId, review) async =>
      throw const PermissionDeniedException('denied');
}
