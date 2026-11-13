// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationRequest _$VerificationRequestFromJson(Map<String, dynamic> json) =>
    _VerificationRequest(
      uid: json['uid'] as String,
      status:
          $enumDecodeNullable(_$VerificationStatusEnumMap, json['status']) ??
          VerificationStatus.pending,
      idDocumentPath: json['idDocumentPath'] as String?,
      selfiePath: json['selfiePath'] as String?,
      submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
      decidedAt: const TimestampConverter().fromJson(json['decidedAt']),
      decidedBy: json['decidedBy'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$VerificationRequestToJson(
  _VerificationRequest instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'status': _$VerificationStatusEnumMap[instance.status]!,
  'idDocumentPath': instance.idDocumentPath,
  'selfiePath': instance.selfiePath,
  'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
  'decidedAt': const TimestampConverter().toJson(instance.decidedAt),
  'decidedBy': instance.decidedBy,
  'reason': instance.reason,
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.approved: 'approved',
  VerificationStatus.rejected: 'rejected',
};
