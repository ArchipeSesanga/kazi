import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/limits.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../auth/application/session_controller.dart';
import '../../contact/domain/contact_repository.dart';
import '../application/write_review_controller.dart';
import '../domain/review_repository.dart';

/// S12 form: 1–5 whole stars + an optional comment (≤ 300 characters). A user
/// who has not contacted the provider sees "Contactez ce prestataire …".
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({
    required this.providerId,
    this.controller,
    super.key,
  });

  final String providerId;

  /// Tests inject a controller; the app builds its own.
  final WriteReviewController? controller;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late final WriteReviewController _ctrl;
  final _text = TextEditingController();
  bool _textSeeded = false;

  @override
  void initState() {
    super.initState();
    _ctrl =
        widget.controller ??
        WriteReviewController(
          context.read<ReviewRepository>(),
          context.read<ContactRepository>(),
          context.read<SessionController>(),
          providerId: widget.providerId,
        );
    _ctrl.addListener(_onChange);
    _ctrl.init();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    if (widget.controller == null) _ctrl.dispose();
    _text.dispose();
    super.dispose();
  }

  void _onChange() {
    if (!_textSeeded && _ctrl.status == WriteReviewStatus.ready) {
      _textSeeded = true;
      _text.text = _ctrl.text;
    }
    if (_ctrl.done && mounted && !_closed) {
      _closed = true;
      final l = AppLocalizations.of(context);
      final msg = _ctrl.isEditing && _ctrl.existing != null && !_deleting
          ? l.reviewsUpdated
          : _deleting
          ? l.reviewsDeleted
          : l.reviewsPublished;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.of(context).maybePop();
    }
  }

  bool _closed = false;
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.reviewsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.buttonCancel),
          ),
          TextButton(
            key: const ValueKey('review-delete-confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.reviewsDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _deleting = true;
    await _ctrl.delete();
    if (_ctrl.error != null) _deleting = false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<WriteReviewController>(
        builder: (context, ctrl, _) => Scaffold(
          backgroundColor: KaziColors.surface,
          appBar: AppBar(
            title: Text(ctrl.isEditing ? l.reviewsEdit : l.reviewsWrite),
          ),
          body: SafeArea(child: _body(context, ctrl, l)),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WriteReviewController ctrl,
    AppLocalizations l,
  ) {
    switch (ctrl.status) {
      case WriteReviewStatus.loading:
        return const Center(child: CircularProgressIndicator.adaptive());
      case WriteReviewStatus.signInRequired:
        return EmptyState(
          key: const ValueKey('review-sign-in'),
          message: l.reviewsSignIn,
        );
      case WriteReviewStatus.ownProfile:
        return EmptyState(
          key: const ValueKey('review-own'),
          message: l.reviewsOwnProfile,
        );
      case WriteReviewStatus.needsContact:
        return EmptyState(
          key: const ValueKey('review-needs-contact'),
          icon: Icons.chat_bubble_outline_rounded,
          message: l.reviewsContactFirst,
        );
      case WriteReviewStatus.loadFailed:
        return ErrorView(
          message: ctrl.error is NetworkException
              ? l.errorNetwork
              : l.errorUnknown,
          onRetry: ctrl.init,
          retryLabel: l.buttonRetry,
        );
      case WriteReviewStatus.ready:
        return _form(context, ctrl, l);
    }
  }

  Widget _form(
    BuildContext context,
    WriteReviewController ctrl,
    AppLocalizations l,
  ) {
    final theme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(KaziSpacing.screenPadding),
      children: [
        Text(l.reviewsRateLabel, style: theme.titleSmall),
        const SizedBox(height: KaziSpacing.xs),
        RatingInput(value: ctrl.rating, onChanged: ctrl.setRating),
        if (ctrl.rating == 0)
          Padding(
            padding: const EdgeInsets.only(top: KaziSpacing.xs),
            child: Text(l.reviewsRatingRequired, style: theme.bodySmall),
          ),
        const SizedBox(height: KaziSpacing.xl),
        KaziTextField(
          label: l.reviewsTextLabel,
          hint: l.reviewsTextHint,
          controller: _text,
          maxLength: Limits.maxReviewTextChars,
          onChanged: ctrl.setText,
          textCapitalization: TextCapitalization.sentences,
        ),
        if (ctrl.error != null) ...[
          const SizedBox(height: KaziSpacing.md),
          Text(
            ctrl.error is NetworkException ? l.errorNetwork : l.errorUnknown,
            key: const ValueKey('review-error'),
            style: theme.bodySmall?.copyWith(color: KaziColors.error),
          ),
        ],
        const SizedBox(height: KaziSpacing.xl),
        KaziButton(
          key: const ValueKey('review-submit'),
          label: ctrl.isEditing ? l.buttonSave : l.reviewsPublish,
          onPressed: ctrl.canSubmit ? ctrl.submit : null,
          isLoading: ctrl.isSaving,
        ),
        if (ctrl.isEditing) ...[
          const SizedBox(height: KaziSpacing.md),
          KaziButton(
            key: const ValueKey('review-delete'),
            label: l.reviewsDelete,
            onPressed: ctrl.isSaving ? null : _confirmDelete,
            variant: KaziButtonVariant.text,
          ),
        ],
      ],
    );
  }
}
