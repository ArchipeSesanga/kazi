import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/category_circle.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kazi_search_bar.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/promo_banner.dart';
import '../../../core/widgets/provider_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../block/application/block_controller.dart';
import '../../catalog/application/catalog_controller.dart';
import '../application/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Consumer<HomeController>(
              builder: (context, home, _) => RefreshIndicator(
                onRefresh: home.refresh,
                color: KaziColors.accent,
                child: _HomeBody(home: home),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.home});
  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogController>();
    final blocked = context.watch<BlockController>();
    final locale = Localizations.localeOf(context).toLanguageTag();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _AppBar(home: home, catalog: catalog),

        // Search bar
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            KaziSpacing.screenPadding,
            KaziSpacing.lg,
            KaziSpacing.screenPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: KaziSearchBar(
              hint: l.homeSearchHint,
              readOnly: true,
              showFilterButton: false,
              onTap: () => context.push(Routes.search),
            ),
          ),
        ),

        // Category row
        if (catalog.categories.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.only(top: KaziSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: _CategoryRow(catalog: catalog, locale: locale),
            ),
          ),

        // Promo banner
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            KaziSpacing.screenPadding,
            KaziSpacing.lg,
            KaziSpacing.screenPadding,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: PromoBanner(
              title: l.homePromoTitle,
              subtitle: l.homePromoSubtitle,
              ctaLabel: l.homePromoCta,
              onTap: () => context.push(Routes.providerOnboarding),
            ),
          ),
        ),

        // Popular providers header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            KaziSpacing.screenPadding,
            KaziSpacing.xxl,
            KaziSpacing.screenPadding,
            KaziSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: l.homePopularProviders,
              actionLabel: l.buttonSeeAll,
              onAction: () => context.push(Routes.explore),
            ),
          ),
        ),

        // Provider grid (skeleton → grid → empty)
        ..._buildProviderSliver(context, home, catalog, blocked, locale, l),

        // Recently added header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            KaziSpacing.screenPadding,
            KaziSpacing.xxl,
            KaziSpacing.screenPadding,
            KaziSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(title: l.homeRecentListings),
          ),
        ),

        // Recent listings — stubbed empty (KZ-033 will wire fetchRecent)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.screenPadding,
            ),
            child: EmptyState(
              icon: LucideIcons.packageOpen,
              message: l.homeEmptyRecent,
            ),
          ),
        ),

        const SliverPadding(
          padding: EdgeInsets.only(bottom: KaziSpacing.xxxl),
        ),
      ],
    );
  }

  List<Widget> _buildProviderSliver(
    BuildContext context,
    HomeController home,
    CatalogController catalog,
    BlockController blocked,
    String locale,
    AppLocalizations l,
  ) {
    const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: KaziSpacing.md,
      mainAxisSpacing: KaziSpacing.md,
      childAspectRatio: 0.72,
    );
    const padding = EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding);

    if (home.isLoading) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (_, __) => const _ProviderCardSkeleton(),
              childCount: 4,
            ),
          ),
        ),
      ];
    }

    final providers = home.providers
        .where((p) => !blocked.isBlocked(p.uid))
        .toList();

    if (providers.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: padding,
            child: EmptyState(
              icon: LucideIcons.users,
              message: l.homeEmptyProviders,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverGrid(
          gridDelegate: gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final p = providers[i];
              return _ProviderCardAdapter(
                provider: p,
                catalog: catalog,
                locale: locale,
                onTap: () => ctx.push(Routes.providerProfile(p.uid)),
              );
            },
            childCount: providers.length,
          ),
        ),
      ),
    ];
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.home, required this.catalog});
  final HomeController home;
  final CatalogController catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final communeName = home.selectedCommuneId != null
        ? catalog.communeById(home.selectedCommuneId!)?.name
        : null;
    final locationLabel = communeName ?? l.homeLocationLabel;

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: KaziColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      titleSpacing: KaziSpacing.screenPadding,
      title: Row(
        children: [
          const Text(
            'Kazi',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: KaziColors.primary,
            ),
          ),
          const SizedBox(width: KaziSpacing.sm),
          GestureDetector(
            onTap: () => _showCommunePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziSpacing.sm,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: KaziColors.border),
                borderRadius: BorderRadius.circular(KaziRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    size: 13,
                    color: KaziColors.primary,
                  ),
                  const SizedBox(width: KaziSpacing.xs),
                  Text(
                    locationLabel,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: KaziColors.ink,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 13,
                    color: KaziColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        const IconButton(
          icon: Icon(LucideIcons.bell, color: KaziColors.ink, size: 20),
          onPressed: null, // KZ-092
        ),
      ],
    );
  }

  void _showCommunePicker(BuildContext context) {
    final l = AppLocalizations.of(context);
    final communes = catalog.cities.expand((c) => c.communes).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KaziColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KaziRadius.sheet),
        ),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KaziSpacing.lg,
                KaziSpacing.lg,
                KaziSpacing.lg,
                KaziSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.homeCommunePickerTitle,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: KaziColors.ink,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx),
                    child: const Icon(LucideIcons.x, color: KaziColors.muted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: KaziColors.border),
            ListTile(
              leading: Icon(
                LucideIcons.mapPin,
                color: home.selectedCommuneId == null
                    ? KaziColors.primary
                    : KaziColors.muted,
                size: 18,
              ),
              title: Text(
                l.homeLocationLabel,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: home.selectedCommuneId == null
                      ? KaziColors.primary
                      : KaziColors.ink,
                ),
              ),
              trailing: home.selectedCommuneId == null
                  ? const Icon(
                      LucideIcons.check,
                      color: KaziColors.primary,
                      size: 18,
                    )
                  : null,
              onTap: () {
                home.setCommune(null);
                Navigator.pop(sheetCtx);
              },
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: communes.length,
                itemBuilder: (_, i) {
                  final commune = communes[i];
                  final selected = home.selectedCommuneId == commune.id;
                  return ListTile(
                    title: Text(
                      commune.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: selected ? KaziColors.primary : KaziColors.ink,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                            LucideIcons.check,
                            color: KaziColors.primary,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      home.setCommune(commune.id);
                      Navigator.pop(sheetCtx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category row ──────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.catalog, required this.locale});
  final CatalogController catalog;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.screenPadding,
        ),
        itemCount: catalog.categories.length,
        itemBuilder: (_, i) {
          final cat = catalog.categories[i];
          final label =
              locale.startsWith('fr') ? cat.name.fr : cat.name.en;
          return Padding(
            padding: const EdgeInsets.only(right: KaziSpacing.md),
            child: CategoryCircle(
              label: label,
              icon: categoryIconForName(cat.icon),
              onTap: () => context.push(Routes.category(cat.id)),
            ),
          );
        },
      ),
    );
  }

}

