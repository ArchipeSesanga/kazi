import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/core/state/paged_state.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/profile/application/edit_profile_controller.dart';
import 'package:kazi/features/provider_profile/domain/media_repository.dart';
import 'package:kazi/features/provider_profile/domain/provider_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedia extends Mock implements MediaRepository {}

class _FakeXFile extends Fake implements XFile {
  _FakeXFile(this.path);
  @override
  final String path;
}

const _old =
    'https://firebasestorage.googleapis.com/v0/b/x/o/media%2Fuid1%2Favatar%2Fold.jpg?alt=media&token=a';
const _new =
    'https://firebasestorage.googleapis.com/v0/b/x/o/media%2Fuid1%2Favatar%2Fnew.jpg?alt=media&token=b';

void main() {
  late FakeFirebaseFirestore db;
  late _MockMedia media;
  late SessionController session;

  setUpAll(() {
    registerFallbackValue(_FakeXFile('/fallback'));
    registerFallbackValue(MediaKind.avatar);
  });

  Future<void> boot({String? photoUrl}) async {
    db = FakeFirebaseFirestore();
    media = _MockMedia();
    await db.collection('users').doc('uid1').set({
      'displayName': 'Alice Mbuyi',
      'phone': '',
      'locale': 'fr',
      'city': 'kinshasa',
      'status': 'active',
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid1'),
    );
    session = SessionController(
      FirebaseUserRepository(db, auth),
      FirebaseAuthRepository(auth),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    when(
      () => media.upload(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
        listingId: any(named: 'listingId'),
      ),
    ).thenAnswer(
      (_) async =>
          const UploadedImage(path: 'media/uid1/avatar/new.jpg', url: _new),
    );
    when(() => media.deleteAvatarByUrl(any())).thenAnswer((_) async {});
  }

  EditProfileController make() => EditProfileController(
    FirebaseUserRepository(
      db,
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1')),
    ),
    _FakeProviders(db),
    media,
    session,
  );

  Future<void> seedProvider({String status = 'approved', String? photoUrl}) =>
      db.collection('providers').doc('uid1').set({
        'displayName': 'Alice Plomberie',
        'bio': '',
        'categoryIds': ['plomberie'],
        'city': 'kinshasa',
        'baseCommune': 'gombe',
        'communes': ['gombe'],
        'whatsappNumber': '+243810000000',
        'yearsExperience': 2,
        'portfolio': <Map<String, dynamic>>[],
        'status': status,
        'verified': false,
        'ratingAvg': 0,
        'ratingCount': 0,
        'ratingSum': 0,
        'listingCount': 0,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

  Future<Map<String, dynamic>?> user() async =>
      (await db.collection('users').doc('uid1').get()).data();
  Future<Map<String, dynamic>?> provider() async =>
      (await db.collection('providers').doc('uid1').get()).data();

  test(
    'adds a picture: uploads it as an avatar and stores it on the user',
    () async {
      await boot();
      final c = make()..pickPhoto(_FakeXFile('/p.jpg'));
      expect(c.hasPhoto, isTrue);

      expect(await c.save(displayName: 'Alice Mbuyi'), isTrue);

      expect((await user())!['photoUrl'], _new);
      verify(
        () => media.upload(
          any(),
          MediaKind.avatar,
          onProgress: any(named: 'onProgress'),
          listingId: any(named: 'listingId'),
        ),
      ).called(1);
      verifyNever(() => media.deleteAvatarByUrl(any()));
    },
  );

  test('a provider\'s public profile gets the same picture', () async {
    await boot();
    await seedProvider();
    final c = make()..pickPhoto(_FakeXFile('/p.jpg'));
    expect(
      await c.save(displayName: 'Alice Mbuyi'),
      isTrue,
      reason: '${c.error}',
    );

    expect((await provider())!['photoUrl'], _new);
    expect((await user())!['photoUrl'], _new);
  });

  test('a suspended provider is not touched', () async {
    await boot();
    await seedProvider(status: 'suspended');
    final c = make()..pickPhoto(_FakeXFile('/p.jpg'));
    expect(await c.save(displayName: 'Alice Mbuyi'), isTrue);

    expect((await provider())!.containsKey('photoUrl'), isFalse);
    expect((await user())!['photoUrl'], _new);
  });

  test('replacing a picture deletes the old file afterwards', () async {
    await boot(photoUrl: _old);
    final c = make()..pickPhoto(_FakeXFile('/p.jpg'));
    expect(
      await c.save(displayName: 'Alice Mbuyi'),
      isTrue,
      reason: '${c.error}',
    );

    verify(() => media.deleteAvatarByUrl(_old)).called(1);
  });

  test('removing the picture clears it on the user and the provider', () async {
    await boot(photoUrl: _old);
    await seedProvider(photoUrl: _old);
    final c = make()..removePhoto();
    expect(c.hasPhoto, isFalse);
    final ok = await c.save(displayName: 'Alice Mbuyi');
    expect(ok, isTrue, reason: '${c.error}');

    expect((await user())!['photoUrl'], isNull);
    expect((await provider())!['photoUrl'], isNull);
    verify(() => media.deleteAvatarByUrl(_old)).called(1);
    verifyNever(
      () => media.upload(
        any(),
        any(),
        onProgress: any(named: 'onProgress'),
        listingId: any(named: 'listingId'),
      ),
    );
  });

  test(
    'saving only the name does not upload, delete or touch the provider',
    () async {
      await boot(photoUrl: _old);
      await seedProvider(photoUrl: _old);
      final c = make();
      expect(c.hasPhoto, isTrue);
      expect(
        await c.save(displayName: 'Alice Kabila', commune: 'gombe'),
        isTrue,
      );

      final u = (await user())!;
      expect(u['displayName'], 'Alice Kabila');
      expect(u['commune'], 'gombe');
      expect(u['photoUrl'], _old);
      verifyNever(
        () => media.upload(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
          listingId: any(named: 'listingId'),
        ),
      );
      verifyNever(() => media.deleteAvatarByUrl(any()));
    },
  );

  test(
    'an upload failure keeps the profile unchanged and reports the error',
    () async {
      await boot(photoUrl: _old);
      when(
        () => media.upload(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
          listingId: any(named: 'listingId'),
        ),
      ).thenThrow(const NetworkException());
      final c = make()..pickPhoto(_FakeXFile('/p.jpg'));

      expect(await c.save(displayName: 'Alice Mbuyi'), isFalse);

      expect(c.error, isA<NetworkException>());
      expect(c.isSaving, isFalse);
      expect((await user())!['photoUrl'], _old);
      verifyNever(() => media.deleteAvatarByUrl(any()));
    },
  );

  test(
    'a retry after a failed profile write does not upload the picture again',
    () async {
      await boot();
      final failing = _FailingOnceUsers(
        FirebaseUserRepository(
          db,
          MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1')),
        ),
      );
      final c = EditProfileController(
        failing,
        _FakeProviders(db),
        media,
        session,
      )..pickPhoto(_FakeXFile('/p.jpg'));

      expect(await c.save(displayName: 'Alice Mbuyi'), isFalse);
      expect(await c.save(displayName: 'Alice Mbuyi'), isTrue);

      verify(
        () => media.upload(
          any(),
          any(),
          onProgress: any(named: 'onProgress'),
          listingId: any(named: 'listingId'),
        ),
      ).called(1);
      expect((await user())!['photoUrl'], _new);
    },
  );
}

class _FailingOnceUsers implements UserRepository {
  _FailingOnceUsers(this._inner);
  final UserRepository _inner;
  bool _failed = false;

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    if (!_failed) {
      _failed = true;
      throw const NetworkException();
    }
    return _inner.updateUser(uid, fields);
  }

  @override
  Stream<AppUser?> watchUser(String uid) => _inner.watchUser(uid);
  @override
  Future<void> createUser(AppUser user) => _inner.createUser(user);
  @override
  Future<void> deleteAccount() => _inner.deleteAccount();
  @override
  Future<void> registerDevice(String uid, String fcmToken) =>
      _inner.registerDevice(uid, fcmToken);
}

/// The real repository calls `waitForPendingWrites`, which the fake Firestore
/// does not implement; this keeps the same read/update contract.
class _FakeProviders implements ProviderRepository {
  _FakeProviders(this._db);
  final FakeFirebaseFirestore _db;

  @override
  Future<ProviderProfile?> getProvider(String id) async {
    final doc = await _db.collection('providers').doc(id).get();
    if (!doc.exists) return null;
    return ProviderProfile.fromJson({...doc.data()!, 'uid': doc.id});
  }

  @override
  Future<void> updateProvider(String id, Map<String, dynamic> fields) => _db
      .collection('providers')
      .doc(id)
      .update({...fields, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  Stream<ProviderProfile?> watchProvider(String id) => const Stream.empty();
  @override
  Future<PageResult<ProviderProfile>> fetchPopular({
    required String city,
    String? commune,
    Object? cursor,
  }) async => const PageResult(items: [], hasMore: false);
  @override
  Future<void> createProvider(ProviderProfile profile) async {}
  @override
  Future<void> resubmit(String id) async {}
}
