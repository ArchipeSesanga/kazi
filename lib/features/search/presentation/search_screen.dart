import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_chip.dart';
import '../../../core/widgets/kazi_search_bar.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/provider_list_item.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../block/application/block_controller.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../search/domain/search_repository.dart';
import '../application/search_results_controller.dart';
import 'filters_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({this.initialQuery = const SearchQuery(), super.key});

  final SearchQuery initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textCtrl;
  late final ScrollController _scrollCtrl;
  late final SearchResultsController _ctrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.initialQuery.keyword ?? '');
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _ctrl = SearchResultsController(
      context.read<SearchRepository>(),
      widget.initialQuery,
    )..init();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _ctrl.loadMore();
    }
  }

  Future<void> _openFiltersSheet() async {
    final catalog = context.read<CatalogController>();
    final communes = catalog.cities.expand((c) => c.communes).toList();

    final result = await showModalBottomSheet<SearchQuery>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KaziRadius.sheet)),
      ),
      builder: (_) =>
          FiltersSheet(query: _ctrl.query, communes: communes),
    );
    if (result != null) {
      _ctrl.applyFiltersFromSheet(result);
    }
  }

  void _clearCommune() {
    final q = _ctrl.query;
    _ctrl.applyFiltersFromSheet(SearchQuery(
      keyword: q.keyword,
      categoryId: q.categoryId,
      city: q.city,
      verifiedOnly: q.verifiedOnly,
      minRating: q.minRating,
      sort: q.sort,
    ));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Scaffold(
        backgroundColor: KaziColors.surfaceAlt,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfflineBanner(),

              // App bar: back + search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KaziSpacing.sm,
                  KaziSpacing.sm,
                  KaziSpacing.screenPadding,
                  KaziSpacing.sm,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft,
                          color: KaziColors.ink),
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: KaziSearchBar(
                        hint: l.exploreSearchHint,
                        controller: _textCtrl,
                        autofocus: true,
                        onChanged: _ctrl.updateKeyword,
                        onFilterTap: _openFiltersSheet,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips
              Consumer<SearchResultsController>(
                builder: (_, ctrl, __) =>
                    _FilterChips(query: ctrl.query, onClearCommune: _clearCommune),
              ),

              // Result count
              Consumer<SearchResultsController>(
                builder: (ctx, ctrl, __) {
                  final state = ctrl.state;
                  if (state.isLoadingFirst || state.error != null) {
                    return const SizedBox.shrink();
                  }
                  final blocked = ctx.watch<BlockController>();
                  final count = state.items
                      .where((item) => !blocked.isBlocked(item.providerId))
                      .length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaziSpacing.screenPadding,
                      vertical: KaziSpacing.sm,
                    ),
                    child: Text(
                      l.searchResultCount(count),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: KaziColors.muted,
                      ),
                    ),
                  );
                },
              ),

              // Main content
              Expanded(
                child: Consumer<SearchResultsController>(
                  builder: (ctx, ctrl, __) {
                    final state = ctrl.state;
                    if (state.isLoadingFirst) return const _Skeleton();
                    final blocked = ctx.watch<BlockController>();
                    final visibleItems = state.items
                        .where((item) => !blocked.isBlocked(item.providerId))
                        .toList();
                    if (state.error != null && visibleItems.isEmpty) {
                      return _buildError(state.error!, ctrl.refresh, l);
                    }
                    if (visibleItems.isEmpty) {
                      return EmptyState(
                        icon: LucideIcons.searchX,
                        message: l.searchEmpty,
                        actionLabel: l.searchEmptyAction,
                        onAction: _clearCommune,
                      );
                    }
                    return _buildList(visibleItems, state, ctrl, l);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(
      AppException err, VoidCallback retry, AppLocalizations l) {
    final msg = err is NetworkException ? l.errorNetwork : l.errorUnknown;
    return ErrorView(message: msg, onRetry: retry, retryLabel: l.buttonRetry);
  }

  Widget _buildList(
    List<Listing> items,
    PagedState<Listing> state,
    SearchResultsController ctrl,
    AppLocalizations l,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      child: ListView.separated(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.screenPadding,
          vertical: KaziSpacing.lg,
        ),
        itemCount: items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: KaziSpacing.md),
        itemBuilder: (ctx, i) {
          if (i == items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: KaziSpacing.xl),
              child: state.isLoadingMore
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : const SizedBox.shrink(),
            );
          }
          final listing = items[i];
          return ProviderListItem(
            name: listing.providerName ?? listing.title,
            serviceLabel: listing.title,
            price: KaziFormatters.price(
              listing.priceAmount,
              listing.currency.name.toUpperCase(),
              listing.priceType.name,
              locale: locale,
            ),
            rating: listing.ratingAvg,
            reviewCount: listing.ratingCount,
            isVerified: listing.providerVerified,
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.query, required this.onClearCommune});

  final SearchQuery query;
  final VoidCallback onClearCommune;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.read<SearchResultsController>();
    final catalogCtrl = context.read<CatalogController>();

    String communeLabel = l.searchFilterNearMe;
    if (query.commune != null) {
      final c = catalogCtrl.communeById(query.commune!);
      communeLabel = c?.name ?? query.commune!;
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: KaziSpacing.screenPadding),
        children: [
          KaziChip(
            label: communeLabel,
            isSelected: query.commune != null,
            leadingIcon: LucideIcons.mapPin,
            trailingIcon: query.commune != null ? LucideIcons.x : null,
            onTap: query.commune != null ? onClearCommune : null,
          ),
          const SizedBox(width: KaziSpacing.sm),
          KaziChip(
            label: l.searchFilterVerified,
            isSelected: query.verifiedOnly,
            leadingIcon: LucideIcons.shieldCheck,
            onTap: ctrl.toggleVerified,
          ),
          const SizedBox(width: KaziSpacing.sm),
          KaziChip(
            label: l.searchFilterTopRated,
            isSelected: query.minRating == 4.0,
            leadingIcon: LucideIcons.star,
            onTap: ctrl.toggleTopRated,
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.lg,
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: KaziSpacing.md),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(KaziSpacing.md),
        decoration: BoxDecoration(
          color: KaziColors.surface,
          borderRadius: BorderRadius.circular(KaziRadius.card),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 56, height: 56, borderRadius: 28),
            const SizedBox(width: KaziSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: 14),
                  const SizedBox(height: KaziSpacing.xs),
                  SkeletonBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 11),
                  const SizedBox(height: KaziSpacing.sm),
                  const SkeletonBox(width: 80, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
