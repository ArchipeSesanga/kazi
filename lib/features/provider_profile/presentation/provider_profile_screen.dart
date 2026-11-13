import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({required this.providerId, super.key});

  final String providerId;

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Profil prestataire');
}
