import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_avatar.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../auth/application/session_controller.dart';
import '../../provider_profile/domain/provider_repository.dart';
import '../../reports/presentation/report_sheet.dart';
import '../application/provider_reviews_controller.dart';
import '../domain/review_repository.dart';

/// S12: rating summary + the reviews of a provider, newest first.
class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({required this.providerId, super.key});

  final String providerId;

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  late final ProviderReviewsController _ctrl;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = ProviderReviewsController(
      context.read<ReviewRepository>(),
      context.read<ProviderRepository>(),
      context.read<SessionController>(),
      providerId: widget.providerId,
    )..init();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _write() async {
    await context.push(Routes.writeReview(widget.providerId));
    if (mounted) await _ctrl.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Scaffold(
        backgroundColor: KaziColors.surfaceAlt,
        appBar: AppBar(title: Text(l.reviewsTitle)),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Consumer<ProviderReviewsController>(
                builder: (context, ctrl, _) {
                  final state = ctrl.state;
                  if (state.isLoadingFirst) return const _Skeleton();
                  if (state.error != null && state.items.isEmpty) {
                    return ErrorView(
                      message: state.error is NetworkException
                          ? l.errorNetwork
                          : l.errorUnknown,
                      onRetry: ctrl.refresh,
                      retryLabel: l.buttonRetry,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: ctrl.refresh,
                    child: ListView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(KaziSpacing.screenPadding),
                      children: [
                        _Summary(ctrl: ctrl),
                        if (ctrl.canWrite) ...[
                          const SizedBox(height: KaziSpacing.lg),
                          KaziButton(
                            key: const ValueKey('reviews-write'),
                            label: l.reviewsWrite,
                            onPressed: _write,
                            variant: KaziButtonVariant.outline,
                          ),
                        ],
                        const SizedBox(height: KaziSpacing.lg),
                        if (state.items.isEmpty)
                          SizedBox(
                            height: 220,
                            child: EmptyState(message: l.reviewsEmpty),
                          )
                        else
                          for (final r in state.items) ...[
                            _ReviewTile(
                              review: r,
                              locale: locale,
                              mine: ctrl.isMine(r),
                              onEdit: _write,
                              onReport: () => showReportSheet(
                                context,
                                targetType: ReportTargetType.review,
                                targetKey:
                                    '${widget.providerId}__${r.authorUid}',
                              ),
                            ),
                            const SizedBox(height: KaziSpacing.md),
                          ],
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(KaziSpacing.lg),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.ctrl});
  final ProviderReviewsController ctrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final big = ctrl.ratingCount > 0
        ? formatRating(context, ctrl.ratingAvg)
        : null;
    return Container(
      padding: const EdgeInsets.all(KaziSpacing.lg),
      decoration: BoxDecoration(
        color: KaziColors.surface,
        borderRadius: BorderRadius.circular(KaziRadius.card),
        boxShadow: KaziColors.cardShadow,
      ),
      child: Row(
        children: [
          if (big != null) ...[
            Text(big, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(width: KaziSpacing.lg),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RatingSummary(
                rating: ctrl.ratingAvg,
                count: ctrl.ratingCount,
                starSize: 18,
              ),
            ),
          ),
          if (big == null)
            Text(l.reviewsEmpty, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.locale,
    required this.mine,
    required this.onEdit,
    required this.onReport,
  });

  final Review review;
  final String locale;
  final bool mine;
  final VoidCallback onEdit;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    // The anonymised copy of a deleted account is not a reportable document id.
    final reportable = !mine && review.authorUid != 'deleted';
    final date = review.createdAt == null
        ? null
        : KaziFormatters.fullDate(review.createdAt!, locale: locale);

    return Container(
      padding: const EdgeInsets.all(KaziSpacing.md),
      decoration: BoxDecoration(
        color: KaziColors.surface,
        borderRadius: BorderRadius.circular(KaziRadius.card),
        boxShadow: KaziColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaziAvatar(
                name: review.authorName,
                photoUrl: review.authorPhotoUrl,
                size: 36,
              ),
              const SizedBox(width: KaziSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (date != null) Text(date, style: text.bodySmall),
                  ],
                ),
              ),
              if (mine)
                TextButton(
                  key: const ValueKey('review-edit'),
                  onPressed: onEdit,
                  child: Text(l.reviewsEdit),
                ),
              if (reportable)
                IconButton(
                  key: ValueKey('review-report-${review.authorUid}'),
                  constraints: const BoxConstraints(
                    minWidth: kMinTapTarget,
                    minHeight: kMinTapTarget,
                  ),
                  tooltip: l.reviewsReport,
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 20,
                    color: KaziColors.muted,
                  ),
                  onPressed: onReport,
                ),
            ],
          ),
          const SizedBox(height: KaziSpacing.sm),
          Row(
            children: [
              RatingStars(rating: review.rating.toDouble()),
              if (mine) ...[
                const SizedBox(width: KaziSpacing.sm),
                Text(l.reviewsMineTag, style: text.labelSmall),
              ],
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: KaziSpacing.sm),
            Text(review.text, style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(KaziSpacing.screenPadding),
    children: [
      for (var i = 0; i < 4; i++) ...const [
        SkeletonBox(height: 96, width: double.infinity),
        SizedBox(height: KaziSpacing.md),
      ],
    ],
  );
}
