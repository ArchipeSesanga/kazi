import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/report_controller.dart';
import '../domain/report_repository.dart';

/// Opens the report sheet (S13) for a listing or a provider and shows the
/// outcome in a snackbar.
Future<void> showReportSheet(
  BuildContext context, {
  required ReportTargetType targetType,
  required String targetKey,
}) async {
  final repo = context.read<ReportRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final outcome = await showModalBottomSheet<ReportOutcome>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: KaziColors.surface,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => ReportController(
        repo,
        targetType: targetType,
        targetKey: targetKey,
      ),
      child: const ReportSheet(),
    ),
  );
  if (outcome == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        outcome == ReportOutcome.alreadyReported
            ? l.reportAlready
            : l.reportSuccess,
      ),
    ),
  );
}

class ReportSheet extends StatelessWidget {
  const ReportSheet({super.key});

  static String reasonLabel(AppLocalizations l, ReportReason r) =>
      switch (r) {
        ReportReason.scam => l.reportReasonScam,
        ReportReason.inappropriate => l.reportReasonInappropriate,
        ReportReason.fake => l.reportReasonFake,
        ReportReason.wrongCategory => l.reportReasonWrongCategory,
        ReportReason.other => l.reportReasonOther,
      };

  static String failureText(AppLocalizations l, ReportFailureReason f) =>
      switch (f) {
        ReportFailureReason.rateLimited => l.reportRateLimited,
        ReportFailureReason.ownTarget => l.reportOwnTarget,
        ReportFailureReason.notFound => l.reportNotFound,
        ReportFailureReason.notVerified => l.reportNotVerified,
        ReportFailureReason.failed => l.errorUnknown,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.watch<ReportController>();
    final failure = c.failure;

    return Padding(
      padding: EdgeInsets.only(
        left: KaziSpacing.screenPadding,
        right: KaziSpacing.screenPadding,
        top: KaziSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + KaziSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.reportTitle,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KaziColors.ink,
              ),
            ),
            const SizedBox(height: KaziSpacing.md),
            Text(
              l.reportReason,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KaziColors.muted,
              ),
            ),
            RadioGroup<ReportReason>(
              groupValue: c.reason,
              onChanged: (v) {
                if (v != null && !c.isSubmitting) c.selectReason(v);
              },
              child: Column(
                children: [
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                      key: Key('report-reason-${r.name}'),
                      value: r,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reasonLabel(l, r),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: KaziColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            KaziTextField(
              label: l.reportDetails,
              maxLength: ReportController.maxDetails,
              enabled: !c.isSubmitting,
              textInputAction: TextInputAction.done,
              onChanged: c.setDetails,
            ),
            if (failure != null)
              Padding(
                padding: const EdgeInsets.only(top: KaziSpacing.sm),
                child: Text(
                  failureText(l, failure),
                  key: const Key('report-error'),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: KaziColors.error,
                  ),
                ),
              ),
            const SizedBox(height: KaziSpacing.lg),
            KaziButton(
              label: l.reportSubmit,
              isLoading: c.isSubmitting,
              onPressed: c.canSubmit
                  ? () async {
                      final nav = Navigator.of(context);
                      final ok = await c.submit();
                      if (ok) nav.pop(c.outcome);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
