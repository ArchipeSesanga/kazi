import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';
import 'kazi_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KaziSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: KaziColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                LucideIcons.triangleAlert,
                size: 32,
                color: KaziColors.error,
              ),
            ),
            const SizedBox(height: KaziSpacing.xl),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: KaziColors.muted,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: KaziSpacing.xl),
              KaziButton(
                label: retryLabel ?? 'Réessayer',
                onPressed: onRetry,
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
