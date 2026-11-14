import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/contact_bar.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_avatar.dart';
import '../../../core/widgets/kazi_network_image.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../catalog/application/catalog_controller.dart';
import '../../contact/application/contact_controller.dart';
import '../../provider_profile/domain/provider_repository.dart';
import '../application/listing_detail_controller.dart';
import '../domain/listing_repository.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late final ListingDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ListingDetailController(
      context.read<ListingRepository>(),
      widget.listingId,
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
      child: Consumer<ListingDetailController>(
        builder: (context, ctrl, _) {
          final state = ctrl.state;

          if (state is ListingDetailLoading) {
            return _LoadingScreen(onBack: () => Navigator.of(context).maybePop());
          }

          if (state is ListingDetailError) {
            final msg = state.error is NetworkException
                ? l.errorNetwork
                : l.errorUnknown;
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
              ),
              body: ErrorView(
                message: msg,
                onRetry: ctrl.refresh,
                retryLabel: l.buttonRetry,
              ),
            );
          }

          if (state is ListingDetailNotFound) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
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

          final listing = (state as ListingDetailLoaded).listing;
          return _LoadedScreen(listing: listing);
        },
      ),
    );
  }
}

// ── Loaded screen ─────────────────────────────────────────────────────────────

class _LoadedScreen extends StatefulWidget {
  const _LoadedScreen({required this.listing});
  final Listing listing;

