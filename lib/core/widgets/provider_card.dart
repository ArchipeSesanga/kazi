import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';
import 'kazi_avatar.dart';
import 'kazi_network_image.dart';
import 'rating_stars.dart';
import 'verified_badge.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.name,
    required this.serviceLabel,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.photoUrl,
    this.coverUrl,
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
  final String? coverUrl;
  final bool isVerified;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: KaziColors.surface,
          borderRadius: BorderRadius.circular(KaziRadius.card),
          boxShadow: KaziColors.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(coverUrl: coverUrl, isFavorite: isFavorite, onFavoriteToggle: onFavoriteToggle),
            Padding(
              padding: const EdgeInsets.all(KaziSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KaziAvatar(name: name, photoUrl: photoUrl, size: 36),
                      const SizedBox(width: KaziSpacing.sm),
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: KaziColors.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: KaziSpacing.xs),
                                  const VerifiedBadge(size: 14),
                                ],
                              ],
                            ),
                            Text(
                              serviceLabel,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                color: KaziColors.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KaziSpacing.sm),
                  Row(
                    children: [
                      RatingBadge(rating: rating, reviewCount: reviewCount),
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
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.coverUrl, required this.isFavorite, this.onFavoriteToggle});

  final String? coverUrl;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        KaziNetworkImage(
          url: coverUrl,
          height: 112,
          width: double.infinity,
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: KaziSpacing.sm,
            right: KaziSpacing.sm,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? LucideIcons.heart : LucideIcons.heart,
                  size: 16,
                  color: isFavorite ? KaziColors.accent : KaziColors.muted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
