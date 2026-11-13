// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactRecord _$ContactRecordFromJson(Map<String, dynamic> json) =>
    _ContactRecord(
      clientUid: json['clientUid'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerPhotoUrl: json['providerPhotoUrl'] as String?,
      listingId: json['listingId'] as String?,
      channel: $enumDecode(_$ContactChannelEnumMap, json['channel']),
      firstAt: const TimestampConverter().fromJson(json['firstAt']),
      lastAt: const TimestampConverter().fromJson(json['lastAt']),
    );

Map<String, dynamic> _$ContactRecordToJson(_ContactRecord instance) =>
    <String, dynamic>{
      'clientUid': instance.clientUid,
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'providerPhotoUrl': instance.providerPhotoUrl,
      'listingId': instance.listingId,
      'channel': _$ContactChannelEnumMap[instance.channel]!,
      'firstAt': const TimestampConverter().toJson(instance.firstAt),
      'lastAt': const TimestampConverter().toJson(instance.lastAt),
    };

const _$ContactChannelEnumMap = {
  ContactChannel.whatsapp: 'whatsapp',
  ContactChannel.call: 'call',
};
