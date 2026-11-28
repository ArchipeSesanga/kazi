import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

/// Minimum touch target (px) for anything tappable.
const double kMinTapTarget = 44;

/// How much of star [index] (0-based) is filled for [rating]: `0`, `0.5` or
/// `1`. The rating is first rounded to the nearest half star, so 4.6 shows
/// four full stars and a half, 4.8 shows five.
double starFill(double rating, int index, {int maxRating = 5}) {
  final halves = (rating.clamp(0, maxRating) * 2).round() / 2;
  return (halves - index).clamp(0.0, 1.0).toDouble();
}

/// "4,8" in French, "4.8" in English.
String formatRating(BuildContext context, double rating) => NumberFormat(
  '0.0',
  Localizations.localeOf(context).toLanguageTag(),
).format(rating);

class _Star extends StatelessWidget {
  const _Star({required this.fill, required this.size});

  final double fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.star_rounded, size: size, color: KaziColors.border),
        if (fill > 0)
          ClipRect(
            clipper: _LeftFraction(fill),
            child: Icon(Icons.star_rounded, size: size, color: KaziColors.star),
          ),
      ],
    );
  }
}

class _LeftFraction extends CustomClipper<Rect> {
  const _LeftFraction(this.fraction);
  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftFraction old) => old.fraction != fraction;
}

/// Read-only stars: orange fill, empty stars in the border colour, partial
/// fill rounded to the nearest half.
class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    super.key,
  });

  final double rating;
  final int maxRating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < maxRating; i++)
            Padding(
              padding: const EdgeInsets.only(right: 1),
              child: _Star(
                fill: starFill(rating, i, maxRating: maxRating),
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}

/// Input variant: whole stars 1–5, each with a 44 px tap target.
class RatingInput extends StatelessWidget {
  const RatingInput({
    required this.value,
    required this.onChanged,
    this.maxRating = 5,
    this.size = 32,
    super.key,
  });

  /// 0 = nothing chosen yet.
  final int value;
  final ValueChanged<int> onChanged;
  final int maxRating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= maxRating; i++)
          Semantics(
            button: true,
            selected: i == value,
            label: l.ratingInputStar(i),
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('rating-input-$i'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: SizedBox(
                width: kMinTapTarget,
                height: kMinTapTarget,
                child: Center(
                  child: _Star(fill: i <= value ? 1 : 0, size: size),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Stars + "4,8 (32 avis)" in the Label style, or a "Nouveau" chip when the
/// provider has no review yet (never "0,0"). Read as "Note 4,8 sur 5, 32 avis".
/// When [onTap] is set the whole row is a 44 px tall tap target.
class RatingSummary extends StatelessWidget {
  const RatingSummary({
    required this.rating,
    required this.count,
    this.starSize = 14,
    this.onTap,
    super.key,
  });

  final double rating;
  final int count;
  final double starSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = Theme.of(context).textTheme.labelMedium;

    final Widget content;
    final String semantics;
    if (count <= 0) {
      semantics = l.ratingSemanticsNew;
      content = Container(
        key: const ValueKey('rating-new'),
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: KaziColors.primarySurface,
          borderRadius: BorderRadius.circular(KaziRadius.pill),
        ),
        child: Text(
          l.ratingNew,
          style: label?.copyWith(color: KaziColors.primary),
        ),
      );
    } else {
      final shown = formatRating(context, rating);
      semantics = l.ratingSemantics(shown, count);
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingStars(rating: rating, size: starSize),
          const SizedBox(width: KaziSpacing.xs),
          Flexible(
            child: Text(
              l.ratingSummary(shown, count),
              key: const ValueKey('rating-text'),
              style: label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final tappable = onTap != null;
    return Semantics(
      label: semantics,
      button: tappable,
      excludeSemantics: true,
      child: tappable
          ? InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTapTarget),
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: content,
                ),
              ),
            )
          : content,
    );
  }
}