  @override
  State<_LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends State<_LoadedScreen> {
  int _photoIndex = 0;
  ProviderProfile? _provider;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    final profile = await context
        .read<ProviderRepository>()
        .getProvider(widget.listing.providerId);
    if (mounted) setState(() => _provider = profile);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final listing = widget.listing;
    final photos = listing.photos;

    return Scaffold(
      backgroundColor: KaziColors.surfaceAlt,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Photo carousel / app bar
                SliverAppBar(
                  expandedHeight: 280,
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
                        onTap: () {},
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: photos.isEmpty
                        ? Container(
                            color: KaziColors.surfaceAlt,
                            child: const Icon(LucideIcons.image,
                                size: 48, color: KaziColors.border),
                          )
                        : _PhotoCarousel(
                            photos: photos,
                            currentIndex: _photoIndex,
                            onChanged: (i) => setState(() => _photoIndex = i),
                          ),
                    collapseMode: CollapseMode.pin,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OfflineBanner(),

                      // Title + price
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          KaziSpacing.screenPadding,
                          KaziSpacing.xl,
                          KaziSpacing.screenPadding,
                          KaziSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.title,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: KaziColors.ink,
                              ),
                            ),
                            const SizedBox(height: KaziSpacing.sm),
                            Text(
                              KaziFormatters.price(
                                listing.priceAmount,
                                listing.currency.name.toUpperCase(),
                                listing.priceType.name,
                                locale: locale,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: KaziColors.primary,
                              ),
                            ),
                            if (listing.ratingCount > 0) ...[
                              const SizedBox(height: KaziSpacing.sm),
                              Row(
                                children: [
                                  RatingStars(rating: listing.ratingAvg, size: 14),
                                  const SizedBox(width: KaziSpacing.xs),
                                  Text(
                                    l.providerReviewCount(listing.ratingCount),
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: KaziColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const _Divider(),

                      // Description
                      if (listing.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KaziSpacing.screenPadding,
                            vertical: KaziSpacing.lg,
                          ),
                          child: Text(
                            listing.description,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: KaziColors.body,
                              height: 1.6,
                            ),
                          ),
                        ),

                      if (listing.description.isNotEmpty) const _Divider(),

                      // Communes served
                      if (listing.communes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KaziSpacing.screenPadding,
                            vertical: KaziSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.listingCommunesServed,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: KaziColors.ink,
                                ),
                              ),
                              const SizedBox(height: KaziSpacing.md),
                              Builder(
                                builder: (ctx) {
                                  final catalog = ctx.read<CatalogController>();
                                  return Wrap(
                                    spacing: KaziSpacing.sm,
                                    runSpacing: KaziSpacing.sm,
                                    children: listing.communes.map((c) {
                                      final label =
                                          catalog.communeById(c)?.name ?? c;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: KaziSpacing.md,
                                          vertical: KaziSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: KaziColors.primarySurface,
                                          borderRadius: BorderRadius.circular(
                                              KaziRadius.pill),
                                        ),
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 13,
                                            color: KaziColors.primary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      if (listing.communes.isNotEmpty) const _Divider(),

                      // Provider mini-card
                      _ProviderMiniCard(listing: listing, l: l),

                      const SizedBox(height: KaziSpacing.xxxl),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky contact bar
          ContactBar(
            onWhatsApp: () {
              final p = _provider;
              if (p == null) return;
              context.read<ContactController>().contactWhatsApp(
                context: context,
                providerId: p.uid,
                providerName: p.displayName,
                providerPhotoUrl: p.photoUrl,
                whatsappNumber: p.whatsappNumber,
                callNumber: p.callNumber,
                providerVerified: p.verified,
                listingId: listing.id,
                listingTitle: listing.title,
              );
            },
            onCall: () {
              final phone = _provider?.callNumber;
              if (phone == null) return;
              context.read<ContactController>().contactCall(
                context: context,
                providerId: _provider!.uid,
                providerName: _provider!.displayName,
                providerPhotoUrl: _provider!.photoUrl,
                phoneNumber: phone,
                whatsappNumber: _provider!.whatsappNumber,
                callNumber: phone,
                providerVerified: _provider!.verified,
                listingId: listing.id,
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

// ── Photo carousel ────────────────────────────────────────────────────────────

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({
    required this.photos,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<ListingPhoto> photos;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: photos.length,
          onPageChanged: onChanged,
          itemBuilder: (_, i) => KaziNetworkImage(url: photos[i].url),
        ),
        if (photos.length > 1)
          Positioned(
            bottom: KaziSpacing.md,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentIndex ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ── Provider mini-card ────────────────────────────────────────────────────────

class _ProviderMiniCard extends StatelessWidget {
  const _ProviderMiniCard({required this.listing, required this.l});

  final Listing listing;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final name = listing.providerName ?? '';
    if (name.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziSpacing.screenPadding,
        vertical: KaziSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.listingProviderCard,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KaziColors.ink,
            ),
          ),
          const SizedBox(height: KaziSpacing.md),
          GestureDetector(
            onTap: () => context.push(Routes.providerProfile(listing.providerId)),
            child: Container(
              padding: const EdgeInsets.all(KaziSpacing.md),
              decoration: BoxDecoration(
                color: KaziColors.surface,
                borderRadius: BorderRadius.circular(KaziRadius.card),
                boxShadow: KaziColors.cardShadow,
              ),
              child: Row(
                children: [
                  KaziAvatar(
                    name: name,
                    photoUrl: listing.providerPhotoUrl,
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
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: KaziColors.ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (listing.providerVerified) ...[
                              const SizedBox(width: KaziSpacing.xs),
                              const VerifiedBadge(),
                            ],
                          ],
                        ),
                        if (listing.ratingCount > 0) ...[
                          const SizedBox(height: KaziSpacing.xs),
                          Row(
                            children: [
                              RatingStars(rating: listing.ratingAvg, size: 12),
                              const SizedBox(width: KaziSpacing.xs),
                              Text(
                                l.providerReviewCount(listing.ratingCount),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  color: KaziColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      size: 16, color: KaziColors.muted),
                ],
              ),
            ),
          ),
        ],
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
          const SkeletonBox(width: double.infinity, height: 280, borderRadius: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(KaziSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 220, height: 22),
                  const SizedBox(height: KaziSpacing.sm),
                  const SkeletonBox(width: 100, height: 18),
                  const SizedBox(height: KaziSpacing.xl),
                  SkeletonBox(
                      width: MediaQuery.sizeOf(context).width - 40, height: 14),
                  const SizedBox(height: KaziSpacing.sm),
                  SkeletonBox(
                      width: MediaQuery.sizeOf(context).width - 80, height: 14),
                  const SizedBox(height: KaziSpacing.sm),
                  SkeletonBox(
                      width: MediaQuery.sizeOf(context).width - 120, height: 14),
                ],
              ),
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
