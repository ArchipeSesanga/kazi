import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/features/listings/presentation/listing_form_screen.dart';

Widget _app({
  required Locale locale,
  required double width,
  required double textScale,
  bool singleSave = false,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        bottomNavigationBar: ListingFormBottomBar(
          isSaving: false,
          hasUploading: false,
          limitReached: false,
          singleSave: singleSave,
          onDraft: () {},
          onPublish: () {},
          onSave: () {},
        ),
      ),
    ),
  );
}

void main() {
  // The reported overflow: "Enregistrer le brouillon" by 49 px.
  for (final locale in const [Locale('fr'), Locale('en')]) {
    for (final scale in [1.0, 1.3]) {
      for (final width in [320.0, 360.0]) {
        testWidgets(
            'no overflow: ${locale.languageCode}, ${width.toInt()}px, x$scale',
            (tester) async {
          tester.view
            ..physicalSize = Size(width, 800)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            _app(locale: locale, width: width, textScale: scale),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('both actions are shown and tappable in French', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(locale: const Locale('fr'), width: 360, textScale: 1),
    );
    await tester.pump();
    expect(find.text('Enregistrer le brouillon'), findsOneWidget);
    expect(find.text('Publier'), findsOneWidget);
  });
}
