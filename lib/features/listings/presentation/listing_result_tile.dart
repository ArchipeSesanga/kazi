import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/provider_list_item.dart';
import '../domain/listing_repository.dart';

/// A listing in a list (Home "Ajoutés récemment", search results): the
/// provider's picture, name, the listing title, price and rating.
class ListingResultTile extends StatelessWidget {
  const ListingResultTile({
    required this.listing,
    required this.locale,
    required this.onTap,
    super.key,
  });

  final Listing listing;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ProviderListItem(
      name: listing.providerName ?? listing.title,
      serviceLabel: listing.title,
      price: KaziFormatters.price(
        listing.priceAmount,
        listing.currency.name.toUpperCase(),
        listing.priceType.name,
        locale: locale,
      ),
      rating: listing.ratingAvg,
      reviewCount: listing.ratingCount,
      photoUrl: listing.providerPhotoUrl,
      isVerified: listing.providerVerified,
      onTap: onTap,
    );
  }
}
