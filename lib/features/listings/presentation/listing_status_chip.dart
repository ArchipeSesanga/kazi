import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../domain/listing_repository.dart';

/// Status chip for a listing as seen by its owner (dashboard, detail page).
///
/// An `active` listing that is not `visible` yet is either still being
/// processed by `onListingWritten` (no `providerStatus` yet → "Publication en
/// cours…"), hidden by moderation, or waiting for the provider's approval.
class ListingStatusChip extends StatelessWidget {
  const ListingStatusChip({required this.listing, super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (listing.status) {
      ListingStatus.draft => (l.dashboardListingStatusDraft, KaziColors.muted),
      ListingStatus.paused => (l.dashboardListingStatusPaused, KaziColors.star),
      ListingStatus.active when listing.visible => (
        l.dashboardListingStatusActive,
        KaziColors.success,
      ),
      ListingStatus.active when listing.providerStatus == null => (
        l.dashboardListingPublishing,
        KaziColors.star,
      ),
      ListingStatus.active when listing.isOverLimit => (
          l.dashboardListingOverLimit,
          KaziColors.error,
        ),
      ListingStatus.active when listing.moderation == Moderation.hidden => (
        l.dashboardListingHidden,
        KaziColors.error,
      ),
      ListingStatus.active => (l.dashboardStatusPending, KaziColors.star),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Explains why an over-limit listing is hidden. Empty for other listings.
class ListingStatusNote extends StatelessWidget {
  const ListingStatusNote({required this.listing, super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    if (!listing.isOverLimit) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        AppLocalizations.of(context).listingOverLimitNote,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: KaziColors.muted,
        ),
      ),
    );
  }
}
