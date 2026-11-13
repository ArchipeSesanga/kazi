import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

enum LegalPageKind { terms, privacy }

class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.kind, super.key});

  final LegalPageKind kind;

  @override
  Widget build(BuildContext context) {
    final title = kind == LegalPageKind.terms
        ? 'Conditions d\'utilisation'
        : 'Politique de confidentialité';
    return PlaceholderScreen(name: title);
  }
}
