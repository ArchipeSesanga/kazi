import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'timestamp_converter.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
abstract class Report with _$Report {
  const factory Report({
    required String reporterUid,
    required ReportTargetType targetType,
    required String targetKey,
    required ReportReason reason,
    @Default('') String details,
    @Default(ReportStatus.open) ReportStatus status,
    Map<String, dynamic>? resolution,
    @TimestampConverter() DateTime? createdAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) =>
      _$ReportFromJson(json);
}

extension ReportWrite on Report {
  Map<String, dynamic> toCreateMap() => {
        'reporterUid': reporterUid,
        'targetType': targetType.name,
        'targetKey': targetKey,
        'reason': reason.name,
        'details': details,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      };
}
