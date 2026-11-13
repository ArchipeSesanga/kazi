import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kazi_colors.dart';
import 'kazi_spacing.dart';
import 'kazi_typography.dart';

abstract final class KaziTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      colorScheme: const ColorScheme.light(
        primary: KaziColors.primary,
        secondary: KaziColors.accent,
        onSurface: KaziColors.ink,
        error: KaziColors.error,
        outline: KaziColors.border,
        surfaceContainerHighest: KaziColors.surfaceAlt,
      ),
      scaffoldBackgroundColor: KaziColors.surface,
      textTheme: KaziTypography.textTheme,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: KaziColors.surface,
        foregroundColor: KaziColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x14121820),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: KaziColors.ink,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KaziColors.surface,
        indicatorColor: KaziColors.primarySurface,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: KaziColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KaziColors.primary, size: 22);
          }
          return const IconThemeData(color: KaziColors.muted, size: 22);
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        elevation: 0,
        shadowColor: const Color(0x14121820),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KaziColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.lg,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: KaziColors.muted,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 15,
          color: KaziColors.muted,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: KaziColors.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KaziRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KaziRadius.button),
          ),
          side: const BorderSide(color: KaziColors.primary),
          foregroundColor: KaziColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KaziColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: KaziColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaziRadius.card),
        ),
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x1F121820),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KaziColors.surfaceAlt,
        selectedColor: KaziColors.primarySurface,
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaziRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: KaziColors.border,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaziRadius.button),
        ),
        backgroundColor: KaziColors.ink,
        contentTextStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KaziColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KaziRadius.sheet),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: KaziColors.border,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KaziColors.primary,
      ),
    );
  }
}
