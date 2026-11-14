// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  phone: json['phone'] as String? ?? '',
  locale: json['locale'] as String? ?? 'fr',
  city: json['city'] as String? ?? 'kinshasa',
  commune: json['commune'] as String?,
  termsVersion: json['termsVersion'] as String?,
  termsAcceptedAt: const TimestampConverter().fromJson(json['termsAcceptedAt']),
  isProvider: json['isProvider'] as bool? ?? false,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'phone': instance.phone,
  'locale': instance.locale,
  'city': instance.city,
  'commune': instance.commune,
  'termsVersion': instance.termsVersion,
  'termsAcceptedAt': const TimestampConverter().toJson(
    instance.termsAcceptedAt,
  ),
  'isProvider': instance.isProvider,
  'status': _$UserStatusEnumMap[instance.status]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.suspended: 'suspended',
  UserStatus.deleting: 'deleting',
};
