import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class CategoryCircle extends StatelessWidget {
  const CategoryCircle({
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? KaziColors.primary : KaziColors.primarySurface,
              boxShadow: isSelected ? KaziColors.cardShadow : null,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : KaziColors.primary,
            ),
          ),
          const SizedBox(height: KaziSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? KaziColors.primary : KaziColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
