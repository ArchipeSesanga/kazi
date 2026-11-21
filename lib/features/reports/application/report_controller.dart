import 'package:flutter/foundation.dart';

import '../domain/report_repository.dart';

enum ReportStep { editing, submitting, done }

class ReportController extends ChangeNotifier {
  ReportController(
    this._repo, {
    required this.targetType,
    required this.targetKey,
  });

  final ReportRepository _repo;
  final ReportTargetType targetType;
  final String targetKey;

  ReportStep _step = ReportStep.editing;
  ReportReason? _reason;
  String _details = '';
  ReportOutcome? _outcome;
  ReportFailureReason? _failure;

  static const maxDetails = 500;

  ReportStep get step => _step;
  ReportReason? get reason => _reason;
  ReportOutcome? get outcome => _outcome;
  ReportFailureReason? get failure => _failure;
  bool get canSubmit =>
      _reason != null &&
      _step != ReportStep.submitting &&
      _details.length <= maxDetails;
  bool get isSubmitting => _step == ReportStep.submitting;

  void selectReason(ReportReason reason) {
    _reason = reason;
    _failure = null;
    notifyListeners();
  }

  void setDetails(String value) {
    _details = value;
  }

  /// Returns true when the report was filed or had been filed before.
  Future<bool> submit() async {
    if (!canSubmit) return false;
    _step = ReportStep.submitting;
    _failure = null;
    notifyListeners();
    try {
      _outcome = await _repo.submit(
        targetType: targetType,
        targetKey: targetKey,
        reason: _reason!,
        details: _details,
      );
      _step = ReportStep.done;
      notifyListeners();
      return true;
    } on ReportFailure catch (f) {
      _failure = f.reason;
    } catch (_) {
      _failure = ReportFailureReason.failed;
    }
    _step = ReportStep.editing;
    notifyListeners();
    return false;
  }
}