// ── Provider card adapter ─────────────────────────────────────────────────────

class _ProviderCardAdapter extends StatelessWidget {
  const _ProviderCardAdapter({
    required this.provider,
    required this.catalog,
    required this.locale,
    required this.onTap,
  });

  final ProviderProfile provider;
  final CatalogController catalog;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstCatId = provider.categoryIds.firstOrNull;
    final category =
        firstCatId != null ? catalog.categoryById(firstCatId) : null;
    final serviceLabel = category == null
        ? ''
        : (locale.startsWith('fr') ? category.name.fr : category.name.en);

    final headline = provider.headline;
    final price = headline != null
        ? KaziFormatters.price(
            headline.fromAmount,
            headline.fromCurrency ?? 'USD',
            headline.fromPriceType ?? 'from',
            locale: locale,
          )
        : '';

    return ProviderCard(
      name: provider.displayName,
      serviceLabel: serviceLabel,
      price: price,
      rating: provider.ratingAvg,
      reviewCount: provider.ratingCount,
      photoUrl: provider.photoUrl,
      coverUrl: provider.coverUrl,
      isVerified: provider.verified,
      onTap: onTap,
    );
  }
}

// ── Provider card skeleton ────────────────────────────────────────────────────

class _ProviderCardSkeleton extends StatelessWidget {
  const _ProviderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KaziColors.surface,
        borderRadius: BorderRadius.circular(KaziRadius.card),
        boxShadow: KaziColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: double.infinity,
            height: 112,
            borderRadius: 0,
          ),
          Padding(
            padding: EdgeInsets.all(KaziSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 36, height: 36, borderRadius: 18),
                    SizedBox(width: KaziSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            width: double.infinity,
                            height: 11,
                          ),
                          SizedBox(height: KaziSpacing.xs),
                          SkeletonBox(width: 60, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: KaziSpacing.sm),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 10),
                    Spacer(),
                    SkeletonBox(width: 40, height: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
