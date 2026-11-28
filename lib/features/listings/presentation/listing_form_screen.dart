import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/limits.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/category_icon.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_chip.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../catalog/application/catalog_controller.dart';
import '../application/listing_form_controller.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({this.listingId, super.key});

  final String? listingId;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  final _picker = ImagePicker();
  bool _handledSave = false;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<ListingFormController>();
    _titleCtrl = TextEditingController(text: ctrl.title);
    _descCtrl = TextEditingController(text: ctrl.description);
    _priceCtrl = TextEditingController(text: ctrl.priceAmountText);
    _titleCtrl.addListener(() => ctrl.setTitle(_titleCtrl.text));
    _descCtrl.addListener(() => ctrl.setDescription(_descCtrl.text));
    _priceCtrl.addListener(() => ctrl.setPriceAmount(_priceCtrl.text));
    ctrl.addListener(_onCtrlChanged);
  }

  void _onCtrlChanged() {
    if (!mounted) return;
    final ctrl = context.read<ListingFormController>();
    if (ctrl.isLoading) return;

    // Sync text controllers when editing mode populates fields on first load.
    if (_titleCtrl.text != ctrl.title) {
      _titleCtrl.value = _titleCtrl.value.copyWith(text: ctrl.title);
    }
    if (_descCtrl.text != ctrl.description) {
      _descCtrl.value = _descCtrl.value.copyWith(text: ctrl.description);
    }
    if (_priceCtrl.text != ctrl.priceAmountText) {
      _priceCtrl.value = _priceCtrl.value.copyWith(text: ctrl.priceAmountText);
    }

    final status = ctrl.savedStatus;
    if (status != null && !_handledSave) {
      _handledSave = true;
      final l = AppLocalizations.of(context);
      if (ctrl.savedAsUpdate) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.listingFormUpdated)));
        Navigator.of(context).pop();
      } else if (status == ListingStatus.active) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.listingFormPublished)));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.listingFormDraftSaved)));
        _handledSave = false;
      }
    }
  }

  @override
  void dispose() {
    final ctrl = context.read<ListingFormController>();
    ctrl.removeListener(_onCtrlChanged);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onPop() async {
    final ctrl = context.read<ListingFormController>();
    if (!ctrl.hasDraft || ctrl.savedStatus != null) return true;
    final l = AppLocalizations.of(context);
    final keep = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.listingFormDraftDialogTitle),
        content: Text(l.listingFormDraftDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.listingFormDraftDiscard),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.listingFormDraftKeep),
          ),
        ],
      ),
    );
    if (keep == null) return false;
    if (!keep) await ctrl.discardDraft();
    return true;
  }

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l.listingFormPhotoPickGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l.listingFormPhotoPickCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final file = await _picker.pickImage(source: source, imageQuality: 90);
    if (file == null || !mounted) return;
    await context.read<ListingFormController>().addPhoto(file);
  }

  String _errorMessage(BuildContext context, String code) {
    final l = AppLocalizations.of(context);
    return switch (code) {
      'network' => l.errorNetwork,
      'permissionDenied' => l.errorPermissionDenied,
      'notFound' => l.errorNotFound,
      'unauthenticated' => l.errorUnauthenticated,
      'quotaExceeded' => l.listingLimitReachedBody(
        context.read<ListingFormController>().quota?.max ??
            Limits.maxListingsPerProvider,
      ),
      _ => l.errorUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<ListingFormController>();

    if (ctrl.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            ctrl.isEditing ? l.listingFormEditTitle : l.listingFormTitle,
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(KaziSpacing.lg),
          child: Column(
            children: [
              SkeletonBox(
                width: null,
                height: 160,
                borderRadius: KaziRadius.card,
              ),
              SizedBox(height: KaziSpacing.md),
              SkeletonBox(
                width: null,
                height: 48,
                borderRadius: KaziRadius.input,
              ),
              SizedBox(height: KaziSpacing.md),
              SkeletonBox(
                width: null,
                height: 48,
                borderRadius: KaziRadius.input,
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _onPop()) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            ctrl.isEditing ? l.listingFormEditTitle : l.listingFormTitle,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            KaziSpacing.lg,
            KaziSpacing.lg,
            KaziSpacing.lg,
            176,
          ),
          children: [
            if (ctrl.limitReached) ...[
              _LimitBanner(
                title: l.listingLimitReachedTitle,
                body: l.listingLimitReachedBody(ctrl.quota!.max),
              ),
              const SizedBox(height: KaziSpacing.lg),
            ],
            _PhotoSection(
              photos: ctrl.photos,
              canAdd: ctrl.canAddPhoto,
              onAdd: _pickPhoto,
              onRemove: ctrl.removePhoto,
            ),
            const SizedBox(height: KaziSpacing.xl),
            KaziTextField(
              label: l.listingFormTitleLabel,
              hint: l.listingFormTitleHint,
              controller: _titleCtrl,
              errorText: ctrl.titleError != null
                  ? l.listingFormTitleError
                  : null,
              maxLength: 80,
            ),
            const SizedBox(height: KaziSpacing.lg),
            _CategoryPicker(
              selectedId: ctrl.categoryId,
              errorText: ctrl.categoryError != null
                  ? l.listingFormCategoryError
                  : null,
              onSelected: ctrl.setCategory,
            ),
            const SizedBox(height: KaziSpacing.lg),
            KaziTextArea(
              label: l.listingFormDescriptionLabel,
              hint: l.listingFormDescriptionHint,
              controller: _descCtrl,
              maxLength: 1000,
            ),
            const SizedBox(height: KaziSpacing.lg),
            _PriceSection(
              priceType: ctrl.priceType,
              currency: ctrl.currency,
              priceCtrl: _priceCtrl,
              onPriceType: ctrl.setPriceType,
              onCurrency: ctrl.setCurrency,
            ),
            const SizedBox(height: KaziSpacing.lg),
            _CommuneSection(
              selected: ctrl.communes,
              errorText: ctrl.communeError != null
                  ? l.listingFormCommuneError
                  : null,
              onToggle: ctrl.toggleCommune,
            ),
            if (ctrl.error != null) ...[
              const SizedBox(height: KaziSpacing.lg),
              ErrorView(
                message: _errorMessage(context, ctrl.error!.code),
                onRetry: ctrl.clearError,
              ),
            ],
          ],
        ),
        bottomNavigationBar: ListingFormBottomBar(
          isSaving: ctrl.isSaving,
          hasUploading: ctrl.photos.any((p) => p.isUploading),
          limitReached: ctrl.limitReached,
          singleSave: ctrl.preservesStatus,
          onDraft: ctrl.saveDraft,
          onPublish: ctrl.publish,
          onSave: ctrl.save,
        ),
      ),
    );
  }
}

