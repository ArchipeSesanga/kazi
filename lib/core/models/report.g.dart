// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  reporterUid: json['reporterUid'] as String,
  targetType: $enumDecode(_$ReportTargetTypeEnumMap, json['targetType']),
  targetKey: json['targetKey'] as String,
  reason: $enumDecode(_$ReportReasonEnumMap, json['reason']),
  details: json['details'] as String? ?? '',
  status:
      $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
      ReportStatus.open,
  resolution: json['resolution'] as Map<String, dynamic>?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'reporterUid': instance.reporterUid,
  'targetType': _$ReportTargetTypeEnumMap[instance.targetType]!,
  'targetKey': instance.targetKey,
  'reason': _$ReportReasonEnumMap[instance.reason]!,
  'details': instance.details,
  'status': _$ReportStatusEnumMap[instance.status]!,
  'resolution': instance.resolution,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$ReportTargetTypeEnumMap = {
  ReportTargetType.listing: 'listing',
  ReportTargetType.provider: 'provider',
  ReportTargetType.review: 'review',
};

const _$ReportReasonEnumMap = {
  ReportReason.scam: 'scam',
  ReportReason.inappropriate: 'inappropriate',
  ReportReason.fake: 'fake',
  ReportReason.wrongCategory: 'wrong_category',
  ReportReason.other: 'other',
};

const _$ReportStatusEnumMap = {
  ReportStatus.open: 'open',
  ReportStatus.dismissed: 'dismissed',
  ReportStatus.actioned: 'actioned',
};
