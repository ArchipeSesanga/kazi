import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class Commune with _$Commune {
  const factory Commune({
    required String id,
    required String name,
  }) = _Commune;

  factory Commune.fromJson(Map<String, dynamic> json) =>
      _$CommuneFromJson(json);
}

@freezed
abstract class City with _$City {
  const factory City({
    required String id,
    required String name,
    @Default(true) bool active,
    @Default([]) List<Commune> communes,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}
