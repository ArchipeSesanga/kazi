import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

enum KaziButtonVariant { accent, primary, outline, whatsapp, text, danger }
enum KaziButtonSize { large, small }

class KaziButton extends StatelessWidget {
  const KaziButton({
    required this.label,
    required this.onPressed,
    this.variant = KaziButtonVariant.accent,
    this.size = KaziButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final KaziButtonVariant variant;
  final KaziButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final height = size == KaziButtonSize.large ? 48.0 : 32.0;
    final fontSize = size == KaziButtonSize.large ? 15.0 : 13.0;
    final hPad = size == KaziButtonSize.large ? 20.0 : 14.0;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foreground,
            ),
          )
        // Last-resort guard: a long translation scales down instead of
        // overflowing (no effect when it fits or when width is unbounded).
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: _foreground),
                  const SizedBox(width: KaziSpacing.sm),
                ],
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: _foreground,
                  ),
                ),
              ],
            ),
          );

    if (variant == KaziButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    if (variant == KaziButtonVariant.outline) {
      return SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            side: const BorderSide(color: KaziColors.primary),
          ),
          child: child,
        ),
      );
    }

    return Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: isLoading || onPressed == null ? _background.withValues(alpha: 0.6) : _background,
        borderRadius: BorderRadius.circular(KaziRadius.button),
        boxShadow: variant == KaziButtonVariant.accent
            ? KaziColors.accentButtonShadow
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(KaziRadius.button),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Color get _background => switch (variant) {
        KaziButtonVariant.accent => KaziColors.accent,
        KaziButtonVariant.primary => KaziColors.primary,
        KaziButtonVariant.whatsapp => KaziColors.whatsapp,
        KaziButtonVariant.danger => KaziColors.error,
        _ => KaziColors.primary,
      };

  Color get _foreground => switch (variant) {
        KaziButtonVariant.outline => KaziColors.primary,
        KaziButtonVariant.text => KaziColors.primary,
        _ => Colors.white,
      };
}

/// Pre-built WhatsApp contact button with icon.
class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({required this.onPressed, required this.label, super.key});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => KaziButton(
        label: label,
        onPressed: onPressed,
        variant: KaziButtonVariant.whatsapp,
        icon: LucideIcons.messageCircle,
      );
}
