import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/listing.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../block/application/block_controller.dart';
import '../../listings/presentation/listing_result_tile.dart';
import '../../search/application/search_results_controller.dart';
import '../../search/domain/search_repository.dart';
import '../application/catalog_controller.dart';

/// The listings of one category, best rated first. An empty category shows a
/// friendly state with a button that starts a listing in this category.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final SearchResultsController _ctrl;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = SearchResultsController(
      context.read<SearchRepository>(),
      SearchQuery(categoryId: widget.categoryId),
    )..init();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _publishHere() => context.push(
    '${Routes.providerNewListing}?cat=${Uri.encodeQueryComponent(widget.categoryId)}',
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final category = context.watch<CatalogController>().categoryById(
      widget.categoryId,
    );
    final title = category?.label(locale) ?? l.categoryUnknown;

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ChangeNotifierProvider.value(
              value: _ctrl,
              child: Consumer<SearchResultsController>(
                builder: (ctx, ctrl, _) {
                  final state = ctrl.state;
                  if (state.isLoadingFirst) return const _Skeleton();
                  final blocked = ctx.watch<BlockController>();
                  final items = state.items
                      .where((i) => !blocked.isBlocked(i.providerId))
                      .toList();
                  if (state.error != null && items.isEmpty) {
                    return ErrorView(
                      message: state.error is NetworkException
                          ? l.errorNetwork
                          : l.errorUnknown,
                      onRetry: ctrl.refresh,
                      retryLabel: l.buttonRetry,
                    );
                  }
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: categoryIconFor(category?.iconKey),
                      message: l.categoryEmptyMessage(title),
                      actionLabel: l.categoryEmptyAction,
                      onAction: _publishHere,
                    );
                  }
                  return _List(
                    items: items,
                    ctrl: ctrl,
                    scroll: _scroll,
                    locale: locale,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.ctrl,
    required this.scroll,
    required this.locale,
  });

  final List<Listing> items;
  final SearchResultsController ctrl;
  final ScrollController scroll;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final state = ctrl.state;
    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: ListView.separated(
        controller: scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(KaziSpacing.screenPadding),
        itemCount: items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: KaziSpacing.md),
        itemBuilder: (ctx, i) {
          if (i == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: KaziSpacing.xl),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          final listing = items[i];
          return ListingResultTile(
            listing: listing,
            locale: locale,
            onTap: () => context.push(Routes.listingDetail(listing.id)),
          );
        },
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(KaziSpacing.screenPadding),
    children: [
      for (var i = 0; i < 4; i++) ...const [
        SkeletonBox(height: 88, width: double.infinity),
        SizedBox(height: KaziSpacing.md),
      ],
    ],
  );
}
