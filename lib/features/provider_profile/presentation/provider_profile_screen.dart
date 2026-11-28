import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_bar.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_avatar.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_network_image.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../auth/application/session_controller.dart';
import '../../block/application/block_controller.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../contact/application/contact_controller.dart';
import '../../listings/domain/listing_repository.dart';
import '../../reports/presentation/report_sheet.dart';
import '../application/provider_profile_controller.dart';
import '../domain/provider_repository.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({required this.providerId, super.key});

  final String providerId;

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late final ProviderProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ProviderProfileController(
      context.read<ProviderRepository>(),
      widget.providerId,
    )..init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<ProviderProfileController>(
        builder: (context, ctrl, _) {
          final state = ctrl.state;

          if (state is ProviderProfileLoading) {
            return _LoadingScreen(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          if (state is ProviderProfileError) {
            final msg = state.error is NetworkException
                ? l.errorNetwork
                : l.errorUnknown;
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              body: ErrorView(
                message: msg,
                onRetry: () {},
                retryLabel: l.buttonRetry,
              ),
            );
          }

          if (state is ProviderProfileNotFound) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              body: Center(
                child: Text(
                  l.errorNotFound,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.muted,
                  ),
                ),
              ),
            );
          }

          final profile = (state as ProviderProfileLoaded).profile;

          // Pending profiles are not visible to others — show not-found.
          if (profile.status == ProviderStatus.pending) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              body: Center(
                child: Text(
                  l.errorNotFound,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.muted,
                  ),
                ),
              ),
            );
          }

          return _LoadedScreen(profile: profile);
        },
      ),
    );
  }
}

// ── Loaded screen ─────────────────────────────────────────────────────────────

