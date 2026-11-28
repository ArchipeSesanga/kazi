import 'package:freezed_annotation/freezed_annotation.dart';

import 'localized_text.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// `categories/{slug}` (TDD §4.10). The slug is the permanent document id;
/// only [names] may change. A retired category is `active: false`, never
/// deleted. [iconKey] is resolved by `categoryIconFor` (unknown keys fall back
/// to a generic icon, so new categories need no app update).
@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required LocalizedText names,
    @Default('') String iconKey,
    @Default(0) int order,
    @Default(false) bool featured,
    @Default(true) bool active,

    /// Search synonyms per language (`fr`, `en`, `ln`, `sw`). Used by the
    /// server to build `searchKeywords`; the app only carries them.
    @Default({}) Map<String, List<String>> synonyms,
    @Default(0) int listingCount,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Display name in [locale] (`fr…` → French, anything else English).
  String label(String locale) => names.resolve(locale);
}
