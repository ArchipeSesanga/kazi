import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class KaziSearchBar extends StatelessWidget {
  const KaziSearchBar({
    required this.hint,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.readOnly = false,
    this.autofocus = false,
    this.showFilterButton = true,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final bool autofocus;
  final bool showFilterButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: KaziColors.surface,
              borderRadius: BorderRadius.circular(KaziRadius.pill),
              boxShadow: KaziColors.cardShadow,
            ),
            child: TextField(
              controller: controller,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              readOnly: readOnly,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: KaziColors.ink,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: KaziColors.muted,
                ),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  size: 18,
                  color: KaziColors.muted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: KaziSpacing.lg,
                ),
              ),
            ),
          ),
        ),
        if (showFilterButton) ...[
          const SizedBox(width: KaziSpacing.sm),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KaziColors.accent,
                borderRadius: BorderRadius.circular(KaziRadius.pill),
                boxShadow: KaziColors.accentButtonShadow,
              ),
              child: const Icon(
                LucideIcons.slidersHorizontal,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