class _LoadedScreen extends StatelessWidget {
  const _LoadedScreen({required this.profile});
  final ProviderProfile profile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Cover + avatar + actions
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  leading: Padding(
                    padding: const EdgeInsets.all(6),
                    child: _CircleIconButton(
                      icon: LucideIcons.arrowLeft,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: _CircleIconButton(
                        icon: LucideIcons.share2,
                        onTap: () {
                          final url = 'https://kazi.app/p/${profile.uid}';
                          final message = l.providerShareMessage(
                            profile.displayName,
                          );
                          Share.share('$message\n$url');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: _CircleIconButton(
                        icon: LucideIcons.flag,
                        onTap: () => showReportSheet(
                          context,
                          targetType: ReportTargetType.provider,
                          targetKey: profile.uid,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _BlockMenu(profile: profile, l: l),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: KaziNetworkImage(url: profile.coverUrl),
                    collapseMode: CollapseMode.pin,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OfflineBanner(),

                      // Avatar + name + rating
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KaziSpacing.screenPadding,
                          KaziSpacing.xl,
                          KaziSpacing.screenPadding,
                          KaziSpacing.lg,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KaziAvatar(
                              name: profile.displayName,
                              photoUrl: profile.photoUrl,
                              size: 64,
                            ),
                            const SizedBox(width: KaziSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          profile.displayName,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: KaziColors.ink,
                                          ),
                                        ),
                                      ),
                                      if (profile.verified) ...[
                                        const SizedBox(width: KaziSpacing.xs),
                                        const VerifiedBadge(),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: KaziSpacing.xs),
                                  RatingSummary(
                                    rating: profile.ratingAvg,
                                    count: profile.ratingCount,
                                    onTap: () => context.push(
                                      Routes.providerReviews(profile.uid),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats row
                      _StatsRow(profile: profile, l: l),

                      const _Divider(),

                      // Bio
                      if (profile.bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KaziSpacing.screenPadding,
                            vertical: KaziSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(title: l.providerBio),
                              const SizedBox(height: KaziSpacing.md),
                              Text(
                                profile.bio,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: KaziColors.body,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (profile.bio.isNotEmpty) const _Divider(),

                      // Categories
                      if (profile.categoryIds.isNotEmpty)
                        Builder(
                          builder: (ctx) {
                            final catalog = ctx.read<CatalogController>();
                            final cats = profile.categoryIds
                                .map((id) => catalog.categoryById(id))
                                .whereType<Category>()
                                .toList();
                            if (cats.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    KaziSpacing.screenPadding,
                                    KaziSpacing.lg,
                                    KaziSpacing.screenPadding,
                                    KaziSpacing.md,
                                  ),
                                  child: Wrap(
                                    spacing: KaziSpacing.sm,
                                    runSpacing: KaziSpacing.sm,
                                    children: cats.map((c) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: KaziSpacing.md,
                                          vertical: KaziSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: KaziColors.primarySurface,
                                          borderRadius: BorderRadius.circular(
                                            KaziRadius.pill,
                                          ),
                                        ),
                                        child: Text(
                                          c.label(locale),
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13,
                                            color: KaziColors.primary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const _Divider(),
                              ],
                            );
                          },
                        ),

                      // Services (listings)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KaziSpacing.screenPadding,
                          KaziSpacing.lg,
                          KaziSpacing.screenPadding,
                          KaziSpacing.md,
                        ),
                        child: SectionHeader(title: l.providerServices),
                      ),
                      _ListingsSection(
                        providerId: profile.uid,
                        locale: locale,
                        l: l,
                      ),

                      const _Divider(),

                      // Portfolio
                      if (profile.portfolio.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KaziSpacing.screenPadding,
                            KaziSpacing.lg,
                            KaziSpacing.screenPadding,
                            KaziSpacing.md,
                          ),
                          child: SectionHeader(title: l.providerPortfolio),
                        ),
                        _PortfolioGrid(photos: profile.portfolio),
                        const _Divider(),
                      ],

                      // Reviews teaser
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KaziSpacing.screenPadding,
                          vertical: KaziSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.providerReviews,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: KaziColors.ink,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(
                                Routes.providerReviews(profile.uid),
                              ),
                              child: Text(
                                l.buttonSeeAll,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  color: KaziColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (profile.ratingCount == 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KaziSpacing.screenPadding,
                            0,
                            KaziSpacing.screenPadding,
                            KaziSpacing.xl,
                          ),
                          child: Text(
                            l.reviewsEmpty,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: KaziColors.muted,
                            ),
                          ),
                        ),

                      // Anyone but the provider can open the review form; it shows
                      // "Contactez ce prestataire …" until they have made contact.
                      if (context.read<SessionController>().uid != profile.uid)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KaziSpacing.screenPadding,
                            0,
                            KaziSpacing.screenPadding,
                            0,
                          ),
                          child: KaziButton(
                            key: const ValueKey('profile-write-review'),
                            label: l.reviewsWrite,
                            variant: KaziButtonVariant.outline,
                            isFullWidth: false,
                            onPressed: () =>
                                context.push(Routes.writeReview(profile.uid)),
                          ),
                        ),

                      const SizedBox(height: KaziSpacing.xxxl),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky contact bar
          ContactBar(
            onWhatsApp: () => context.read<ContactController>().contactWhatsApp(
              context: context,
              providerId: profile.uid,
              providerName: profile.displayName,
              providerPhotoUrl: profile.photoUrl,
              whatsappNumber: profile.whatsappNumber,
              callNumber: profile.callNumber,
              providerVerified: profile.verified,
            ),
            onCall: () {
              final phone = profile.callNumber;
              if (phone == null) return;
              context.read<ContactController>().contactCall(
                context: context,
                providerId: profile.uid,
                providerName: profile.displayName,
                providerPhotoUrl: profile.photoUrl,
                phoneNumber: phone,
                whatsappNumber: profile.whatsappNumber,
                callNumber: phone,
                providerVerified: profile.verified,
              );
            },
            whatsAppLabel: l.providerWhatsAppButton,
            callLabel: l.providerCallButton,
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile, required this.l});
  final ProviderProfile profile;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '${profile.yearsExperience}',
              label: l.providerExperience,
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatCell(
              value: '${profile.listingCount}',
              label: l.providerWorks,
            ),
          ),
          _StatDivider(),
          Expanded(
            child: _StatCell(
              value: '${profile.stats?.contactsTotal ?? 0}',
              label: l.providerContacts,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: KaziColors.ink,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          color: KaziColors.muted,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: KaziColors.border);
}

// ── Listings section ──────────────────────────────────────────────────────────

class _ListingsSection extends StatefulWidget {
  const _ListingsSection({
    required this.providerId,
    required this.locale,
    required this.l,
  });
  final String providerId;
  final String locale;
  final AppLocalizations l;

  @override
  State<_ListingsSection> createState() => _ListingsSectionState();
}