class _LimitBanner extends StatelessWidget {
  const _LimitBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KaziSpacing.md),
      decoration: BoxDecoration(
        color: KaziColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KaziRadius.card),
        border: Border.all(color: KaziColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KaziColors.error,
            ),
          ),
          const SizedBox(height: KaziSpacing.xs),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: KaziColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo section ─────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photos,
    required this.canAdd,
    required this.onAdd,
    required this.onRemove,
  });

  final List<PhotoEntry> photos;
  final bool canAdd;
  final VoidCallback onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.listingFormPhotosLabel(6),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: KaziSpacing.sm),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...photos.map((p) => _PhotoTile(entry: p, onRemove: onRemove)),
              if (canAdd)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: KaziSpacing.sm),
                    decoration: BoxDecoration(
                      color: KaziColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(KaziRadius.card),
                      border: Border.all(color: KaziColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.plus, color: KaziColors.muted),
                        const SizedBox(height: 4),
                        Text(
                          l.listingFormAddPhoto,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: KaziColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.entry, required this.onRemove});

  final PhotoEntry entry;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (entry.url != null) {
      image = Image.network(entry.url!, fit: BoxFit.cover);
    } else if (entry.localFile != null) {
      image = Image.file(File(entry.localFile!.path), fit: BoxFit.cover);
    } else {
      image = const SizedBox.shrink();
    }

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: KaziSpacing.sm),
          decoration: BoxDecoration(
            color: KaziColors.surfaceAlt,
            borderRadius: BorderRadius.circular(KaziRadius.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: image,
        ),
        if (entry.isUploading)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(right: KaziSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(KaziRadius.card),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: entry.progress,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        if (entry.hasError)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(right: KaziSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(KaziRadius.card),
              ),
              child: const Center(
                child: Icon(LucideIcons.alertTriangle, color: KaziColors.error),
              ),
            ),
          ),
        if (!entry.isUploading)
          Positioned(
            top: 4,
            right: 12,
            child: GestureDetector(
              onTap: () => onRemove(entry.id),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Category picker ───────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selectedId,
    required this.errorText,
    required this.onSelected,
  });

  final String? selectedId;
  final String? errorText;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cats = context.watch<CatalogController>().selectable;
    final locale = Localizations.localeOf(context).languageCode;
    final selected = cats.where((c) => c.id == selectedId).firstOrNull;

    return GestureDetector(
      onTap: () => _showSheet(context, cats, locale),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l.listingFormCategoryLabel,
          errorText: errorText,
          suffixIcon: const Icon(LucideIcons.chevronsUpDown, size: 18),
        ),
        child: Text(
          selected != null ? selected.label(locale) : l.listingFormCategoryHint,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected != null ? KaziColors.ink : KaziColors.muted,
          ),
        ),
      ),
    );
  }

  Future<void> _showSheet(
    BuildContext context,
    List<Category> cats,
    String locale,
  ) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scroll) => ListView.builder(
          controller: scroll,
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final cat = cats[i];
            return ListTile(
              key: ValueKey('listing-category-${cat.id}'),
              leading: Icon(
                categoryIconFor(cat.iconKey),
                color: KaziColors.primary,
              ),
              title: Text(cat.label(locale)),
              selected: cat.id == selectedId,
              selectedColor: KaziColors.accent,
              onTap: () => Navigator.pop(ctx, cat.id),
            );
          },
        ),
      ),
    );
    if (id != null) onSelected(id);
  }
}

