import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
    this.imageUrl,
    super.key,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          gradient: KaziColors.promoBannerGradient,
          borderRadius: BorderRadius.circular(KaziRadius.banner),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 120,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziSpacing.xl,
                vertical: KaziSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: KaziSpacing.xs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KaziSpacing.md,
                      vertical: KaziSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: KaziColors.accent,
                      borderRadius: BorderRadius.circular(KaziRadius.button),
                    ),
                    child: Text(
                      ctaLabel,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
