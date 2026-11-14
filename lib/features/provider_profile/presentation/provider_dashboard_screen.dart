import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kazi_network_image.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../auth/application/session_controller.dart';
import '../../listings/domain/listing_repository.dart';
import '../application/dashboard_controller.dart';
import '../domain/provider_repository.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  late final DashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = DashboardController(
      context.read<ProviderRepository>(),
      context.read<ListingRepository>(),
    );
    final uid = context.read<SessionController>().uid;
    if (uid != null) _ctrl.init(uid);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            _AppBar(l: l),
            Expanded(
              child: ChangeNotifierProvider.value(
                value: _ctrl,
                child: Consumer<DashboardController>(
                  builder: (_, ctrl, __) => _Body(ctrl: ctrl, l: l),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KaziSpacing.screenPadding,
        KaziSpacing.lg,
        KaziSpacing.sm,
        KaziSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.dashboardTitle,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KaziColors.ink,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            color: KaziColors.muted,
            tooltip: l.publishHubGoToDashboard,
            onPressed: () => context.push(Routes.providerOnboarding),
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.ctrl, required this.l});
  final DashboardController ctrl;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading) return const _LoadingSkeleton();
    if (ctrl.error != null) {
      return Center(
        child: Text(
          l.errorUnknown,
          style: const TextStyle(fontFamily: 'Montserrat', color: KaziColors.muted),
        ),
      );
    }

    final profile = ctrl.profile;

    return ListView(
      padding: const EdgeInsets.only(bottom: KaziSpacing.xxxl),
      children: [
        // Status card
        if (profile != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
            child: _StatusCard(profile: profile, l: l),
          ),
          const SizedBox(height: KaziSpacing.lg),
          // Stats strip
          _StatsRow(profile: profile, listingCount: ctrl.listings.length, l: l),
          const SizedBox(height: KaziSpacing.xl),
        ],
        // My listings section
        SectionHeader(
          title: l.dashboardMyListings,
          actionLabel: l.dashboardNewListing,
          onAction: () => context.push(Routes.providerNewListing),
        ),
        const SizedBox(height: KaziSpacing.sm),
        if (ctrl.isLoadingListings)
          ..._listingSkeletons
        else if (ctrl.listings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.screenPadding,
              vertical: KaziSpacing.xl,
            ),
            child: EmptyState(
              icon: LucideIcons.clipboardList,
              message: l.dashboardListingsEmpty,
              actionLabel: l.dashboardNewListing,
              onAction: () => context.push(Routes.providerNewListing),
            ),
          )
        else
          ...ctrl.listings.map(
            (listing) => _ListingCard(listing: listing, ctrl: ctrl, l: l),
          ),
      ],
    );
  }

  List<Widget> get _listingSkeletons => List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KaziSpacing.screenPadding,
            vertical: KaziSpacing.xs,
          ),
          child: SkeletonBox(width: null, height: 80),
        ),
      );
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.profile, required this.l});
  final ProviderProfile profile;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (profile.status) {
      ProviderStatus.pending => (
          KaziColors.star.withValues(alpha: 0.1),
          KaziColors.star,
          LucideIcons.clock,
          l.dashboardStatusPending,
        ),
      ProviderStatus.approved => (
          KaziColors.success.withValues(alpha: 0.1),
          KaziColors.success,
          LucideIcons.circleCheck,
          l.dashboardStatusApproved,
        ),
      ProviderStatus.rejected => (
          KaziColors.error.withValues(alpha: 0.1),
          KaziColors.error,
          LucideIcons.circleX,
          l.dashboardStatusRejected,
        ),
      ProviderStatus.suspended => (
          KaziColors.error.withValues(alpha: 0.1),
          KaziColors.error,
          LucideIcons.ban,
          l.dashboardStatusSuspended,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(KaziSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KaziRadius.card),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: KaziSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                if (profile.statusReason != null &&
                    profile.status == ProviderStatus.rejected) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.statusReason!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: fg.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (profile.status == ProviderStatus.rejected)
            TextButton(
              onPressed: () => context.push(Routes.providerOnboarding),
              child: Text(
                l.publishHubResubmit,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.profile,
    required this.listingCount,
    required this.l,
  });
  final ProviderProfile profile;
  final int listingCount;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final contactsMonth = profile.stats?.contactsByMonth[monthKey] ?? 0;
    final contactsTotal = profile.stats?.contactsTotal ?? 0;
    final rating = profile.ratingAvg;

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
        children: [
          StatTile(
            value: contactsMonth.toString(),
            label: l.dashboardStatContactsMonth,
            icon: LucideIcons.phone,
          ),
          const SizedBox(width: KaziSpacing.sm),
          StatTile(
            value: contactsTotal.toString(),
            label: l.dashboardStatContactsTotal,
            icon: LucideIcons.users,
          ),
          const SizedBox(width: KaziSpacing.sm),
          StatTile(
            value: rating > 0 ? rating.toStringAsFixed(1) : '—',
            label: l.dashboardStatRating,
            icon: LucideIcons.star,
          ),
          const SizedBox(width: KaziSpacing.sm),
          StatTile(
            value: listingCount.toString(),
            label: l.dashboardStatListings,
            icon: LucideIcons.clipboardList,
          ),
        ],
      ),
    );
  }
}

