// Fails (exit 1) when app_fr.arb and app_en.arb differ in keys or placeholders.
// Run: dart run tool/check_arb_parity.dart [fr.arb en.arb]
import 'dart:convert';
import 'dart:io';

Map<String, dynamic> _load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// Placeholder names used in a message, for example `{count}` or the
/// argument of `{count, plural, ...}`. Read from the message text, because
/// only the template file has to carry `@key` metadata.
Set<String> _placeholders(Map<String, dynamic> arb, String key) {
  final value = arb[key];
  if (value is! String) return {};
  return RegExp(r'\{\s*(\w+)\s*[,}]')
      .allMatches(value)
      .map((m) => m.group(1)!)
      .toSet();
}

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

void main(List<String> args) {
  final frPath = args.isNotEmpty ? args[0] : 'lib/core/l10n/app_fr.arb';
  final enPath = args.length > 1 ? args[1] : 'lib/core/l10n/app_en.arb';
  final fr = _load(frPath);
  final en = _load(enPath);
  final frKeys = _keys(fr);
  final enKeys = _keys(en);

  final problems = <String>[
    for (final k in (frKeys.difference(enKeys).toList()..sort()))
      'missing in $enPath: $k',
    for (final k in (enKeys.difference(frKeys).toList()..sort()))
      'missing in $frPath: $k',
    for (final k in (frKeys.intersection(enKeys).toList()..sort()))
      if (!_sameSet(_placeholders(fr, k), _placeholders(en, k)))
        'placeholders differ for: $k',
  ];

  if (problems.isEmpty) {
    stdout.writeln('ARB parity OK (${frKeys.length} keys).');
    return;
  }
  stderr.writeln('ARB parity check failed:');
  for (final p in problems) {
    stderr.writeln('  - $p');
  }
  exit(1);
}
