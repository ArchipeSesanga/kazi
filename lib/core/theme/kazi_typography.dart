import 'package:flutter/material.dart';

import 'kazi_colors.dart';

abstract final class KaziTypography {
  static const String _font = 'Montserrat';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _font,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    headlineMedium: TextStyle(
      fontFamily: _font,
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    titleLarge: TextStyle(
      fontFamily: _font,
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    titleMedium: TextStyle(
      fontFamily: _font,
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    titleSmall: TextStyle(
      fontFamily: _font,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    bodyLarge: TextStyle(
      fontFamily: _font,
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w400,
      color: KaziColors.body,
    ),
    bodyMedium: TextStyle(
      fontFamily: _font,
      fontSize: 14,
      height: 21 / 14,
      fontWeight: FontWeight.w400,
      color: KaziColors.body,
    ),
    bodySmall: TextStyle(
      fontFamily: _font,
      fontSize: 12,
      height: 17 / 12,
      fontWeight: FontWeight.w400,
      color: KaziColors.muted,
    ),
    labelLarge: TextStyle(
      fontFamily: _font,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w700,
      color: KaziColors.ink,
    ),
    labelMedium: TextStyle(
      fontFamily: _font,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      color: KaziColors.ink,
    ),
    labelSmall: TextStyle(
      fontFamily: _font,
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w500,
      color: KaziColors.muted,
    ),
  );
}
