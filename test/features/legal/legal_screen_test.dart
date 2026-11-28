import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/services/launcher_service.dart';
import 'package:kazi/core/widgets/kazi_button.dart';
import 'package:kazi/features/legal/presentation/legal_screen.dart';
import 'package:provider/provider.dart';

class _Launcher implements LauncherService {
  final urls = <String>[];
  @override
  Future<void> launchUrl(String url) async => urls.add(url);
  @override
  Future<void> launchWhatsApp(String e164Phone, {String? message}) async {}
  @override
  Future<void> launchPhone(String e164Phone) async {}
}

void main() {
  test('URLs follow the Hosting layout for FR and EN', () {
    expect(LegalScreen.urlFor(LegalPageKind.terms, 'fr'), endsWith('/fr/terms'));
    expect(LegalScreen.urlFor(LegalPageKind.privacy, 'en'), endsWith('/en/privacy'));
    // Unknown languages fall back to French.
    expect(LegalScreen.urlFor(LegalPageKind.privacy, 'sw'), endsWith('/fr/privacy'));
  });

  for (final lang in ['fr', 'en']) {
    testWidgets('opens the $lang page in the browser', (tester) async {
      final launcher = _Launcher();
      await tester.pumpWidget(
        Provider<LauncherService>.value(
          value: launcher,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(lang),
            home: const LegalScreen(kind: LegalPageKind.terms),
          ),
        ),
      );
      await tester.tap(find.byType(KaziButton));
      expect(launcher.urls.single, endsWith('/$lang/terms'));
    });
  }
}
