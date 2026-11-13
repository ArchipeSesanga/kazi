import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class ProviderReviewsScreen extends StatelessWidget {
  const ProviderReviewsScreen({required this.providerId, super.key});

  final String providerId;

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Avis');
}
