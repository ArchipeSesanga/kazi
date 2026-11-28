import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';
import 'kazi_avatar.dart';
import 'rating_stars.dart';
import 'verified_badge.dart';

class ProviderListItem extends StatelessWidget {
  const ProviderListItem({
    required this.name,
    required this.serviceLabel,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.photoUrl,
    this.isVerified = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
    super.key,
  });

  final String name;
  final String serviceLabel;
  final String price;
  final double rating;
  final int reviewCount;
  final String? photoUrl;
  final bool isVerified;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KaziSpacing.md),
        decoration: BoxDecoration(
          color: KaziColors.surface,
          borderRadius: BorderRadius.circular(KaziRadius.card),
          boxShadow: KaziColors.cardShadow,
        ),
        child: Row(
          children: [
            KaziAvatar(name: name, photoUrl: photoUrl, size: 56),
            const SizedBox(width: KaziSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: KaziColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: KaziSpacing.xs),
                        const VerifiedBadge(size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    serviceLabel,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: KaziColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: KaziSpacing.xs),
                  Row(
                    children: [
                      Flexible(
                        child: RatingSummary(
                          rating: rating,
                          count: reviewCount,
                        ),
                      ),
                      const SizedBox(width: KaziSpacing.sm),
                      const Spacer(),
                      Text(
                        price,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: KaziColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onFavoriteToggle != null) ...[
              const SizedBox(width: KaziSpacing.sm),
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  LucideIcons.heart,
                  size: 20,
                  color: isFavorite ? KaziColors.accent : KaziColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
