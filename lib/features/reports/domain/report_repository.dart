import '../../../core/models/enums.dart';

export '../../../core/models/enums.dart'
    show ReportReason, ReportStatus, ReportTargetType;

/// Result of filing a report.
enum ReportOutcome { created, alreadyReported }

enum ReportFailureReason {
  rateLimited,
  ownTarget,
  notFound,
  notVerified,
  failed,
}

class ReportFailure implements Exception {
  const ReportFailure(this.reason);

  final ReportFailureReason reason;

  @override
  String toString() => 'ReportFailure($reason)';
}

abstract interface class ReportRepository {
  /// Reports a listing, a provider or a review (`targetKey` =
  /// `{providerId}__{reviewerUid}`).
  /// Throws [ReportFailure].
  Future<ReportOutcome> submit({
    required ReportTargetType targetType,
    required String targetKey,
    required ReportReason reason,
    String details = '',
  });
}
