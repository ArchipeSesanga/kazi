import 'package:freezed_annotation/freezed_annotation.dart';

import 'localized_text.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required LocalizedText name,
    required String icon,
    required int order,
    @Default(true) bool active,
    @Default(0) int listingCount,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
