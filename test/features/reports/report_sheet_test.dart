import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/widgets/kazi_button.dart';
import 'package:kazi/features/reports/domain/report_repository.dart';
import 'package:kazi/features/reports/presentation/report_sheet.dart';
import 'package:provider/provider.dart';

import 'report_controller_test.dart' show FakeReports;

Future<FakeReports> _pump(WidgetTester tester) async {
  final repo = FakeReports();
  await tester.pumpWidget(
    Provider<ReportRepository>.value(
      value: repo,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showReportSheet(
                context,
                targetType: ReportTargetType.provider,
                targetKey: 'p1',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('the submit button waits for a reason, then reports', (tester) async {
    final repo = await _pump(tester);
    KaziButton button() =>
        tester.widget<KaziButton>(find.widgetWithText(KaziButton, 'Signaler'));

    expect(button().onPressed, isNull);
    await tester.tap(find.byKey(const Key('report-reason-scam')));
    await tester.pump();
    expect(button().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(KaziButton, 'Signaler'));
    await tester.pumpAndSettle();
    expect(repo.calls.single['type'], ReportTargetType.provider);
    expect(repo.calls.single['reason'], ReportReason.scam);
    expect(find.text('Signalement envoyé. Merci.'), findsOneWidget);
  });

  testWidgets('"Déjà signalé" when the user reported this before', (tester) async {
    final repo = await _pump(tester);
    repo.outcome = ReportOutcome.alreadyReported;
    await tester.tap(find.byKey(const Key('report-reason-fake')));
    await tester.pump();
    await tester.tap(find.widgetWithText(KaziButton, 'Signaler'));
    await tester.pumpAndSettle();
    expect(find.text('Déjà signalé'), findsOneWidget);
  });

  testWidgets('the rate-limit message is shown and the sheet stays open', (tester) async {
    final repo = await _pump(tester);
    repo.failure = ReportFailureReason.rateLimited;
    await tester.tap(find.byKey(const Key('report-reason-other')));
    await tester.pump();
    await tester.tap(find.widgetWithText(KaziButton, 'Signaler'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('report-error')), findsOneWidget);
    expect(find.text('Trop de signalements aujourd\'hui. Réessayez demain.'), findsOneWidget);
  });
}
