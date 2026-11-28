import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/constants/limits.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/provider_profile/application/provider_onboarding_controller.dart';
import 'package:kazi/features/provider_profile/domain/media_repository.dart';
import 'package:kazi/features/provider_profile/domain/provider_repository.dart';
import 'package:mocktail/mocktail.dart';

class _Providers extends Mock implements ProviderRepository {}

class _Media extends Mock implements MediaRepository {}

class _Users extends Mock implements UserRepository {}

void main() {
  late OnboardingController c;
  late SessionController session;

  setUp(() async {
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('u').set({
      'displayName': 'Alice Mbuyi',
      'phone': '',
      'locale': 'fr',
      'city': 'kinshasa',
      'status': 'active',
    });
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'u'));
    session = SessionController(
      FirebaseUserRepository(db, auth),
      FirebaseAuthRepository(auth),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    c = OnboardingController(_Providers(), session, _Media(), _Users());
  });

  tearDown(() {
    c.dispose();
    session.dispose();
  });

  test('a provider picks at most 3 categories', () {
    expect(Limits.maxCategoriesPerProvider, 3);
    for (final id in ['plomberie', 'electricite', 'menage', 'coiffure']) {
      c.toggleCategory(id);
    }
    expect(c.categoryIds, [
      'plomberie',
      'electricite',
      'menage',
    ]); // the 4th is ignored
  });

  test('deselecting frees a slot', () {
    for (final id in ['plomberie', 'electricite', 'menage']) {
      c.toggleCategory(id);
    }
    c.toggleCategory('electricite');
    expect(c.categoryIds, ['plomberie', 'menage']);
    c.toggleCategory('coiffure');
    expect(c.categoryIds, ['plomberie', 'menage', 'coiffure']);
  });

  test('toggling the same category twice leaves it unselected', () {
    c.toggleCategory('autres');
    c.toggleCategory('autres');
    expect(c.categoryIds, isEmpty);
  });
}
