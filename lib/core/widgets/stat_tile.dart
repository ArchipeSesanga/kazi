import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    required this.value,
    required this.label,
    this.icon,
    this.color,
    super.key,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? KaziColors.primary;
    return Container(
      padding: const EdgeInsets.all(KaziSpacing.lg),
      decoration: BoxDecoration(
        color: KaziColors.surface,
        borderRadius: BorderRadius.circular(KaziRadius.card),
        boxShadow: KaziColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: tileColor),
            const SizedBox(height: KaziSpacing.sm),
          ],
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: tileColor,
            ),
          ),
          const SizedBox(height: KaziSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KaziColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

