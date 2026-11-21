import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/listings/application/listing_form_controller.dart';
import 'package:kazi/features/listings/data/firestore_listing_repository.dart';
import 'package:kazi/features/listings/domain/listing_repository.dart';
import 'package:kazi/features/provider_profile/domain/media_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockMediaRepository extends Mock implements MediaRepository {}

class _FakeXFile extends Fake implements XFile {
  _FakeXFile(this.path);
  @override
  final String path;
}

void main() {
  late FakeFirebaseFirestore fakeDb;
  late FirestoreListingRepository listingRepo;
  late _MockMediaRepository mediaRepo;
  late SessionController session;

  setUpAll(() {
    registerFallbackValue(_FakeXFile('/fallback'));
    registerFallbackValue(MediaKind.listingPhoto);
  });

  setUp(() async {
    fakeDb = FakeFirebaseFirestore();
    listingRepo = FirestoreListingRepository(fakeDb);
    mediaRepo = _MockMediaRepository();

    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    session = SessionController(
      FirebaseUserRepository(fakeDb, auth),
      FirebaseAuthRepository(auth),
    );
    // Let session resolve.
    await Future<void>.delayed(Duration.zero);
  });

  ListingFormController makeCtrl({String? listingId}) =>
      ListingFormController(listingRepo, mediaRepo, session, listingId: listingId);

  group('validation', () {
    test('fails when title is too short', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('hi');
      ctrl.setCategory('plomberie');
      ctrl.toggleCommune('gombe');
      await ctrl.publish();
      expect(ctrl.titleError, isNotNull);
      expect(ctrl.savedStatus, isNull);
    });

    test('fails when category is missing', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Plomberie rapide à domicile');
      ctrl.toggleCommune('gombe');
      await ctrl.publish();
      expect(ctrl.categoryError, isNotNull);
      expect(ctrl.savedStatus, isNull);
    });

    test('fails when no communes selected', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Plomberie rapide à domicile');
      ctrl.setCategory('plomberie');
      await ctrl.publish();
      expect(ctrl.communeError, isNotNull);
      expect(ctrl.savedStatus, isNull);
    });
  });

  group('draft creation', () {
    test('creates a Firestore doc and returns an id on saveDraft', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Coiffure femme');
      ctrl.setCategory('coiffure_beaute');
      ctrl.toggleCommune('gombe');
      await ctrl.saveDraft();

      expect(ctrl.savedStatus, ListingStatus.draft);
      expect(ctrl.listingId, isNotNull);

      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first['status'], 'draft');
    });

    test('publishes listing by setting status=active', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Menuiserie sur mesure');
      ctrl.setCategory('menuiserie');
      ctrl.toggleCommune('lemba');
      await ctrl.publish();

      expect(ctrl.savedStatus, ListingStatus.active);

      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.first['status'], 'active');
      expect(snap.docs.first['priceType'], 'fixed');
    });

    test('reuses existing draft id on second publish', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Menuiserie sur mesure');
      ctrl.setCategory('menuiserie');
      ctrl.toggleCommune('lemba');
      await ctrl.saveDraft();
      final firstId = ctrl.listingId;

      ctrl.setTitle('Menuiserie sur mesure — édition spéciale');
      await ctrl.publish();

      expect(ctrl.listingId, equals(firstId));
      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.length, 1);
    });
  });

  group('price type', () {
    test('quote clears priceAmount field', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Jardinage professionnel');
      ctrl.setCategory('jardinage');
      ctrl.toggleCommune('ngaliema');
      ctrl.setPriceAmount('50');
      ctrl.setPriceType(PriceType.quote);
      await ctrl.publish();

      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.first.data().containsKey('priceAmount'), isFalse);
    });

    test('fixed keeps priceAmount', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('Jardinage professionnel');
      ctrl.setCategory('jardinage');
      ctrl.toggleCommune('ngaliema');
      ctrl.setPriceType(PriceType.fixed);
      ctrl.setPriceAmount('200');
      await ctrl.publish();

      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.first['priceAmount'], 200.0);
    });
  });

  group('commune toggle', () {
    test('adds and removes communes', () {
      final ctrl = makeCtrl();
      ctrl.toggleCommune('gombe');
      ctrl.toggleCommune('lemba');
      expect(ctrl.communes, containsAll(['gombe', 'lemba']));
      ctrl.toggleCommune('gombe');
      expect(ctrl.communes, isNot(contains('gombe')));
    });

    test('caps at 10 communes', () {
      final ctrl = makeCtrl();
      for (var i = 0; i < 12; i++) {
        ctrl.toggleCommune('c$i');
      }
      expect(ctrl.communes.length, 10);
    });
  });

  group('edit mode', () {
    test('loads existing listing on init', () async {
      await fakeDb.collection('listings').doc('listing1').set({
        'providerId': 'uid1',
        'title': 'Réparation téléphone',
        'description': 'Toutes marques',
        'categoryId': 'reparation_telephones',
        'priceType': 'fixed',
        'priceAmount': 1000.0,
        'currency': 'CDF',
        'photos': <Map<String, dynamic>>[],
        'city': 'kinshasa',
        'communes': ['gombe'],
        'status': 'active',
        'visible': true,
        'moderation': 'ok',
      });

      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();

      expect(ctrl.title, 'Réparation téléphone');
      expect(ctrl.categoryId, 'reparation_telephones');
      expect(ctrl.currency, Currency.cdf);
      expect(ctrl.communes, ['gombe']);
    });
  });

  group('upload-on-submit', () {
    void fillValidForm(ListingFormController ctrl) {
      ctrl.setTitle('Plomberie rapide à domicile');
      ctrl.setCategory('plomberie');
      ctrl.toggleCommune('gombe');
    }

    test('invalid form → zero uploads', () async {
      final ctrl = makeCtrl();
      ctrl.setTitle('hi'); // too short
      ctrl.setCategory('plomberie');
      ctrl.toggleCommune('gombe');

      await ctrl.addPhoto(_FakeXFile('/photo1.jpg'));
      await ctrl.publish();

      expect(ctrl.titleError, isNotNull);
      expect(ctrl.savedStatus, isNull);
      verifyNever(() => mediaRepo.upload(any(), any(),
          listingId: any(named: 'listingId'),
          onProgress: any(named: 'onProgress')));
    });

    test('upload fails on photo 2 → photo 1 kept, retry uploads only photo 2',
        () async {
      final ctrl = makeCtrl();
      fillValidForm(ctrl);

      await ctrl.addPhoto(_FakeXFile('/photo1.jpg'));
      await ctrl.addPhoto(_FakeXFile('/photo2.jpg'));
      expect(ctrl.photos.length, 2);

      var uploadCallCount = 0;
      when(() => mediaRepo.upload(any(), any(),
          listingId: any(named: 'listingId'),
          onProgress: any(named: 'onProgress'))).thenAnswer((_) async {
        uploadCallCount++;
        if (uploadCallCount == 2) {
          throw const NetworkException();
        }
        return UploadedImage(
            path: 'media/uid1/listings/draft1/photo$uploadCallCount.jpg',
            url: 'https://storage/photo$uploadCallCount.jpg');
      });

      await ctrl.publish();

      // Photo 1 was uploaded, photo 2 failed.
      expect(ctrl.photos[0].isUploaded, isTrue);
      expect(ctrl.photos[1].hasError, isTrue);
      expect(ctrl.error, isNotNull);
      expect(ctrl.savedStatus, isNull);

      // Retry: only photo 2 should upload.
      uploadCallCount = 0;
      when(() => mediaRepo.upload(any(), any(),
          listingId: any(named: 'listingId'),
          onProgress: any(named: 'onProgress'))).thenAnswer((_) async {
        uploadCallCount++;
        return const UploadedImage(
            path: 'media/uid1/listings/draft1/photo2.jpg',
            url: 'https://storage/photo2_retry.jpg');
      });

      ctrl.clearError();
      await ctrl.publish();

      expect(uploadCallCount, 1);
      expect(ctrl.photos[0].isUploaded, isTrue);
      expect(ctrl.photos[1].isUploaded, isTrue);
      expect(ctrl.savedStatus, ListingStatus.active);
    });

    test('double tap publish → one draft', () async {
      final ctrl = makeCtrl();
      fillValidForm(ctrl);

      // Publish twice concurrently — isSaving guard prevents second call.
      final f1 = ctrl.publish();
      final f2 = ctrl.publish(); // should be no-op since isSaving = true
      await Future.wait([f1, f2]);

      final snap = await fakeDb.collection('listings').get();
      expect(snap.docs.length, 1);
    });

    test('discard draft deletes doc and photos', () async {
      final ctrl = makeCtrl();
      fillValidForm(ctrl);

      when(() => mediaRepo.upload(any(), any(),
          listingId: any(named: 'listingId'),
          onProgress: any(named: 'onProgress'))).thenAnswer((_) async {
        return const UploadedImage(
            path: 'media/uid1/listings/draft1/photo1.jpg',
            url: 'https://storage/photo1.jpg');
      });
      when(() => mediaRepo.delete(any())).thenAnswer((_) async {});

      await ctrl.addPhoto(_FakeXFile('/photo1.jpg'));
      await ctrl.saveDraft();

      expect(ctrl.hasDraft, isTrue);
      final draftId = ctrl.listingId!;

      final before = await fakeDb.collection('listings').doc(draftId).get();
      expect(before.exists, isTrue);

      await ctrl.discardDraft();

      expect(ctrl.hasDraft, isFalse);
      final after = await fakeDb.collection('listings').doc(draftId).get();
      expect(after.exists, isFalse);
      verify(() => mediaRepo.delete('media/uid1/listings/draft1/photo1.jpg'))
          .called(1);
    });
  });

  group('edit existing listing', () {
    Future<void> seedListing(String status, {List<Map<String, String>>? photos}) =>
        fakeDb.collection('listings').doc('listing1').set({
          'providerId': 'uid1',
          'title': 'Réparation téléphone',
          'description': '',
          'categoryId': 'reparation_telephones',
          'priceType': 'fixed',
          'priceAmount': 1000.0,
          'currency': 'CDF',
          'photos': photos ?? <Map<String, String>>[],
          'city': 'kinshasa',
          'communes': ['gombe'],
          'status': status,
          'visible': status == 'active',
          'moderation': 'ok',
        });

    test('save() updates fields and keeps an active listing active', () async {
      await seedListing('active');
      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();
      expect(ctrl.preservesStatus, isTrue);

      ctrl.setTitle('Réparation téléphone express');
      ctrl.setPriceAmount('1500');
      await ctrl.save();

      expect(ctrl.error, isNull);
      expect(ctrl.savedStatus, ListingStatus.active);
      expect(ctrl.savedAsUpdate, isTrue);
      final doc = await fakeDb.collection('listings').doc('listing1').get();
      expect(doc['title'], 'Réparation téléphone express');
      expect(doc['priceAmount'], 1500.0);
      expect(doc['status'], 'active');
    });

    test('save() keeps a paused listing paused', () async {
      await seedListing('paused');
      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();

      ctrl.setDescription('Toutes marques');
      await ctrl.save();

      final doc = await fakeDb.collection('listings').doc('listing1').get();
      expect(doc['status'], 'paused');
      expect(doc['description'], 'Toutes marques');
    });

    test('a draft is not status-preserving (Draft / Publish buttons)', () async {
      await seedListing('draft');
      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();
      expect(ctrl.preservesStatus, isFalse);
    });

    test('removed photos are deleted from Storage only after a successful save',
        () async {
      await seedListing('active', photos: [
        {'id': 'p1', 'path': 'media/uid1/listings/listing1/p1.jpg', 'url': 'https://s/p1'},
        {'id': 'p2', 'path': 'media/uid1/listings/listing1/p2.jpg', 'url': 'https://s/p2'},
      ]);
      when(() => mediaRepo.delete(any())).thenAnswer((_) async {});

      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();
      ctrl.removePhoto('p1');

      // Nothing is deleted while the user is still editing.
      verifyNever(() => mediaRepo.delete(any()));

      await ctrl.save();

      verify(() => mediaRepo.delete('media/uid1/listings/listing1/p1.jpg')).called(1);
      verifyNever(() => mediaRepo.delete('media/uid1/listings/listing1/p2.jpg'));
      final doc = await fakeDb.collection('listings').doc('listing1').get();
      expect((doc['photos'] as List).length, 1);
    });

    test('a failed save keeps the removed photos in Storage and shows the error',
        () async {
      await seedListing('active', photos: [
        {'id': 'p1', 'path': 'media/uid1/listings/listing1/p1.jpg', 'url': 'https://s/p1'},
      ]);
      final failing = ListingFormController(
        _FailingUpdateRepository(fakeDb),
        mediaRepo,
        session,
        listingId: 'listing1',
      );
      await failing.init();
      failing.removePhoto('p1');

      await failing.save();

      expect(failing.error, isA<NetworkException>());
      expect(failing.savedStatus, isNull);
      expect(failing.isSaving, isFalse);
      verifyNever(() => mediaRepo.delete(any()));
    });
  });

  group('listing limit', () {
    Future<void> seedQuota({required int count, int? max}) async {
      await fakeDb.collection('providers').doc('uid1').set({'listingCount': count});
      if (max != null) {
        await fakeDb.collection('config').doc('limits').set({'maxListingsPerProvider': max});
      }
    }

    void fillValidForm(ListingFormController ctrl) {
      ctrl.setTitle('Plomberie rapide à domicile');
      ctrl.setCategory('plomberie');
      ctrl.toggleCommune('gombe');
    }

    test('at the limit: explains it and creates nothing', () async {
      await seedQuota(count: 10, max: 10);
      final ctrl = makeCtrl();
      await ctrl.init();
      expect(ctrl.limitReached, isTrue);

      fillValidForm(ctrl);
      await ctrl.publish();

      expect(ctrl.error, isA<QuotaExceededException>());
      expect(ctrl.savedStatus, isNull);
      expect((await fakeDb.collection('listings').get()).docs, isEmpty);
    });

    test('at 9 of 10 the form is usable', () async {
      await seedQuota(count: 9, max: 10);
      final ctrl = makeCtrl();
      await ctrl.init();
      expect(ctrl.limitReached, isFalse);

      fillValidForm(ctrl);
      await ctrl.publish();
      expect(ctrl.savedStatus, ListingStatus.active);
    });

    test('publishing a draft at the limit is explained, saving it as draft is not blocked',
        () async {
      await seedQuota(count: 10, max: 10);
      await fakeDb.collection('listings').doc('draft1').set({
        'providerId': 'uid1', 'title': 'Brouillon', 'description': '',
        'categoryId': 'plomberie', 'priceType': 'quote', 'currency': 'USD',
        'photos': <Map<String, String>>[], 'city': 'kinshasa',
        'communes': ['gombe'], 'status': 'draft',
      });
      final ctrl = makeCtrl(listingId: 'draft1');
      await ctrl.init();
      await Future<void>.delayed(Duration.zero);
      expect(ctrl.quota?.reached, isTrue);

      await ctrl.publish();
      expect(ctrl.error, isA<QuotaExceededException>());
      var doc = await fakeDb.collection('listings').doc('draft1').get();
      expect(doc['status'], 'draft');

      ctrl.clearError();
      await ctrl.saveDraft();
      expect(ctrl.error, isNull);
      doc = await fakeDb.collection('listings').doc('draft1').get();
      expect(doc['status'], 'draft');
    });

    test('follows the configured max (raised to 25)', () async {
      await seedQuota(count: 10, max: 25);
      final ctrl = makeCtrl();
      await ctrl.init();
      expect(ctrl.limitReached, isFalse);
    });

    test('a denied create at the limit is reported as the limit, not a generic denial',
        () async {
      await seedQuota(count: 9, max: 10); // stale quota at init time
      final ctrl = ListingFormController(
        _DenyCreateRepository(fakeDb, onDeny: () => seedQuota(count: 10, max: 10)),
        mediaRepo,
        session,
      );
      await ctrl.init();
      expect(ctrl.limitReached, isFalse);

      fillValidForm(ctrl);
      await ctrl.publish();

      expect(ctrl.error, isA<QuotaExceededException>());
    });

    test('editing an existing listing is never blocked by the limit', () async {
      await seedQuota(count: 10, max: 10);
      await fakeDb.collection('listings').doc('listing1').set({
        'providerId': 'uid1', 'title': 'Réparation téléphone', 'description': '',
        'categoryId': 'plomberie', 'priceType': 'quote', 'currency': 'USD',
        'photos': <Map<String, String>>[], 'city': 'kinshasa',
        'communes': ['gombe'], 'status': 'active',
      });
      final ctrl = makeCtrl(listingId: 'listing1');
      await ctrl.init();
      expect(ctrl.limitReached, isFalse);
      await ctrl.save();
      expect(ctrl.error, isNull);
    });
  });
}

class _FailingUpdateRepository extends FirestoreListingRepository {
  const _FailingUpdateRepository(super.db);

  @override
  Future<void> update(String id, Map<String, dynamic> fields) async =>
      throw const NetworkException();
}

class _DenyCreateRepository extends FirestoreListingRepository {
  const _DenyCreateRepository(super.db, {required this.onDeny});
  final Future<void> Function() onDeny;

  @override
  Future<String> createDraft(Listing draft) async {
    await onDeny();
    throw const PermissionDeniedException();
  }
}
