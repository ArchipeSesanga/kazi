import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/widgets/category_circle.dart';
import '../../../core/widgets/kazi_search_bar.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../catalog/application/catalog_controller.dart';
import '../application/explore_controller.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String raw) async {
    final keyword = raw.trim();
    if (keyword.isEmpty) return;
    await context.read<ExploreController>().addSearch(keyword);
    if (!mounted) return;
    unawaited(context.push('${Routes.search}?q=${Uri.encodeComponent(keyword)}'));
    _textCtrl.clear();
  }

  void _tapRecentSearch(String keyword) {
    context.read<ExploreController>().addSearch(keyword);
    unawaited(context.push('${Routes.search}?q=${Uri.encodeComponent(keyword)}'));
  }

  void _tapCategory(String id) {
    unawaited(context.push(Routes.category(id)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KaziSpacing.screenPadding,
                        KaziSpacing.xl,
                        KaziSpacing.screenPadding,
                        KaziSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.exploreTitle,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: KaziColors.ink,
                            ),
                          ),
                          const SizedBox(height: KaziSpacing.lg),
                          KaziSearchBar(
                            hint: l.exploreSearchHint,
                            controller: _textCtrl,
                            showFilterButton: false,
                            onSubmitted: _submitSearch,
                          ),
                        ],
                      ),
                    ),

                    // Recent searches
                    Consumer<ExploreController>(
                      builder: (_, ctrl, __) {
                        if (ctrl.searches.isEmpty) return const SizedBox.shrink();
                        return _RecentSearches(
                          searches: ctrl.searches,
                          onTap: _tapRecentSearch,
                          onRemove: ctrl.removeSearch,
                          onClear: ctrl.clearAll,
                        );
                      },
                    ),

                    // Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: KaziSpacing.screenPadding),
                      child: SectionHeader(title: l.exploreCategories),
                    ),
                    const SizedBox(height: KaziSpacing.md),

                    Consumer<CatalogController>(
                      builder: (_, catalog, __) {
                        if (catalog.categories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KaziSpacing.screenPadding),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: KaziSpacing.md,
                              crossAxisSpacing: KaziSpacing.sm,
                            ),
                            itemCount: catalog.categories.length,
                            itemBuilder: (_, i) {
                              final cat = catalog.categories[i];
                              return CategoryCircle(
                                label: cat.name.resolve(locale),
                                icon: categoryIconForName(cat.icon),
                                onTap: () => _tapCategory(cat.id),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: KaziSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent searches ───────────────────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.screenPadding),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.exploreRecentSearches,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KaziColors.ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  l.exploreClearRecent,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: KaziColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KaziSpacing.md),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.screenPadding),
          itemCount: searches.length,
          itemBuilder: (_, i) {
            final keyword = searches[i];
            return GestureDetector(
              onTap: () => onTap(keyword),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: KaziSpacing.sm),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 16, color: KaziColors.muted),
                    const SizedBox(width: KaziSpacing.md),
                    Expanded(
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: KaziColors.ink,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(keyword),
                      child: const Icon(LucideIcons.x,
                          size: 16, color: KaziColors.muted),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: KaziSpacing.xl),
      ],
    );
  }
}
