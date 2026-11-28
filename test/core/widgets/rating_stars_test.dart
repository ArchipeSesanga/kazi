import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/l10n/app_localizations.dart';
import 'package:kazi/core/theme/kazi_colors.dart';
import 'package:kazi/core/theme/kazi_typography.dart';
import 'package:kazi/core/widgets/rating_stars.dart';

Widget _app(Widget child, {String locale = 'fr'}) => MaterialApp(
  locale: Locale(locale),
  theme: ThemeData(textTheme: KaziTypography.textTheme),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

/// Fill of each of the five stars, read from the rendered tree: the orange
/// icon is clipped to its fill fraction.
List<double> _fills(WidgetTester tester) {
  final stars = find.descendant(
    of: find.byType(RatingStars),
    matching: find.byType(Stack),
  );
  return [
    for (final s in stars.evaluate())
      () {
        final clip = find.descendant(
          of: find.byWidget(s.widget),
          matching: find.byType(ClipRect),
        );
        if (clip.evaluate().isEmpty) return 0.0;
        final clipper = tester.widget<ClipRect>(clip).clipper!;
        final rect = clipper.getClip(const Size(10, 10));
        return rect.width / 10;
      }(),
  ];
}

void main() {
  group('starFill: partial fill rounded to the nearest half', () {
    test('0 → all empty', () {
      expect([for (var i = 0; i < 5; i++) starFill(0, i)], [0, 0, 0, 0, 0]);
    });
    test('1 → one full star', () {
      expect([for (var i = 0; i < 5; i++) starFill(1, i)], [1, 0, 0, 0, 0]);
    });
    test('4.6 → four full and a half', () {
      expect([for (var i = 0; i < 5; i++) starFill(4.6, i)], [1, 1, 1, 1, 0.5]);
    });
    test('4.8 → rounds up to five', () {
      expect([for (var i = 0; i < 5; i++) starFill(4.8, i)], [1, 1, 1, 1, 1]);
    });
    test('5 → all full; out-of-range values are clamped', () {
      expect([for (var i = 0; i < 5; i++) starFill(5, i)], [1, 1, 1, 1, 1]);
      expect(starFill(9, 4), 1);
      expect(starFill(-3, 0), 0);
    });
    test('4.2 → 4 and a half boundary: 4.25 rounds to 4.5, 4.24 to 4.0', () {
      expect(starFill(4.25, 4), 0.5);
      expect(starFill(4.24, 4), 0);
    });
  });

  group('RatingStars (display)', () {
    for (final (rating, expected) in <(double, List<double>)>[
      (0, [0, 0, 0, 0, 0]),
      (1, [1, 0, 0, 0, 0]),
      (4.6, [1, 1, 1, 1, 0.5]),
      (5, [1, 1, 1, 1, 1]),
    ]) {
      testWidgets('renders $rating', (tester) async {
        await tester.pumpWidget(_app(RatingStars(rating: rating)));
        expect(_fills(tester), expected);
      });
    }

    testWidgets('orange fill, empty stars in the border colour', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const RatingStars(rating: 1)));
      final icons = tester
          .widgetList<Icon>(find.byIcon(Icons.star_rounded))
          .map((i) => i.color)
          .toList();
      expect(KaziColors.star, const Color(0xFFF25912));
      expect(icons.where((c) => c == KaziColors.star), hasLength(1));
      expect(icons.where((c) => c == KaziColors.border), hasLength(5));
    });
  });

  group('RatingSummary', () {
    testWidgets('French: "4,8 (32 avis)" and the screen-reader label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const RatingSummary(rating: 4.8, count: 32)),
      );
      expect(find.text('4,8 (32 avis)'), findsOneWidget);
      expect(find.bySemanticsLabel('Note 4,8 sur 5, 32 avis'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('English uses the point and "reviews"', (tester) async {
      await tester.pumpWidget(
        _app(const RatingSummary(rating: 4.8, count: 32), locale: 'en'),
      );
      expect(find.text('4.8 (32 reviews)'), findsOneWidget);
    });

    testWidgets('one review is singular', (tester) async {
      await tester.pumpWidget(_app(const RatingSummary(rating: 5, count: 1)));
      expect(find.text('5,0 (1 avis)'), findsOneWidget);
    });

    testWidgets('no review: a "Nouveau" chip, never "0,0"', (tester) async {
      await tester.pumpWidget(_app(const RatingSummary(rating: 0, count: 0)));
      expect(find.text('Nouveau'), findsOneWidget);
      expect(find.byKey(const ValueKey('rating-new')), findsOneWidget);
      expect(find.textContaining('0,0'), findsNothing);
      expect(find.byType(RatingStars), findsNothing);
    });

    testWidgets('the text uses the Label style (labelMedium)', (tester) async {
      await tester.pumpWidget(
        _app(const RatingSummary(rating: 4.8, count: 32)),
      );
      final style = tester
          .widget<Text>(find.byKey(const ValueKey('rating-text')))
          .style!;
      expect(style.fontSize, KaziTypography.textTheme.labelMedium!.fontSize);
      expect(
        style.fontWeight,
        KaziTypography.textTheme.labelMedium!.fontWeight,
      );
    });

    testWidgets('a tappable summary is at least 44 px tall', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(RatingSummary(rating: 4.8, count: 32, onTap: () => taps++)),
      );
      expect(
        tester.getSize(find.byType(InkWell)).height,
        greaterThanOrEqualTo(44),
      );
      await tester.tap(find.byType(RatingSummary));
      expect(taps, 1);
    });
  });

  group('RatingInput', () {
    testWidgets('whole stars 1–5, each a 44 px target', (tester) async {
      var value = 0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => RatingInput(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      for (var i = 1; i <= 5; i++) {
        final size = tester.getSize(find.byKey(ValueKey('rating-input-$i')));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
      await tester.tap(find.byKey(const ValueKey('rating-input-4')));
      await tester.pump();
      expect(value, 4);
      final orange = tester
          .widgetList<Icon>(find.byIcon(Icons.star_rounded))
          .where((i) => i.color == KaziColors.star);
      expect(orange, hasLength(4));
      await tester.tap(find.byKey(const ValueKey('rating-input-1')));
      await tester.pump();
      expect(value, 1);
    });

    testWidgets('each star is announced ("3 étoiles")', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(RatingInput(value: 3, onChanged: (_) {})));
      expect(find.bySemanticsLabel('3 étoiles'), findsOneWidget);
      expect(find.bySemanticsLabel('1 étoile'), findsOneWidget);
      handle.dispose();
    });
  });
}
