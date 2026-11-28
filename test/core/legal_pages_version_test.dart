import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/config/app_defaults.dart';

/// The terms version the app stores with each new account must be the version
/// printed on the published pages, so "the version you accepted" is traceable.
void main() {
  for (final page in [
    'web/public/fr/terms.html',
    'web/public/en/terms.html',
    'web/public/fr/privacy.html',
    'web/public/en/privacy.html',
    'web/public/delete-account.html',
  ]) {
    test('$page shows version ${AppDefaults.termsVersion}', () {
      final html = File(page).readAsStringSync();
      expect(html, contains('Version ${AppDefaults.termsVersion}'));
      expect(html, contains('2026')); // a "last updated" / "effective" date
    });
  }

  test('FR and EN pages state both a last-updated and an effective date', () {
    final fr = File('web/public/fr/privacy.html').readAsStringSync();
    final en = File('web/public/en/privacy.html').readAsStringSync();
    expect(fr, allOf(contains('Dernière mise à jour'), contains('Date d’entrée en vigueur')));
    expect(en, allOf(contains('Last updated'), contains('Effective date')));
  });
}
