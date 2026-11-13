// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Commune _$CommuneFromJson(Map<String, dynamic> json) =>
    _Commune(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CommuneToJson(_Commune instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

_City _$CityFromJson(Map<String, dynamic> json) => _City(
  id: json['id'] as String,
  name: json['name'] as String,
  active: json['active'] as bool? ?? true,
  communes:
      (json['communes'] as List<dynamic>?)
          ?.map((e) => Commune.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CityToJson(_City instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'active': instance.active,
  'communes': instance.communes,
};
