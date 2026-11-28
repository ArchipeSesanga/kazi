import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/catalog/application/catalog_controller.dart';
import 'package:kazi/features/catalog/data/firestore_catalog_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<FirestoreCatalogRepository> _repo(FakeFirebaseFirestore db) async {
  SharedPreferences.setMockInitialValues({});
  return FirestoreCatalogRepository(db, await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a not-yet-seeded database falls back to the bundled taxonomy',
    () async {
      final repo = await _repo(FakeFirebaseFirestore());
      final cats = await repo.getCategories();
      expect(cats, hasLength(23));
      expect(cats.first.id, 'plomberie');
      expect(cats.last.id, 'autres'); // always last
      expect(cats.where((c) => c.featured), hasLength(8));
      expect(cats.first.label('fr'), 'Plomberie');
      expect(cats.first.label('en'), 'Plumbing');
      expect(cats.first.synonyms['fr'], contains('plombier'));
      expect(cats.first.synonyms['ln'], isEmpty);
    },
  );

  test('reads the new document shape and drops retired categories', () async {
    final db = FakeFirebaseFirestore();
    Future<void> put(
      String id,
      int order, {
      bool active = true,
      bool featured = false,
    }) => db.collection('categories').doc(id).set({
      'names': {'fr': id, 'en': id},
      'iconKey': 'plumbing',
      'order': order,
      'featured': featured,
      'active': active,
      'synonyms': {
        'fr': ['a'],
        'en': ['b'],
        'ln': <String>[],
        'sw': <String>[],
      },
      'listingCount': 3,
    });
    await put('b', 2);
    await put('a', 1, featured: true);
    await put('old', 3, active: false);
    final cats = await (await _repo(db)).getCategories();
    expect(cats.map((c) => c.id), ['a', 'b']); // ordered, retired removed
    expect(cats.first.featured, isTrue);
    expect(cats.first.listingCount, 3);
  });

  test(
    'Home shows the 8 featured categories; the picker offers every active one',
    () async {
      final ctrl = CatalogController(await _repo(FakeFirebaseFirestore()));
      await ctrl.load();
      expect(ctrl.featured, hasLength(8));
      expect(
        ctrl.featured.map((c) => c.id),
        containsAll([
          'plomberie',
          'electricite',
          'menage',
          'coiffure',
          'couture',
          'telephones',
          'mecanique-auto',
          'cours',
        ]),
      );
      expect(ctrl.selectable, hasLength(23));
      expect(
        ctrl.categoryById('froid-clim')?.label('fr'),
        'Frigo & climatisation',
      );
      expect(ctrl.categoryById('unknown'), isNull);
    },
  );
}
