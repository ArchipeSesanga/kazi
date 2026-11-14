import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/features/listings/data/firestore_listing_repository.dart';
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
}
