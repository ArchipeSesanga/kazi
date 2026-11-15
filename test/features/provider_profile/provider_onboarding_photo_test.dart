import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/provider_profile/application/provider_onboarding_controller.dart';
import 'package:kazi/features/provider_profile/domain/media_repository.dart';
import 'package:kazi/features/provider_profile/domain/provider_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockProviders extends Mock implements ProviderRepository {}

class _MockMedia extends Mock implements MediaRepository {}

class _MockUsers extends Mock implements UserRepository {}

class _FakeXFile extends Fake implements XFile {
  _FakeXFile(this.path);
  @override
  final String path;
}

class _FakeProfile extends Fake implements ProviderProfile {}

const _account = 'https://firebasestorage.googleapis.com/v0/b/x/o/media%2Fuid1%2Favatar%2Faccount.jpg?alt=media&token=a';
const _picked = 'https://firebasestorage.googleapis.com/v0/b/x/o/media%2Fuid1%2Favatar%2Fpicked.jpg?alt=media&token=b';

void main() {
  late _MockProviders providers;
  late _MockMedia media;
  late _MockUsers users;
  late SessionController session;

  setUpAll(() {
    registerFallbackValue(_FakeXFile('/f'));
    registerFallbackValue(MediaKind.avatar);
    registerFallbackValue(_FakeProfile());
  });

  Future<void> boot({String? accountPhoto}) async {
    providers = _MockProviders();
    media = _MockMedia();
    users = _MockUsers();
    final db = FakeFirebaseFirestore();
    await db.collection('users').doc('uid1').set({
      'displayName': 'Alice Mbuyi',
      'phone': '',
      'locale': 'fr',
      'city': 'kinshasa',
      'status': 'active',
      if (accountPhoto != null) 'photoUrl': accountPhoto,
    });
    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    session = SessionController(
      FirebaseUserRepository(db, auth),
      FirebaseAuthRepository(auth),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    when(() => providers.createProvider(any())).thenAnswer((_) async {});
    when(() => users.updateUser(any(), any())).thenAnswer((_) async {});
    when(() => media.deleteAvatarByUrl(any())).thenAnswer((_) async {});
    when(() => media.upload(any(), any(),
            onProgress: any(named: 'onProgress'),
            listingId: any(named: 'listingId')))
        .thenAnswer((_) async => const UploadedImage(path: 'media/uid1/avatar/picked.jpg', url: _picked));
  }

  OnboardingController make() => OnboardingController(providers, session, media, users)
    ..displayName = 'Alice Plomberie'
    ..whatsappNumber = '+243810000000'
    ..categoryIds = ['plomberie']
    ..baseCommune = 'gombe'
    ..communes = ['gombe'];

  ProviderProfile createdProfile() =>
      verify(() => providers.createProvider(captureAny())).captured.single as ProviderProfile;

  void verifyNoUpload() => verifyNever(() => media.upload(any(), any(),
      onProgress: any(named: 'onProgress'), listingId: any(named: 'listingId')));

  test('account already has a picture: it is prefilled and reused, nothing is uploaded', () async {
    await boot(accountPhoto: _account);
    final c = make();
    expect(c.photoUrl, _account);

    await c.submit();

    expect(c.isDone, isTrue, reason: '${c.error}');
    expect(createdProfile().photoUrl, _account);
    verifyNoUpload();
    verifyNever(() => users.updateUser(any(), any()));
    verifyNever(() => media.deleteAvatarByUrl(any()));
  });

  test('account has no picture: the one picked here becomes the account picture too', () async {
    await boot();
    final c = make();
    expect(c.photoUrl, isNull);
    c.pickAvatar(_FakeXFile('/p.jpg'));

    await c.submit();

    expect(c.isDone, isTrue, reason: '${c.error}');
    expect(createdProfile().photoUrl, _picked);
    verify(() => users.updateUser('uid1', {'photoUrl': _picked})).called(1);
    verifyNever(() => media.deleteAvatarByUrl(any()));
  });

  test('a different picture picked here overwrites the account picture and removes the old file', () async {
    await boot(accountPhoto: _account);
    final c = make()..pickAvatar(_FakeXFile('/p.jpg'));

    await c.submit();

    expect(createdProfile().photoUrl, _picked);
    verify(() => users.updateUser('uid1', {'photoUrl': _picked})).called(1);
    verify(() => media.deleteAvatarByUrl(_account)).called(1);
  });

  test('no picture anywhere: provider is created without one and the account is untouched', () async {
    await boot();
    final c = make();
    await c.submit();

    expect(c.isDone, isTrue);
    expect(createdProfile().photoUrl, isNull);
    verifyNoUpload();
    verifyNever(() => users.updateUser(any(), any()));
  });

  test('a failure syncing the account picture does not fail the submit', () async {
    await boot();
    when(() => users.updateUser(any(), any())).thenThrow(const NetworkException());
    final c = make()..pickAvatar(_FakeXFile('/p.jpg'));

    await c.submit();

    expect(c.isDone, isTrue);
    expect(c.error, isNull);
    verify(() => providers.createProvider(any())).called(1);
  });

  test('a failed provider create leaves the account picture alone', () async {
    await boot(accountPhoto: _account);
    when(() => providers.createProvider(any())).thenThrow(const NetworkException());
    final c = make()..pickAvatar(_FakeXFile('/p.jpg'));

    await c.submit();

    expect(c.isDone, isFalse);
    expect(c.error, isA<NetworkException>());
    verifyNever(() => users.updateUser(any(), any()));
    verifyNever(() => media.deleteAvatarByUrl(any()));
  });

  test('resubmit without a provider picture falls back to the account picture', () async {
    await boot(accountPhoto: _account);
    final c = OnboardingController(providers, session, media, users)
      ..prefillForResubmit(
        ProviderProfile(
          uid: 'uid1',
          displayName: 'Alice Plomberie',
          whatsappNumber: '+243810000000',
          categoryIds: const ['plomberie'],
          baseCommune: 'gombe',
          communes: const ['gombe'],
        ),
      );
    expect(c.photoUrl, _account);
  });
}
