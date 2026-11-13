import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../application/gate_controller.dart';

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final storeUrl = context.read<GateController>().storeUrl;

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
                    gradient: KaziColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                Text(
                  l.updateRequiredTitle,
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
                  l.updateRequiredBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.body,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                if (storeUrl.isNotEmpty)
                  KaziButton(
                    label: l.updateRequiredButton,
                    icon: Icons.open_in_new_rounded,
                    onPressed: () =>
                        context.read<LauncherService>().launchUrl(storeUrl),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
