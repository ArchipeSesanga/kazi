import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/config/env.dart';
import '../domain/report_repository.dart';

/// Files reports through the `submitReport` callable: the server enforces one
/// report per user and target and the per-user daily limit.
class FirebaseReportRepository implements ReportRepository {
  FirebaseReportRepository([FirebaseFunctions? functions])
      : _functionsOverride = functions;

  final FirebaseFunctions? _functionsOverride;

  FirebaseFunctions get _functions =>
      _functionsOverride ??
      FirebaseFunctions.instanceFor(region: Env.functionsRegion);

  @override
  Future<ReportOutcome> submit({
    required ReportTargetType targetType,
    required String targetKey,
    required ReportReason reason,
    String details = '',
  }) async {
    try {
      final result = await _functions.httpsCallable('submitReport').call<Map>({
        'targetType': targetType.name,
        'targetKey': targetKey,
        'reason': _wire(reason),
        if (details.trim().isNotEmpty) 'details': details.trim(),
      });
      return result.data['status'] == 'already_reported'
          ? ReportOutcome.alreadyReported
          : ReportOutcome.created;
    } on FirebaseFunctionsException catch (e) {
      throw ReportFailure(switch (e.code) {
        'resource-exhausted' => ReportFailureReason.rateLimited,
        'failed-precondition' => ReportFailureReason.ownTarget,
        'not-found' => ReportFailureReason.notFound,
        'permission-denied' ||
        'unauthenticated' =>
          ReportFailureReason.notVerified,
        _ => ReportFailureReason.failed,
      });
    }
  }

  static String _wire(ReportReason r) => switch (r) {
        ReportReason.wrongCategory => 'wrong_category',
        _ => r.name,
      };
}
