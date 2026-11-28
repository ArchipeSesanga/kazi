import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/launcher_service.dart';
import '../../../core/theme/kazi_colors.dart';
import 'legal_screen.dart';

/// "By continuing you accept the Terms and Privacy Policy", with both links
/// opening the published pages in the user's language. Shown where the user
/// continues into an account (phone sign-in and profile setup). Opens the
/// pages in the browser directly (not through the router) so it also works
/// while the router only allows the sign-in screens.
class LegalNotice extends StatelessWidget {
  const LegalNotice({super.key});

  static const termsKey = Key('legal-notice-terms');
  static const privacyKey = Key('legal-notice-privacy');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    const base = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12.5,
      height: 1.5,
      color: KaziColors.muted,
    );
    const link = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 12.5,
      height: 1.5,
      fontWeight: FontWeight.w700,
      color: KaziColors.primary,
      decoration: TextDecoration.underline,
    );

    Widget linkTo(Key key, String label, LegalPageKind kind) => Semantics(
          link: true,
          child: InkWell(
            key: key,
            onTap: () => context
                .read<LauncherService>()
                .launchUrl(LegalScreen.urlFor(kind, lang)),
            child: Text(label, style: link),
          ),
        );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l.legalAcceptPrefix, style: base),
        linkTo(termsKey, l.legalLinkTerms, LegalPageKind.terms),
        Text(l.legalAcceptAnd, style: base),
        linkTo(privacyKey, l.legalLinkPrivacy, LegalPageKind.privacy),
        Text(l.legalAcceptSuffix, style: base),
      ],
    );
  }
}