class _ListingsSectionState extends State<_ListingsSection> {
  List<Listing>? _listings;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _failed = false);
    try {
      final repo = context.read<ListingRepository>();
      final result = await repo.fetchByProvider(widget.providerId);
      if (mounted) setState(() => _listings = result.items);
    } catch (e) {
      // Surface the failure (e.g. a missing index) instead of showing an
      // empty list that looks like "no listings".
      debugPrint('[ProviderProfile] listings query failed: $e');
      if (mounted) {
        setState(() {
          _failed = true;
          _listings = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.screenPadding,
          vertical: KaziSpacing.sm,
        ),
        child: ErrorView(
          message: widget.l.listingsLoadFailed,
          onRetry: _load,
          retryLabel: widget.l.buttonRetry,
        ),
      );
    }
    final listings = _listings;
    if (listings == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
        child: Column(
          children: [
            SkeletonBox(width: double.infinity, height: 72),
            SizedBox(height: KaziSpacing.sm),
            SkeletonBox(width: double.infinity, height: 72),
          ],
        ),
      );
    }
    if (listings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.screenPadding,
          vertical: KaziSpacing.sm,
        ),
        child: Text(
          widget.l.homeEmptyRecent,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: KaziColors.muted,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.sm,
      ),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: KaziSpacing.sm),
      itemBuilder: (_, i) {
        final listing = listings[i];
        return GestureDetector(
          onTap: () => context.push(Routes.listingDetail(listing.id)),
          child: Container(
            padding: const EdgeInsets.all(KaziSpacing.md),
            decoration: BoxDecoration(
              color: KaziColors.surface,
              borderRadius: BorderRadius.circular(KaziRadius.card),
              boxShadow: KaziColors.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KaziColors.ink,
                        ),
                      ),
                      const SizedBox(height: KaziSpacing.xs),
                      Text(
                        KaziFormatters.price(
                          listing.priceAmount,
                          listing.currency.name.toUpperCase(),
                          listing.priceType.name,
                          locale: widget.locale,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: KaziColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: KaziColors.muted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Portfolio grid ────────────────────────────────────────────────────────────

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid({required this.photos});
  final List<PortfolioPhoto> photos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.sm,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: KaziSpacing.sm,
          mainAxisSpacing: KaziSpacing.sm,
        ),
        itemCount: photos.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(KaziRadius.card),
          child: KaziNetworkImage(url: photos[i].url),
        ),
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: Column(
        children: [
          const SkeletonBox(
            width: double.infinity,
            height: 200,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(KaziSpacing.screenPadding),
            child: Row(
              children: [
                const SkeletonBox(width: 64, height: 64, borderRadius: 32),
                const SizedBox(width: KaziSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 160, height: 18),
                    const SizedBox(height: KaziSpacing.xs),
                    SkeletonBox(
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    thickness: 1,
    color: KaziColors.border,
    indent: KaziSpacing.screenPadding,
    endIndent: KaziSpacing.screenPadding,
  );
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: KaziColors.ink),
      ),
    );
  }
}

// ── Block overflow menu ───────────────────────────────────────────────────────

enum _ProfileMenuAction { block, unblock }

class _BlockMenu extends StatelessWidget {
  const _BlockMenu({required this.profile, required this.l});
  final ProviderProfile profile;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final blocked = context.watch<BlockController>();
    final isBlocked = blocked.isBlocked(profile.uid);

    return PopupMenuButton<_ProfileMenuAction>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KaziRadius.card),
      ),
      onSelected: (action) => _onSelected(context, action, blocked),
      itemBuilder: (_) => [
        PopupMenuItem<_ProfileMenuAction>(
          value: isBlocked
              ? _ProfileMenuAction.unblock
              : _ProfileMenuAction.block,
          child: Row(
            children: [
              Icon(
                isBlocked ? LucideIcons.shieldCheck : LucideIcons.ban,
                size: 16,
                color: isBlocked ? KaziColors.primary : KaziColors.error,
              ),
              const SizedBox(width: KaziSpacing.sm),
              Text(
                isBlocked ? l.providerUnblock : l.providerBlock,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: isBlocked ? KaziColors.ink : KaziColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            LucideIcons.moreVertical,
            size: 18,
            color: KaziColors.ink,
          ),
        ),
      ),
    );
  }

  Future<void> _onSelected(
    BuildContext context,
    _ProfileMenuAction action,
    BlockController blocked,
  ) async {
    if (action == _ProfileMenuAction.unblock) {
      await blocked.unblock(profile.uid);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.providerUnblockedSnackbar)));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(ctx).providerBlockTitle(profile.displayName),
        ),
        content: Text(AppLocalizations.of(ctx).providerBlockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx).buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppLocalizations.of(ctx).providerBlockConfirm,
              style: const TextStyle(color: KaziColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await blocked.block(profile.uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).providerBlockedSnackbar),
      ),
    );
    Navigator.of(context).maybePop();
  }
}
