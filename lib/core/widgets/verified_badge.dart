import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/kazi_colors.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({this.size = 16, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Prestataire vérifié',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: KaziColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.check,
          size: size * 0.65,
          color: Colors.white,
        ),
      ),
    );
  }
}
