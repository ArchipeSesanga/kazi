import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/search/data/firestore_search_repository.dart';
import 'package:kazi/features/search/domain/search_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreSearchRepository repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = FirestoreSearchRepository(fakeFirestore);
  });

  Future<void> seedListing({
    required String id,
    String city = 'kinshasa',
    bool visible = true,
    String categoryId = 'cat1',
    bool providerVerified = false,
    double ratingAvg = 3.0,
    List<String> communes = const [],
    List<String> searchKeywords = const [],
    DateTime? publishedAt,
  }) async {
    await fakeFirestore.collection('listings').doc(id).set({
      'visible': visible,
      'city': city,
      'categoryId': categoryId,
      'providerVerified': providerVerified,
      'ratingAvg': ratingAvg,
      'communes': communes,
      'searchKeywords': searchKeywords,
      'publishedAt':
          publishedAt != null ? Timestamp.fromDate(publishedAt) : null,
      'title': id,
      'providerId': 'p1',
      'description': '',
      'priceType': 'from',
      'currency': 'USD',
      'status': 'active',
      'moderation': 'ok',
    });
  }

  group('base query (no keyword, no commune)', () {
    test('returns only visible listings in the given city', () async {
      await seedListing(id: 'l1');
      await seedListing(id: 'l2', visible: false);
      await seedListing(id: 'l3', city: 'lubumbashi');

      final result = await repo.search(const SearchQuery());

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('l1'));
      expect(ids, isNot(contains('l2')));
      expect(ids, isNot(contains('l3')));
    });

    test('orders by ratingAvg descending by default', () async {
      await seedListing(id: 'low', ratingAvg: 2.0);
      await seedListing(id: 'high', ratingAvg: 4.5);

      final result = await repo.search(const SearchQuery());

      final ids = result.items.map((l) => l.id).toList();
      expect(ids.indexOf('high'), lessThan(ids.indexOf('low')));
    });

    test('orders by publishedAt descending when sort=recent', () async {
      await seedListing(
        id: 'old',
        publishedAt: DateTime(2024),
        ratingAvg: 4.5,
      );
      await seedListing(
        id: 'new',
        publishedAt: DateTime(2024, 6),
        ratingAvg: 1.0,
      );

      final result =
          await repo.search(const SearchQuery(sort: SearchSort.recent));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids.indexOf('new'), lessThan(ids.indexOf('old')));
    });
  });

  group('category filter', () {
    test('returns only listings with matching categoryId', () async {
      await seedListing(id: 'plumb', categoryId: 'plumbing');
      await seedListing(id: 'elec', categoryId: 'electric');

      final result =
          await repo.search(const SearchQuery(categoryId: 'plumbing'));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('plumb'));
      expect(ids, isNot(contains('elec')));
    });
  });

  group('verifiedOnly filter — Firestore (no keyword/commune)', () {
    test('returns only verified listings', () async {
      await seedListing(id: 'verified', providerVerified: true);
      await seedListing(id: 'unverified');

      final result = await repo.search(const SearchQuery(verifiedOnly: true));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('verified'));
      expect(ids, isNot(contains('unverified')));
    });

    test('filters by both categoryId and verifiedOnly', () async {
      await seedListing(
          id: 'cv', categoryId: 'plumbing', providerVerified: true);
      await seedListing(id: 'cu', categoryId: 'plumbing');
      await seedListing(
          id: 'ov', categoryId: 'electric', providerVerified: true);

      final result = await repo.search(
        const SearchQuery(categoryId: 'plumbing', verifiedOnly: true),
      );

      expect(result.items.map((l) => l.id).toList(), equals(['cv']));
    });
  });

  group('commune filter — Firestore (no keyword)', () {
    test('returns only listings whose communes contain the given commune',
        () async {
      await seedListing(id: 'in', communes: ['gombe', 'ngaliema']);
      await seedListing(id: 'out', communes: ['matete']);

      final result =
          await repo.search(const SearchQuery(commune: 'gombe'));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('in'));
      expect(ids, isNot(contains('out')));
    });

    test('filters by both commune and categoryId', () async {
      await seedListing(
          id: 'match', categoryId: 'plumbing', communes: ['gombe']);
      await seedListing(
          id: 'wrongcat', categoryId: 'electric', communes: ['gombe']);
      await seedListing(
          id: 'wrongzone', categoryId: 'plumbing', communes: ['matete']);

      final result = await repo.search(
        const SearchQuery(commune: 'gombe', categoryId: 'plumbing'),
      );

      expect(result.items.map((l) => l.id).toList(), equals(['match']));
    });
  });

  group('keyword filter — Firestore array-contains', () {
    test('returns listings whose searchKeywords contain the token', () async {
      await seedListing(
          id: 'plumb',
          searchKeywords: ['plombier', 'plomb', 'plom', 'pl', 'plo']);
      await seedListing(
          id: 'elec', searchKeywords: ['electricite', 'electric', 'el']);

      final result =
          await repo.search(const SearchQuery(keyword: 'plombier'));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('plumb'));
      expect(ids, isNot(contains('elec')));
    });

    test('normalises diacritics before Firestore lookup', () async {
      await seedListing(
          id: 'elec',
          searchKeywords: ['electricite', 'electricit', 'electric', 'el']);

      final result =
          await repo.search(const SearchQuery(keyword: 'Électricité'));

      expect(result.items.map((l) => l.id), contains('elec'));
    });

    test('picks the longest token when keyword has multiple words', () async {
      // "fuite eau": tokens "fuite"(5) and "eau"(3) → longest is "fuite"
      await seedListing(id: 'fuite', searchKeywords: ['fuite', 'fuit', 'fu']);
      await seedListing(id: 'eau', searchKeywords: ['eau', 'ea']);

      final result =
          await repo.search(const SearchQuery(keyword: 'fuite eau'));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('fuite'));
    });

    test('filters by keyword and categoryId together', () async {
      await seedListing(
          id: 'match',
          categoryId: 'plumbing',
          searchKeywords: ['plombier']);
      await seedListing(
          id: 'wrongcat',
          categoryId: 'electric',
          searchKeywords: ['plombier']);

      final result = await repo.search(
        const SearchQuery(keyword: 'plombier', categoryId: 'plumbing'),
      );

      expect(result.items.map((l) => l.id).toList(), equals(['match']));
    });
  });

  group('client-side filters', () {
    test('commune is applied client-side when keyword is present', () async {
      await seedListing(
          id: 'in_zone',
          searchKeywords: ['plombier'],
          communes: ['gombe']);
      await seedListing(
          id: 'out_zone',
          searchKeywords: ['plombier'],
          communes: ['matete']);

      final result = await repo.search(
        const SearchQuery(keyword: 'plombier', commune: 'gombe'),
      );

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('in_zone'));
      expect(ids, isNot(contains('out_zone')));
    });

    test('minRating filters out listings below the threshold', () async {
      await seedListing(id: 'high', ratingAvg: 4.5);
      await seedListing(id: 'low');

      final result =
          await repo.search(const SearchQuery(minRating: 4.0));

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('high'));
      expect(ids, isNot(contains('low')));
    });

    test('verifiedOnly is applied client-side when keyword is present',
        () async {
      await seedListing(
          id: 'vp', searchKeywords: ['plombier'], providerVerified: true);
      await seedListing(id: 'up', searchKeywords: ['plombier']);

      final result = await repo.search(
        const SearchQuery(keyword: 'plombier', verifiedOnly: true),
      );

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('vp'));
      expect(ids, isNot(contains('up')));
    });

    test('verifiedOnly is applied client-side when commune is present',
        () async {
      await seedListing(
          id: 'vc', communes: ['gombe'], providerVerified: true);
      await seedListing(id: 'uc', communes: ['gombe']);

      final result = await repo.search(
        const SearchQuery(commune: 'gombe', verifiedOnly: true),
      );

      final ids = result.items.map((l) => l.id).toList();
      expect(ids, contains('vc'));
      expect(ids, isNot(contains('uc')));
    });
  });

  group('pagination', () {
    test('returns hasMore=false when fewer results than page size', () async {
      await seedListing(id: 'only');

      final result = await repo.search(const SearchQuery());

      expect(result.hasMore, isFalse);
    });

    test('auto-fetches extra pages until >= 10 client-side results', () async {
      // 15 ngaliema listings (ratingAvg 4.0 → appear in first Firestore page of 20)
      for (var i = 1; i <= 15; i++) {
        await seedListing(
          id: 'ng$i',
          communes: ['ngaliema'],
          searchKeywords: ['plombier'],
          ratingAvg: 4.0,
        );
      }
      // 10 gombe listings (ratingAvg 3.0 → sorted after ngaliema)
      for (var i = 1; i <= 10; i++) {
        await seedListing(
          id: 'go$i',
          communes: ['gombe'],
          searchKeywords: ['plombier'],
        );
      }
      // First page (20 docs): 15 ngaliema + 5 gombe → 5 pass commune filter < 10
      // → repo fetches one extra page: 5 more gombe → total 10 results.

      final result = await repo.search(
        const SearchQuery(keyword: 'plombier', commune: 'gombe'),
      );

      expect(result.items.length, 10);
      expect(result.items.every((l) => l.communes.contains('gombe')), isTrue);
    });

    test('returns a cursor that can be used to fetch the next page', () async {
      for (var i = 1; i <= 25; i++) {
        await seedListing(id: 'l$i', ratingAvg: i.toDouble());
      }

      final page1 = await repo.search(const SearchQuery());
      expect(page1.hasMore, isTrue);
      expect(page1.items.length, 20);

      final page2 =
          await repo.search(const SearchQuery(), cursor: page1.cursor);
      expect(page2.items.length, 5);
      expect(page2.hasMore, isFalse);

      final ids1 = page1.items.map((l) => l.id).toSet();
      final ids2 = page2.items.map((l) => l.id).toSet();
      expect(ids1.intersection(ids2), isEmpty);
    });
  });

  group('keyword normalization edge cases', () {
    test('stop words are ignored', () async {
      // "de la plomberie" → tokens ["plomberie"] (de/la are stop words)
      await seedListing(
          id: 'p', searchKeywords: ['plomberie', 'plomberi', 'plomber']);

      final result =
          await repo.search(const SearchQuery(keyword: 'de la plomberie'));

      expect(result.items.map((l) => l.id), contains('p'));
    });

    test('truncates long tokens to 15 characters', () async {
      // token "electromenagersuperlongword" → truncated to "electromenagers"
      await seedListing(id: 'e', searchKeywords: ['electromenagers']);

      final result = await repo
          .search(const SearchQuery(keyword: 'electromenagersuperlongword'));

      expect(result.items.map((l) => l.id), contains('e'));
    });

    test('falls back to base query when keyword reduces to only stop words',
        () async {
      await seedListing(id: 'any');

      final result =
          await repo.search(const SearchQuery(keyword: 'de la le'));

      expect(result.items.map((l) => l.id), contains('any'));
    });
  });
}
