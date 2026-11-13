import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.welcomeLanguageTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: KaziSpacing.sm),
        children: LocaleController.supported.map((locale) {
          final isSelected = controller.locale == locale;
          final label = locale.languageCode == 'fr' ? 'Français' : 'English';
          final flag = locale.languageCode == 'fr' ? '🇫🇷' : '🇬🇧';
          return ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 24)),
            title: Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? KaziColors.primary : KaziColors.ink,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle_rounded, color: KaziColors.primary)
                : null,
            onTap: () {
              context.read<LocaleController>().setLocale(locale);
              Navigator.of(context).maybePop();
            },
          );
        }).toList(),
      ),
    );
  }
}
