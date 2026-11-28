import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/features/listings/data/firestore_listing_repository.dart';
import 'package:kazi/features/listings/domain/listing_repository.dart';
import 'package:kazi/features/provider_profile/application/dashboard_controller.dart';
import 'package:kazi/features/provider_profile/data/firestore_provider_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late DashboardController ctrl;

  setUp(() {
    db = FakeFirebaseFirestore();
    ctrl = DashboardController(
      FirestoreProviderRepository(db),
      FirestoreListingRepository(db),
    );
  });

  tearDown(() => ctrl.dispose());

  Future<void> seedProvider() async {
    await db.collection('providers').doc('uid1').set({
      'displayName': 'Alice',
      'bio': '',
      'categoryIds': ['plomberie'],
      'city': 'kinshasa',
      'baseCommune': 'gombe',
      'communes': ['gombe'],
      'whatsappNumber': '+243810000000',
      'yearsExperience': 2,
      'portfolio': <Map<String, dynamic>>[],
      'status': 'approved',
      'verified': false,
      'ratingAvg': 4.5,
      'ratingCount': 10,
      'ratingSum': 45,
      'listingCount': 2,
      'createdAt': null,
      'updatedAt': null,
    });
  }

  Future<void> seedListing(String id, String status) async {
    await db.collection('listings').doc(id).set({
      'providerId': 'uid1',
      'title': 'Service $id',
      'description': '',
      'categoryId': 'plomberie',
      'priceType': 'fixed',
      'priceAmount': 100.0,
      'currency': 'USD',
      'photos': <Map<String, dynamic>>[],
      'city': 'kinshasa',
      'communes': ['gombe'],
      'status': status,
      'visible': status == 'active',
    });
  }

  test('loads provider profile on init', () async {
    await seedProvider();
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    expect(ctrl.isLoading, isFalse);
    expect(ctrl.profile?.displayName, 'Alice');
    expect(ctrl.profile?.status, ProviderStatus.approved);
  });

  test('loads listings on init', () async {
    await seedProvider();
    await seedListing('l1', 'active');
    await seedListing('l2', 'draft');
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    expect(ctrl.isLoadingListings, isFalse);
    expect(ctrl.listings.length, 2);
  });

  test('no listings shows empty list', () async {
    await seedProvider();
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    expect(ctrl.listings, isEmpty);
  });

  test('pauseListing sets status to paused', () async {
    await seedListing('l1', 'active');
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    await ctrl.pauseListing('l1');

    final doc = await db.collection('listings').doc('l1').get();
    expect(doc.data()!['status'], 'paused');
  });

  test('resumeListing sets status to active', () async {
    await seedListing('l1', 'paused');
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    await ctrl.resumeListing('l1');

    final doc = await db.collection('listings').doc('l1').get();
    expect(doc.data()!['status'], 'active');
  });

  test('deleteListing removes the document', () async {
    await seedListing('l1', 'draft');
    ctrl.init('uid1');
    await Future<void>.delayed(Duration.zero);

    await ctrl.deleteListing('l1');
    await Future<void>.delayed(Duration.zero);

    final snap = await db.collection('listings').get();
    expect(snap.docs, isEmpty);
  });

  group('action results and states', () {
    test('pause / resume / delete report success', () async {
      await seedListing('l1', 'active');
      ctrl.init('uid1');
      await Future<void>.delayed(Duration.zero);

      final paused = await ctrl.pauseListing('l1');
      expect(paused.isSuccess, isTrue);
      expect(paused.action, ListingAction.pause);

      final resumed = await ctrl.resumeListing('l1');
      expect(resumed.isSuccess, isTrue);
      expect(resumed.action, ListingAction.resume);

      final deleted = await ctrl.deleteListing('l1');
      expect(deleted.isSuccess, isTrue);
      expect(deleted.action, ListingAction.delete);
    });

    test(
      'a failing repository yields a failure result, not an exception',
      () async {
        final failing = DashboardController(
          FirestoreProviderRepository(db),
          _FailingListingRepository(db, const PermissionDeniedException()),
        );
        addTearDown(failing.dispose);

        final r = await failing.pauseListing('l1');
        expect(r.isSuccess, isFalse);
        expect(r.error, isA<PermissionDeniedException>());
        expect(failing.isBusy('l1'), isFalse);
      },
    );

    test('isBusy is true while an action is in flight', () async {
      await seedListing('l1', 'active');
      ctrl.init('uid1');
      await Future<void>.delayed(Duration.zero);

      final future = ctrl.pauseListing('l1');
      expect(ctrl.isBusy('l1'), isTrue);
      await future;
      expect(ctrl.isBusy('l1'), isFalse);
    });

    test('a listings query error is surfaced, and retry recovers', () async {
      final repo = _FlakyWatchRepository(db);
      final c = DashboardController(FirestoreProviderRepository(db), repo);
      addTearDown(c.dispose);

      c.init('uid1');
      await Future<void>.delayed(Duration.zero);
      expect(c.listingsError, isA<UnknownException>());
      expect(c.isLoadingListings, isFalse);

      repo.fail = false;
      await seedListing('l1', 'active');
      c.retryListings();
      await Future<void>.delayed(Duration.zero);
      expect(c.listingsError, isNull);
      expect(c.listings.length, 1);
    });
  });

  group('listing limit (config/limits)', () {
    test('defaults to 10 when config/limits is missing', () async {
      await seedProvider();
      ctrl.init('uid1');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.maxListings, 10);
      expect(ctrl.limitReached, isFalse);
    });

    test('reads maxListingsPerProvider from config/limits', () async {
      await db.collection('config').doc('limits').set({
        'maxListingsPerProvider': 2,
      });
      await seedProvider(); // listingCount: 2
      ctrl.init('uid1');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.maxListings, 2);
      expect(ctrl.usedListings, 2);
      expect(ctrl.limitReached, isTrue);
    });

    test('3 of 10 is under the limit', () async {
      await seedProvider();
      for (final id in ['a', 'b', 'c']) {
        await seedListing(id, 'active');
      }
      ctrl.init('uid1');
      await Future<void>.delayed(Duration.zero);

      expect(ctrl.usedListings, 3);
      expect(ctrl.limitReached, isFalse);
    });

    test(
      'only active + paused count; drafts and over_limit listings do not',
      () async {
        await seedProvider();
        await db.collection('providers').doc('uid1').update({
          'listingCount': 0,
        });
        await seedListing('a', 'active');
        await seedListing('b', 'paused');
        await seedListing('c', 'draft');
        await seedListing('d', 'draft');
        await seedListing('e', 'active');
        await db.collection('listings').doc('e').update({
          'visible': false,
          'moderation': 'hidden',
          'moderationReason': 'over_limit',
        });
        ctrl.init('uid1');
        await Future<void>.delayed(Duration.zero);

        expect(ctrl.listings.length, 5);
        expect(ctrl.usedListings, 2);
        expect(ctrl.limitReached, isFalse);
      },
    );

    test(
      'server listingCount counts even before the local list catches up',
      () async {
        await seedProvider(); // listingCount: 2, no listing docs
        ctrl.init('uid1');
        await Future<void>.delayed(Duration.zero);

        expect(ctrl.usedListings, 2);
      },
    );
  });
}

class _FailingListingRepository extends FirestoreListingRepository {
  const _FailingListingRepository(super.db, this.error);
  final AppException error;

  @override
  Future<void> setStatus(String id, ListingStatus status) async => throw error;

  @override
  Future<void> delete(String id) async => throw error;
}

class _FlakyWatchRepository extends FirestoreListingRepository {
  _FlakyWatchRepository(super.db);
  bool fail = true;

  @override
  Stream<List<Listing>> watchMine(String uid) => fail
      ? Stream<List<Listing>>.error(const UnknownException('index'))
      : super.watchMine(uid);
}
