import '../constants/limits.dart';

const _stopWords = {
  'de', 'du', 'des', 'la', 'le', 'les', 'et', 'en', 'a', 'au', 'aux',
  'un', 'une', 'pour', 'sur', 'avec',
  'the', 'and', 'of', 'for', 'in',
};

/// Returns a list of distinct normalised tokens from [text].
/// Algorithm mirrors the TypeScript implementation (TDD §8.1).
List<String> tokens(String text) {
  final raw = _normaliseRaw(text);
  return raw.toList();
}

/// Returns all distinct keyword prefixes generated from [text].
/// Used for `searchKeywords` in Firestore documents.
List<String> prefixes(String text) {
  final result = <String>{};
  for (final token in tokens(text)) {
    final max = token.length.clamp(0, Limits.searchKeywordsPrefixMaxLength);
    for (var k = Limits.searchKeywordsPrefixMinLength; k <= max; k++) {
      result.add(token.substring(0, k));
    }
  }
  return result.toList();
}

/// Caps [prefixes] to [Limits.maxSearchKeywords], dropping longest first.
List<String> capKeywords(List<String> kws) {
  if (kws.length <= Limits.maxSearchKeywords) return kws;
  final sorted = [...kws]..sort((a, b) => b.length.compareTo(a.length));
  return sorted.sublist(kws.length - Limits.maxSearchKeywords);
}

Set<String> _normaliseRaw(String text) {
  // 1. Lowercase.
  var s = text.toLowerCase();
  // 2. Strip diacritics: NFD decompose, then remove combining marks (U+0300–U+036F).
  s = _removeDiacritics(s);
  // 3. Replace any char not [a-z0-9] with space.
  s = s.replaceAll(RegExp(r'[^a-z0-9]'), ' ');
  // 4. Split, drop tokens shorter than 2 chars.
  final parts = s.split(RegExp(r'\s+')).where((t) => t.length >= 2);
  // 5. Drop stop words; return distinct set.
  return parts.where((t) => !_stopWords.contains(t)).toSet();
}

String _removeDiacritics(String s) {
  // Dart doesn't expose ICU NFD directly, so we map each common accented char.
  const replacements = {
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'à': 'a', 'â': 'a', 'ä': 'a',
    'ç': 'c',
    'ô': 'o', 'ö': 'o', 'ò': 'o', 'ó': 'o',
    'î': 'i', 'ï': 'i', 'ì': 'i', 'í': 'i',
    'û': 'u', 'ù': 'u', 'ü': 'u', 'ú': 'u',
    'ÿ': 'y',
    'ñ': 'n',
  };
  return s.splitMapJoin(
    RegExp(r'.', dotAll: true),
    onMatch: (m) => replacements[m.group(0)!] ?? m.group(0)!,
    onNonMatch: (n) => n,
  );
}
