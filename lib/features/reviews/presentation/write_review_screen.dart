import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class WriteReviewScreen extends StatelessWidget {
  const WriteReviewScreen({required this.providerId, super.key});

  final String providerId;

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Laisser un avis');
}
