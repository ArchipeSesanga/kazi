import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.interactive = false,
    this.onRatingChanged,
    super.key,
  });

  final double rating;
  final int maxRating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$rating out of $maxRating',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxRating, (i) {
          final filled = i < rating.floor();
          final halfFilled = !filled && i < rating;
          final icon = filled
              ? LucideIcons.star
              : halfFilled
                  ? LucideIcons.star
                  : LucideIcons.star;
          final color = (filled || halfFilled)
              ? KaziColors.star
              : KaziColors.border;

          if (interactive) {
            return GestureDetector(
              onTap: () => onRatingChanged?.call((i + 1).toDouble()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(icon, size: size, color: color),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(icon, size: size, color: color),
          );
        }),
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({required this.rating, required this.reviewCount, super.key});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LucideIcons.star, size: 14, color: KaziColors.star),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: KaziColors.ink,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: KaziColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}
