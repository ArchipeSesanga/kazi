import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_text.freezed.dart';
part 'localized_text.g.dart';

@freezed
abstract class LocalizedText with _$LocalizedText {
  const factory LocalizedText({
    @Default('') String fr,
    @Default('') String en,
  }) = _LocalizedText;

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
}

extension LocalizedTextX on LocalizedText {
  String resolve(String locale) =>
      locale.startsWith('fr') ? fr : en;
}
