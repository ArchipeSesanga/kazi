// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  names: LocalizedText.fromJson(json['names'] as Map<String, dynamic>),
  iconKey: json['iconKey'] as String? ?? '',
  order: (json['order'] as num?)?.toInt() ?? 0,
  featured: json['featured'] as bool? ?? false,
  active: json['active'] as bool? ?? true,
  synonyms:
      (json['synonyms'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const {},
  listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'names': instance.names,
  'iconKey': instance.iconKey,
  'order': instance.order,
  'featured': instance.featured,
  'active': instance.active,
  'synonyms': instance.synonyms,
  'listingCount': instance.listingCount,
};
