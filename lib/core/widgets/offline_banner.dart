import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KaziColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KaziSpacing.lg,
            vertical: KaziSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.wifiOff, size: 16, color: Colors.white),
              const SizedBox(width: KaziSpacing.sm),
              Expanded(
                child: Text(
                  message ?? 'Pas de connexion internet',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
