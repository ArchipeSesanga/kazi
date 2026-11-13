import 'package:flutter/material.dart';

abstract final class KaziColors {
  // Brand
  static const Color accent = Color(0xFFF25912);
  static const Color primary = Color(0xFF5C3E94);
  static const Color primaryDark = Color(0xFF412B6B);
  static const Color primaryLight = Color(0xFFD9CFF0);
  static const Color primarySurface = Color(0xFFF1ECFA);

  // Text
  static const Color ink = Color(0xFF211832);
  static const Color body = Color(0xFF3D3550);
  static const Color muted = Color(0xFF6E6684);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF5F3F8);
  static const Color border = Color(0xFFD9D9D9);

  // Semantic
  static const Color whatsapp = Color(0xFF25D366);
  static const Color star = Color(0xFFF5B700);
  static const Color error = Color(0xFFD92D20);
  static const Color success = Color(0xFF12B76A);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primaryDark],
  );
  static const LinearGradient promoBannerGradient = LinearGradient(
    colors: [primary, ink],
  );

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1F121820),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> accentButtonShadow = [
    BoxShadow(
      color: Color(0x66F25912),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
