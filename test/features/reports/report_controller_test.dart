import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/reports/application/report_controller.dart';
import 'package:kazi/features/reports/domain/report_repository.dart';

class FakeReports implements ReportRepository {
  final calls = <Map<String, Object?>>[];
  ReportFailureReason? failure;
  ReportOutcome outcome = ReportOutcome.created;

  @override
  Future<ReportOutcome> submit({
    required ReportTargetType targetType,
    required String targetKey,
    required ReportReason reason,
    String details = '',
  }) async {
    calls.add({'type': targetType, 'key': targetKey, 'reason': reason, 'details': details});
    if (failure != null) throw ReportFailure(failure!);
    return outcome;
  }
}

void main() {
  late FakeReports repo;
  late ReportController c;

  setUp(() {
    repo = FakeReports();
    c = ReportController(repo, targetType: ReportTargetType.listing, targetKey: 'l1');
  });

  test('cannot submit before a reason is chosen', () async {
    expect(c.canSubmit, isFalse);
    expect(await c.submit(), isFalse);
    expect(repo.calls, isEmpty);
  });

  test('submits the chosen reason, details and target', () async {
    c.selectReason(ReportReason.scam);
    c.setDetails('Il demande un acompte');
    expect(c.canSubmit, isTrue);
    expect(await c.submit(), isTrue);
    expect(repo.calls.single, {
      'type': ReportTargetType.listing,
      'key': 'l1',
      'reason': ReportReason.scam,
      'details': 'Il demande un acompte',
    });
    expect(c.step, ReportStep.done);
    expect(c.outcome, ReportOutcome.created);
  });

  test('a repeat report is "already reported", not an error', () async {
    repo.outcome = ReportOutcome.alreadyReported;
    c.selectReason(ReportReason.fake);
    expect(await c.submit(), isTrue);
    expect(c.outcome, ReportOutcome.alreadyReported);
    expect(c.failure, isNull);
  });

  test('details over 500 characters block the submit', () {
    c.selectReason(ReportReason.other);
    c.setDetails('x' * 501);
    expect(c.canSubmit, isFalse);
  });

  group('failures keep the sheet open with the reason', () {
    for (final reason in ReportFailureReason.values) {
      test(reason.name, () async {
        repo.failure = reason;
        c.selectReason(ReportReason.scam);
        expect(await c.submit(), isFalse);
        expect(c.failure, reason);
        expect(c.step, ReportStep.editing);
        // The user can retry.
        repo.failure = null;
        expect(await c.submit(), isTrue);
        expect(c.failure, isNull);
      });
    }
  });
}
