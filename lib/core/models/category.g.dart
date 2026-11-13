// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
  icon: json['icon'] as String,
  order: (json['order'] as num).toInt(),
  active: json['active'] as bool? ?? true,
  listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'order': instance.order,
  'active': instance.active,
  'listingCount': instance.listingCount,
};
