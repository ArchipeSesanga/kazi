import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';

enum LegalPageKind { terms, privacy }

/// The legal pages are published on Hosting (the single source of truth, also
/// required publicly by Google Play). This screen opens the page in the
/// user's language.
class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.kind, super.key});

  final LegalPageKind kind;

  /// `https://…/fr/terms` for the current language.
  static String urlFor(LegalPageKind kind, String languageCode) {
    final lang = languageCode == 'en' ? 'en' : 'fr';
    final page = kind == LegalPageKind.terms ? 'terms' : 'privacy';
    return '${AppDefaults.legalBaseUrl}/$lang/$page';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = kind == LegalPageKind.terms
        ? l.legalTermsTitle
        : l.legalPrivacyTitle;
    final url = urlFor(kind, Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: KaziColors.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: KaziColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(KaziSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.legalOpenHint,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: KaziColors.body,
              ),
            ),
            const SizedBox(height: KaziSpacing.xl),
            KaziButton(
              label: l.legalOpenButton,
              onPressed: () => context.read<LauncherService>().launchUrl(url),
            ),
          ],
        ),
      ),
    );
  }
}
