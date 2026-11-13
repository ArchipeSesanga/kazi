// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Favorite _$FavoriteFromJson(Map<String, dynamic> json) => _Favorite(
  providerId: json['providerId'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  headline: json['headline'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$FavoriteToJson(_Favorite instance) => <String, dynamic>{
  'providerId': instance.providerId,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'headline': instance.headline,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