// ── Listing card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.ctrl,
    required this.l,
  });
  final Listing listing;
  final DashboardController ctrl;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: KaziColors.surface,
          borderRadius: BorderRadius.circular(KaziRadius.card),
          border: Border.all(color: KaziColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(KaziRadius.card),
          onTap: () => context.push(Routes.editListing(listing.id)),
          child: Padding(
            padding: const EdgeInsets.all(KaziSpacing.md),
            child: Row(
              children: [
                _Thumbnail(listing: listing),
                const SizedBox(width: KaziSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KaziColors.ink,
                        ),
                      ),
                      const SizedBox(height: KaziSpacing.xs),
                      _StatusChip(listing: listing, l: l),
                    ],
                  ),
                ),
                _ActionMenu(listing: listing, ctrl: ctrl, l: l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final url = listing.photos.isNotEmpty ? listing.photos.first.url : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url != null
          ? KaziNetworkImage(url: url, width: 56, height: 56, fit: BoxFit.cover)
          : Container(
              width: 56,
              height: 56,
              color: KaziColors.surfaceAlt,
              child: const Icon(
                LucideIcons.image,
                size: 24,
                color: KaziColors.muted,
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.listing, required this.l});
  final Listing listing;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    // Active but not visible yet = publishing
    if (listing.status == ListingStatus.active && !listing.visible) {
      return _Chip(
        label: l.dashboardListingPublishing,
        color: KaziColors.star,
      );
    }
    final (label, color) = switch (listing.status) {
      ListingStatus.draft => (l.dashboardListingStatusDraft, KaziColors.muted),
      ListingStatus.active => (l.dashboardListingStatusActive, KaziColors.success),
      ListingStatus.paused => (l.dashboardListingStatusPaused, KaziColors.star),
    };
    return _Chip(label: label, color: color);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.listing,
    required this.ctrl,
    required this.l,
  });
  final Listing listing;
  final DashboardController ctrl;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      icon: const Icon(LucideIcons.ellipsisVertical, size: 18, color: KaziColors.muted),
      onSelected: (action) => _handle(context, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _Action.edit,
          child: Text(l.dashboardListingEdit),
        ),
        if (listing.status == ListingStatus.active && listing.visible)
          PopupMenuItem(
            value: _Action.pause,
            child: Text(l.dashboardListingPause),
          ),
        if (listing.status == ListingStatus.paused)
          PopupMenuItem(
            value: _Action.resume,
            child: Text(l.dashboardListingResume),
          ),
        PopupMenuItem(
          value: _Action.delete,
          child: Text(
            l.dashboardListingDelete,
            style: const TextStyle(color: KaziColors.error),
          ),
        ),
      ],
    );
  }

  Future<void> _handle(BuildContext context, _Action action) async {
    switch (action) {
      case _Action.edit:
        unawaited(context.push(Routes.editListing(listing.id)));
      case _Action.pause:
        await ctrl.pauseListing(listing.id);
      case _Action.resume:
        await ctrl.resumeListing(listing.id);
      case _Action.delete:
        final confirmed = await _confirmDelete(context);
        if (confirmed == true) await ctrl.deleteListing(listing.id);
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.dashboardListingDeleteConfirm),
        content: Text(l.dashboardListingDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l.dashboardListingDelete,
              style: const TextStyle(color: KaziColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Action { edit, pause, resume, delete }

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
      children: [
        SkeletonBox(width: null, height: 64),
        const SizedBox(height: KaziSpacing.lg),
        Row(
          children: [
            Expanded(child: SkeletonBox(width: null, height: 72)),
            const SizedBox(width: KaziSpacing.sm),
            Expanded(child: SkeletonBox(width: null, height: 72)),
            const SizedBox(width: KaziSpacing.sm),
            Expanded(child: SkeletonBox(width: null, height: 72)),
            const SizedBox(width: KaziSpacing.sm),
            Expanded(child: SkeletonBox(width: null, height: 72)),
          ],
        ),
        const SizedBox(height: KaziSpacing.xl),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: KaziSpacing.sm),
            child: SkeletonBox(width: null, height: 80),
          ),
        ),
      ],
    );
  }
}
