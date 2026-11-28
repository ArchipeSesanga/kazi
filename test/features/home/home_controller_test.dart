import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/core/models/listing.dart';
import 'package:kazi/core/state/paged_state.dart';
import 'package:kazi/features/home/application/home_controller.dart';
import 'package:kazi/features/provider_profile/domain/provider_repository.dart';
import 'package:kazi/features/search/domain/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockProviders extends Mock implements ProviderRepository {}

class _MockSearch extends Mock implements SearchRepository {}

Listing _listing(String id) => Listing(
  id: id,
  providerId: 'p$id',
  title: 'Service $id',
  categoryId: 'plomberie',
  priceType: PriceType.quote,
  city: 'kinshasa',
  visible: true,
);

void main() {
  late _MockProviders providers;
  late _MockSearch search;

  setUpAll(() => registerFallbackValue(const SearchQuery()));

  setUp(() {
    providers = _MockProviders();
    search = _MockSearch();
    when(
      () => providers.fetchPopular(
        city: any(named: 'city'),
        commune: any(named: 'commune'),
      ),
    ).thenAnswer((_) async => const PageResult(items: [], hasMore: false));
  });

  test(
    'loads recent listings with the "recent" sort (publishedAt desc)',
    () async {
      when(() => search.search(any(), cursor: any(named: 'cursor'))).thenAnswer(
        (_) async =>
            PageResult(items: [_listing('1'), _listing('2')], hasMore: false),
      );
      final ctrl = HomeController(providers, search);
      await ctrl.load();

      expect(ctrl.recentListings.map((l) => l.id), ['1', '2']);
      expect(ctrl.recentError, isNull);
      final q =
          verify(
                () => search.search(captureAny(), cursor: any(named: 'cursor')),
              ).captured.single
              as SearchQuery;
      expect(q.sort, SearchSort.recent);
      expect(q.commune, isNull);
    },
  );

  test('a query failure is surfaced instead of an empty list', () async {
    when(() => search.search(any(), cursor: any(named: 'cursor')))
        .thenThrow(const NetworkException());
    final ctrl = HomeController(providers, search);
    await ctrl.load();

    expect(ctrl.recentError, isA<NetworkException>());
    expect(ctrl.recentListings, isEmpty);
    expect(ctrl.isLoadingRecent, isFalse);
  });

  test('keeps at most 10 recent listings', () async {
    when(() => search.search(any(), cursor: any(named: 'cursor'))).thenAnswer(
      (_) async => PageResult(
        items: List.generate(20, (i) => _listing('$i')),
        hasMore: true,
      ),
    );
    final ctrl = HomeController(providers, search);
    await ctrl.load();
    expect(ctrl.recentListings.length, 10);
  });
}
