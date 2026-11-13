import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class KaziChip extends StatelessWidget {
  const KaziChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? KaziColors.primarySurface : KaziColors.surfaceAlt;
    final fg = isSelected ? KaziColors.primary : KaziColors.muted;
    final border = isSelected
        ? const Border.fromBorderSide(BorderSide(color: KaziColors.primaryLight))
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KaziRadius.pill),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(trailingIcon, size: 14, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