// ── Price section ─────────────────────────────────────────────────────────────

class _PriceSection extends StatelessWidget {
  const _PriceSection({
    required this.priceType,
    required this.currency,
    required this.priceCtrl,
    required this.onPriceType,
    required this.onCurrency,
  });

  final PriceType priceType;
  final Currency currency;
  final TextEditingController priceCtrl;
  final void Function(PriceType) onPriceType;
  final void Function(Currency) onCurrency;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KaziChip(
              label: l.listingFormPriceTypeFixed,
              isSelected: priceType == PriceType.fixed,
              onTap: () => onPriceType(PriceType.fixed),
            ),
            const SizedBox(width: KaziSpacing.sm),
            KaziChip(
              label: l.listingFormPriceTypeFrom,
              isSelected: priceType == PriceType.from,
              onTap: () => onPriceType(PriceType.from),
            ),
            const SizedBox(width: KaziSpacing.sm),
            KaziChip(
              label: l.listingFormPriceQuoteToggle,
              isSelected: priceType == PriceType.quote,
              onTap: () => onPriceType(PriceType.quote),
            ),
          ],
        ),
        if (priceType != PriceType.quote) ...[
          const SizedBox(height: KaziSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KaziTextField(
                  label: l.listingFormPriceLabel,
                  hint: l.listingFormAmountHint,
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                ),
              ),
              const SizedBox(width: KaziSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _CurrencyToggle(
                  currency: currency,
                  onChanged: onCurrency,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.currency, required this.onChanged});

  final Currency currency;
  final void Function(Currency) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: KaziColors.border),
        borderRadius: BorderRadius.circular(KaziRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CurrencyBtn(
            label: 'USD',
            selected: currency == Currency.usd,
            onTap: () => onChanged(Currency.usd),
          ),
          _CurrencyBtn(
            label: 'CDF',
            selected: currency == Currency.cdf,
            onTap: () => onChanged(Currency.cdf),
          ),
        ],
      ),
    );
  }
}

class _CurrencyBtn extends StatelessWidget {
  const _CurrencyBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.md,
          vertical: KaziSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? KaziColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(KaziRadius.button - 1),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : KaziColors.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Commune section ───────────────────────────────────────────────────────────

class _CommuneSection extends StatelessWidget {
  const _CommuneSection({
    required this.selected,
    required this.errorText,
    required this.onToggle,
  });

  final List<String> selected;
  final String? errorText;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cities = context.watch<CatalogController>().cities;
    final communes = cities.expand((city) => city.communes).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.listingFormCommunesLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l.listingFormCommuneHint,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: KaziColors.muted),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: KaziColors.error),
          ),
        ],
        const SizedBox(height: KaziSpacing.sm),
        Wrap(
          spacing: KaziSpacing.xs,
          runSpacing: KaziSpacing.xs,
          children: communes.map((c) {
            final isSelected = selected.contains(c.id);
            return KaziChip(
              label: c.name,
              isSelected: isSelected,
              onTap: () => onToggle(c.id),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

/// Bottom action bar of the listing form.
class ListingFormBottomBar extends StatelessWidget {
  const ListingFormBottomBar({
    super.key,
    required this.isSaving,
    required this.hasUploading,
    required this.limitReached,
    required this.singleSave,
    required this.onDraft,
    required this.onPublish,
    required this.onSave,
  });

  final bool isSaving;
  final bool hasUploading;
  final bool limitReached;

  /// Editing an active/paused listing: one Save button, status unchanged.
  final bool singleSave;
  final VoidCallback onDraft;
  final VoidCallback onPublish;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final disabled = isSaving || hasUploading || limitReached;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KaziSpacing.lg,
          KaziSpacing.sm,
          KaziSpacing.lg,
          KaziSpacing.md,
        ),
        child: singleSave
            ? KaziButton(
                label: l.buttonSave,
                onPressed: disabled ? null : onSave,
                isLoading: isSaving,
              )
            // Stacked, not side by side: "Enregistrer le brouillon" does not
            // fit in half the screen width (and never at larger text sizes).
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KaziButton(
                    label: l.listingFormPublish,
                    onPressed: disabled ? null : onPublish,
                    isLoading: isSaving,
                  ),
                  const SizedBox(height: KaziSpacing.sm),
                  KaziButton(
                    label: l.listingFormSaveDraft,
                    onPressed: disabled ? null : onDraft,
                    variant: KaziButtonVariant.outline,
                    isLoading: isSaving,
                  ),
                ],
              ),
      ),
    );
  }
}
