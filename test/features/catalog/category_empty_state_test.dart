import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/models/listing.dart';
import 'package:kazi/core/services/connectivity_controller.dart';
import 'package:kazi/core/state/paged_state.dart';
import 'package:kazi/features/block/application/block_controller.dart';
import 'package:kazi/features/block/domain/block_repository.dart';
import 'package:kazi/features/catalog/application/catalog_controller.dart';
import 'package:kazi/features/catalog/data/firestore_catalog_repository.dart';
import 'package:kazi/features/catalog/presentation/category_screen.dart';
import 'package:kazi/features/search/domain/search_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Search implements SearchRepository {
  _Search(this.items);
  final List<Listing> items;
  SearchQuery? last;

  @override
  Future<PageResult<Listing>> search(
    SearchQuery query, {
    Object? cursor,
  }) async {
    last = query;
    return PageResult(items: items, hasMore: false);
  }
}

class _Online extends ChangeNotifier implements ConnectivityController {
  @override
  bool get isOnline => true;
}

class _Blocks implements BlockRepository {
  @override
  Stream<Set<String>> watchBlockedUids(String uid) => Stream.value(<String>{});
  @override
  Future<void> block(String uid, String blockedUid) async {}
  @override
  Future<void> unblock(String uid, String blockedUid) async {}
}

Future<_Search> _pump(
  WidgetTester tester,
  String categoryId, {
  List<Listing> items = const [],
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final catalog = CatalogController(
    FirestoreCatalogRepository(
      FakeFirebaseFirestore(),
      await SharedPreferences.getInstance(),
    ),
  );
  await tester.runAsync(catalog.load);
  final search = _Search(items);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => CategoryScreen(categoryId: categoryId),
      ),
      GoRoute(
        path: '/provider/listings/new',
        builder: (_, state) => Scaffold(
          body: Text(
            'new listing form cat=${state.uri.queryParameters['cat']}',
          ),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<SearchRepository>.value(value: search),
        ChangeNotifierProvider<ConnectivityController>.value(value: _Online()),
        ChangeNotifierProvider<CatalogController>.value(value: catalog),
        ChangeNotifierProvider<BlockController>(
          create: (_) => BlockController(_Blocks()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return search;
}

void main() {
  testWidgets(
    'an empty category: friendly state and a button that starts a listing in it',
    (tester) async {
      final search = await _pump(tester, 'plomberie');
      expect(search.last?.categoryId, 'plomberie');
      expect(find.text('Plomberie'), findsWidgets); // app bar
      expect(
        find.textContaining('Aucun prestataire dans « Plomberie »'),
        findsOneWidget,
      );
      expect(
        find.text('Soyez le premier à proposer ce service'),
        findsOneWidget,
      );

      await tester.tap(find.text('Soyez le premier à proposer ce service'));
      await tester.pumpAndSettle();
      // The listing form opens with this category pre-selected.
      expect(find.text('new listing form cat=plomberie'), findsOneWidget);
    },
  );

  testWidgets('an unknown or retired category still shows a safe empty state', (
    tester,
  ) async {
    await _pump(tester, 'plus-active');
    expect(find.text('Catégorie introuvable'), findsOneWidget);
    expect(find.text('Soyez le premier à proposer ce service'), findsOneWidget);
  });
}
