import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

enum KaziCurrency { cdf, usd }

class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final KaziCurrency selected;
  final ValueChanged<KaziCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: KaziColors.surfaceAlt,
        borderRadius: BorderRadius.circular(KaziRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(
            label: 'CDF',
            isSelected: selected == KaziCurrency.cdf,
            onTap: () => onChanged(KaziCurrency.cdf),
            isFirst: true,
          ),
          _Tab(
            label: 'USD',
            isSelected: selected == KaziCurrency.usd,
            onTap: () => onChanged(KaziCurrency.usd),
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? KaziColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(KaziRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : KaziColors.muted,
          ),
        ),
      ),
    );
  }
}
