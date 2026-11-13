import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../services/connectivity_controller.dart';
import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

/// Shows a dark banner when the device is offline.
/// Hides itself when connectivity is restored.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select<ConnectivityController, bool>((c) => c.isOnline);
    if (isOnline) return const SizedBox.shrink();

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
                  AppLocalizations.of(context).offlineBanner,
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
