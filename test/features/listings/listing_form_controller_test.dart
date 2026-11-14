import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/data/firebase_auth_repository.dart';
import 'package:kazi/features/auth/data/firebase_user_repository.dart';
import 'package:kazi/features/listings/application/listing_form_controller.dart';
import 'package:kazi/features/listings/data/firestore_listing_repository.dart';
import 'package:kazi/features/provider_profile/domain/media_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late FakeFirebaseFirestore fakeDb;
  late FirestoreListingRepository listingRepo;
  late _MockMediaRepository mediaRepo;
  late SessionController session;

  setUp(() async {
    fakeDb = FakeFirebaseFirestore();
    listingRepo = FirestoreListingRepository(fakeDb);
    mediaRepo = _MockMediaRepository();

    final auth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid1'));
    session = SessionController(
      FirebaseAuthRepository(auth),
      FirebaseUserRepository(fakeDb, auth),
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
}
