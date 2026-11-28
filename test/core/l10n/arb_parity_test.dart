import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/core/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Message keys (without the `@` metadata and `@@locale`).
Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// `{name}` placeholders used by a message, incl. those inside plurals.
Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)(?:,|\})')
        .allMatches(message)
        .map((m) => m.group(1)!)
        .toSet();

void main() {
  final fr = _arb('app_fr.arb');
  final en = _arb('app_en.arb');

  test('FR and EN have exactly the same keys', () {
    expect(_keys(en).difference(_keys(fr)), isEmpty, reason: 'missing in FR');
    expect(_keys(fr).difference(_keys(en)), isEmpty, reason: 'missing in EN');
  });

  test('no empty translation', () {
    for (final arb in [fr, en]) {
      for (final k in _keys(arb)) {
        if (k == '@@locale') continue;
        expect((arb[k] as String).trim(), isNotEmpty, reason: k);
      }
    }
  });

  test('both languages use the same placeholders in every message', () {
    for (final k in _keys(fr)) {
      if (k == '@@locale') continue;
      expect(
        _placeholders(en[k] as String),
        _placeholders(fr[k] as String),
        reason: 'placeholders differ for "$k"',
      );
    }
  });
}
