import '../../../core/models/report.dart';

export '../../../core/models/report.dart';

abstract interface class ReportRepository {
  Future<void> submit(Report report);
}
