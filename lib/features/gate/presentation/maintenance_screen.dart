import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: KaziColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(KaziSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: KaziColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    size: 44,
                    color: KaziColors.primary,
                  ),
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                Text(
                  l.maintenanceTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: KaziColors.ink,
                  ),
                ),
                const SizedBox(height: KaziSpacing.lg),
                Text(
                  l.maintenanceBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.body,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
