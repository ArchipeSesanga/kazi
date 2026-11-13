import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';
import 'kazi_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KaziSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: KaziColors.primarySurface,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Icon(icon, size: 32, color: KaziColors.primary),
              ),
              const SizedBox(height: KaziSpacing.xl),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: KaziColors.muted,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KaziSpacing.xl),
              KaziButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: KaziButtonVariant.outline,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
