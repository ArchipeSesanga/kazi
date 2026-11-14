import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/location.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../application/search_results_controller.dart';

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({
    required this.query,
    required this.communes,
    super.key,
  });

  final SearchQuery query;
  final List<Commune> communes;

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late SearchSort _sort;
  late String? _commune;
  late bool _verifiedOnly;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _sort = widget.query.sort;
    _commune = widget.query.commune;
    _verifiedOnly = widget.query.verifiedOnly;
    _minRating = widget.query.minRating;
  }

  void _apply() {
    Navigator.of(context).pop(SearchQuery(
      keyword: widget.query.keyword,
      categoryId: widget.query.categoryId,
      commune: _commune,
      city: widget.query.city,
      verifiedOnly: _verifiedOnly,
      minRating: _minRating,
      sort: _sort,
    ));
  }

  void _reset() {
    Navigator.of(context).pop(SearchQuery(
      keyword: widget.query.keyword,
      categoryId: widget.query.categoryId,
      city: widget.query.city,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: KaziSpacing.screenPadding,
          right: KaziSpacing.screenPadding,
          top: KaziSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + KaziSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet handle + header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: KaziColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KaziSpacing.lg),
            Row(
              children: [
                Text(
                  l.filterTitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KaziColors.ink,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: KaziColors.muted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: KaziSpacing.xl),

            // Sort section
            _SectionLabel(label: l.searchSortTitle),
            const SizedBox(height: KaziSpacing.md),
            _RadioRow(
              label: l.searchSortRelevance,
              selected: _sort == SearchSort.relevance,
              onTap: () => setState(() => _sort = SearchSort.relevance),
            ),
            _RadioRow(
              label: l.searchSortRecent,
              selected: _sort == SearchSort.recent,
              onTap: () => setState(() => _sort = SearchSort.recent),
            ),
            const SizedBox(height: KaziSpacing.xl),

            // Commune section
            _SectionLabel(label: l.filterCommune),
            const SizedBox(height: KaziSpacing.md),
            SizedBox(
              height: 140,
              child: ListView(
                children: [
                  _RadioRow(
                    label: l.filterCommuneAll,
                    selected: _commune == null,
                    onTap: () => setState(() => _commune = null),
                  ),
                  ...widget.communes.map((c) => _RadioRow(
                        label: c.name,
                        selected: _commune == c.id,
                        onTap: () => setState(() => _commune = c.id),
                      )),
                ],
              ),
            ),
            const SizedBox(height: KaziSpacing.xl),

            // Verified toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.filterVerified,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: KaziColors.ink,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: _verifiedOnly,
                  onChanged: (v) => setState(() => _verifiedOnly = v),
                  activeThumbColor: KaziColors.primary,
                  activeTrackColor: KaziColors.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: KaziSpacing.xl),

            // Min rating section
            _SectionLabel(label: l.filterMinRating),
            const SizedBox(height: KaziSpacing.md),
            Row(
              children: [
                _RatingOption(
                  label: l.filterMinRatingAny,
                  selected: _minRating == null,
                  onTap: () => setState(() => _minRating = null),
                ),
                const SizedBox(width: KaziSpacing.sm),
                _RatingOption(
                  label: '3+ ★',
                  selected: _minRating == 3.0,
                  onTap: () => setState(() => _minRating = 3.0),
                ),
                const SizedBox(width: KaziSpacing.sm),
                _RatingOption(
                  label: '4+ ★',
                  selected: _minRating == 4.0,
                  onTap: () => setState(() => _minRating = 4.0),
                ),
              ],
            ),
            const SizedBox(height: KaziSpacing.xxxl),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: KaziButton(
                    label: l.filterReset,
                    onPressed: _reset,
                    variant: KaziButtonVariant.outline,
                  ),
                ),
                const SizedBox(width: KaziSpacing.md),
                Expanded(
                  child: KaziButton(
                    label: l.filterApply,
                    onPressed: _apply,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: KaziColors.muted,
          letterSpacing: 0.5,
        ),
      );
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: selected ? KaziColors.primary : KaziColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                selected ? LucideIcons.circleCheck : LucideIcons.circle,
                size: 20,
                color: selected ? KaziColors.primary : KaziColors.muted,
              ),
            ],
          ),
        ),
      );
}

class _RatingOption extends StatelessWidget {
  const _RatingOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.lg, vertical: KaziSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? KaziColors.primarySurface : KaziColors.surfaceAlt,
            borderRadius: BorderRadius.circular(KaziRadius.pill),
            border: selected
                ? Border.all(color: KaziColors.primaryLight)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? KaziColors.primary : KaziColors.muted,
            ),
          ),
        ),
      );
}
