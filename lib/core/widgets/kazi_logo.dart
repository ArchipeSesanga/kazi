import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Available logo files from `assets/kazi-logo-kit/svg/`.
enum KaziLogoVariant {
  symbol('kazi-symbol'),
  symbolReversed('kazi-symbol-reversed'),
  horizontal('kazi-horizontal'),
  horizontalReversed('kazi-horizontal-reversed'),
  stacked('kazi-stacked'),
  stackedReversed('kazi-stacked-reversed');

  const KaziLogoVariant(this.file);
  final String file;
  String get asset => 'assets/kazi-logo-kit/svg/$file.svg';
}

/// Brand logo. Use `*Reversed` variants on dark/purple backgrounds.
class KaziLogo extends StatelessWidget {
  const KaziLogo({
    super.key,
    this.variant = KaziLogoVariant.horizontal,
    this.width,
    this.height,
  });

  final KaziLogoVariant variant;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      variant.asset,
      width: width,
      height: height,
      semanticsLabel: 'Kazi',
    );
  }
}
