import 'package:flutter/material.dart';

import '../../../app/widgets/placeholder_screen.dart';

class ListingFormScreen extends StatelessWidget {
  /// [listingId] is null for a new listing, non-null for edit.
  const ListingFormScreen({this.listingId, super.key});

  final String? listingId;

  @override
  Widget build(BuildContext context) => PlaceholderScreen(
        name: listingId == null ? 'Nouvelle annonce' : 'Modifier l\'annonce',
      );
}
