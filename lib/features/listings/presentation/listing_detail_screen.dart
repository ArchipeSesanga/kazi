import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(name: 'Annonce');
}
