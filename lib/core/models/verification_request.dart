import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'timestamp_converter.dart';

part 'verification_request.freezed.dart';
part 'verification_request.g.dart';

@freezed
abstract class VerificationRequest with _$VerificationRequest {
  const factory VerificationRequest({
    required String uid,
    @Default(VerificationStatus.pending) VerificationStatus status,
    String? idDocumentPath,
    String? selfiePath,
    @TimestampConverter() DateTime? submittedAt,
    @TimestampConverter() DateTime? decidedAt,
    String? decidedBy,
    String? reason,
  }) = _VerificationRequest;

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$VerificationRequestFromJson(json);
}
