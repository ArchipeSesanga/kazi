import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/enums.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_chip.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../../core/widgets/stepper_bar.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/user_repository.dart';
import '../../catalog/application/catalog_controller.dart';
import '../application/provider_onboarding_controller.dart';
import '../domain/media_repository.dart';
import '../domain/provider_repository.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  late final OnboardingController _ctrl;
  final _form1Key = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _callCtrl;
  bool _consentError = false;
  String? _step2Error;

  // Entry check: is there already a providers/{uid} doc, and if so what do
  // we do about it (see the redirect/resubmit rules in _checkExisting).
  bool _checkingEntry = true;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = OnboardingController(
      context.read<ProviderRepository>(),
      context.read<SessionController>(),
      context.read<MediaRepository>(),
      context.read<UserRepository>(),
    );
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _whatsappCtrl = TextEditingController();
    _callCtrl = TextEditingController();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final uid = context.read<SessionController>().uid;
    if (uid == null) {
      if (mounted) setState(() => _checkingEntry = false);
      return;
    }
    try {
      final existing = await context.read<ProviderRepository>().getProvider(
        uid,
      );
      if (!mounted) return;
      if (existing == null) {
        setState(() => _checkingEntry = false);
        return;
      }
      switch (existing.status) {
        case ProviderStatus.rejected:
          _ctrl.prefillForResubmit(existing);
          _nameCtrl.text = _ctrl.displayName;
          _bioCtrl.text = _ctrl.bio;
          _whatsappCtrl.text = _ctrl.whatsappNumber;
          _callCtrl.text = _ctrl.callNumber;
          setState(() => _checkingEntry = false);
        case ProviderStatus.pending:
        case ProviderStatus.approved:
        case ProviderStatus.suspended:
          // A doc already exists — re-submitting a create-style payload
          // against it would be evaluated as an update and denied. Only a
          // rejected profile may resubmit; everything else belongs on the
          // dashboard.
          setState(() => _redirecting = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.pushReplacement(Routes.providerDashboard);
          });
      }
    } catch (_) {
      // Don't trap the user on a blank screen over a transient read error —
      // fall back to the create form; the write path still verifies itself.
      if (mounted) setState(() => _checkingEntry = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _whatsappCtrl.dispose();
    _callCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_ctrl.step == 1) {
      final formValid = _form1Key.currentState!.validate();
      setState(() => _consentError = !_ctrl.hasConsent);
      if (!formValid || !_ctrl.hasConsent) return;
      _ctrl.goToStep(2);
    } else if (_ctrl.step == 2) {
      if (_ctrl.categoryIds.isEmpty) {
        setState(() => _step2Error = 'category');
        return;
      }
      if (_ctrl.baseCommune == null) {
        setState(() => _step2Error = 'commune');
        return;
      }
      setState(() => _step2Error = null);
      _ctrl.goToStep(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingEntry || _redirecting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<OnboardingController>(
        builder: (ctx, ctrl, _) {
          if (ctrl.isDone) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!ctx.mounted) return;
              ctx.pushReplacement(Routes.providerDashboard);
            });
          }
          if (ctrl.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!ctx.mounted) return;
              final message = switch (ctrl.error) {
                PermissionDeniedException() => AppLocalizations.of(
                  ctx,
                ).errorPermissionDenied,
                InvalidInputException() => AppLocalizations.of(
                  ctx,
                ).errorInvalidInput,
                _ => AppLocalizations.of(ctx).errorUnknown,
              };
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 6),
                ),
              );
              ctrl.clearError();
            });
          }

          final l = AppLocalizations.of(ctx);
          return Scaffold(
            backgroundColor: KaziColors.surface,
            appBar: AppBar(
              title: Text(l.onboardingTitle),
              leading: ctrl.step > 1
                  ? IconButton(
                      icon: const Icon(LucideIcons.arrowLeft),
                      onPressed: () => ctrl.goToStep(ctrl.step - 1),
                    )
                  : null,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KaziSpacing.screenPadding,
                      KaziSpacing.md,
                      KaziSpacing.screenPadding,
                      KaziSpacing.sm,
                    ),
                    child: StepperBar(
                      totalSteps: OnboardingController.totalSteps,
                      currentStep: ctrl.step,
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: ctrl.step - 1,
                      children: [
                        _Step1(
                          ctrl: ctrl,
                          formKey: _form1Key,
                          nameCtrl: _nameCtrl,
                          bioCtrl: _bioCtrl,
                          whatsappCtrl: _whatsappCtrl,
                          callCtrl: _callCtrl,
                          consentError: _consentError,
                        ),
                        _Step2(ctrl: ctrl, error: _step2Error),
                        _Step3(ctrl: ctrl),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KaziSpacing.screenPadding,
                      KaziSpacing.sm,
                      KaziSpacing.screenPadding,
                      KaziSpacing.lg,
                    ),
                    child: ctrl.step < OnboardingController.totalSteps
                        ? KaziButton(
                            label: l.buttonContinue,
                            onPressed: _onNext,
                          )
                        : KaziButton(
                            label: l.onboardingSubmit,
                            onPressed: ctrl.isSubmitting ? null : ctrl.submit,
                            isLoading: ctrl.isSubmitting,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Step 1: Basic info ────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.ctrl,
    required this.formKey,
    required this.nameCtrl,
    required this.bioCtrl,
    required this.whatsappCtrl,
    required this.callCtrl,
    required this.consentError,
  });

  final OnboardingController ctrl;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController bioCtrl;
  final TextEditingController whatsappCtrl;
  final TextEditingController callCtrl;
  final bool consentError;


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          KaziSpacing.screenPadding,
          KaziSpacing.md,
          KaziSpacing.screenPadding,
          KaziSpacing.xxxl,
        ),
        children: [
          Text(
            l.onboardingStep1,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KaziColors.ink,
            ),
          ),
          const SizedBox(height: KaziSpacing.xl),
          _PhotoPickers(ctrl: ctrl),
          const SizedBox(height: KaziSpacing.xl),
          KaziTextField(
            label: l.onboardingNameLabel,
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: 60,
            onChanged: (v) => ctrl.displayName = v,
            validator: (v) {
              if ((v?.trim().length ?? 0) < 2) return l.errorInvalidInput;
              return null;
            },
          ),
          const SizedBox(height: KaziSpacing.lg),
          KaziTextArea(
            label: l.onboardingBioLabel,
            hint: l.onboardingBioHint,
            controller: bioCtrl,
            maxLength: 600,
            onChanged: (v) => ctrl.bio = v,
          ),
          const SizedBox(height: KaziSpacing.lg),
          KaziTextField(
            label: l.onboardingWhatsAppLabel,
            controller: whatsappCtrl,
            hint: '+243 81 234 5678',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: (v) => ctrl.whatsappNumber = v,
            validator: (v) {
              if (PhoneUtils.normalise(v ?? '') == null) {
                return l.onboardingPhoneInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: KaziSpacing.lg),
          KaziTextField(
            label: l.onboardingPhoneLabel,
            controller: callCtrl,
            hint: '+243 81 234 5678',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onChanged: (v) => ctrl.callNumber = v,
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return null;
              if (PhoneUtils.normalise(val) == null) {
                return l.onboardingPhoneInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: KaziSpacing.lg),
          _YearsStepper(ctrl: ctrl),
          const SizedBox(height: KaziSpacing.xl),
          _ConsentRow(ctrl: ctrl, hasError: consentError),
        ],
      ),
    );
  }
}

class _YearsStepper extends StatelessWidget {
  const _YearsStepper({required this.ctrl});
  final OnboardingController ctrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.onboardingYearsLabel,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.sm),
        Row(
          children: [
            _StepBtn(
              icon: LucideIcons.minus,
              onTap: ctrl.decrementYears,
              enabled: ctrl.yearsExperience > 0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.xl),
              child: Text(
                '${ctrl.yearsExperience}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KaziColors.ink,
                ),
              ),
            ),
            _StepBtn(
              icon: LucideIcons.plus,
              onTap: ctrl.incrementYears,
              enabled: ctrl.yearsExperience < 60,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? KaziColors.border : KaziColors.border,
          ),
          borderRadius: BorderRadius.circular(KaziRadius.button),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? KaziColors.ink : KaziColors.muted,
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.ctrl, required this.hasError});
  final OnboardingController ctrl;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: ctrl.hasConsent,
                onChanged: (v) => ctrl.setConsent(v ?? false),
                activeColor: KaziColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: KaziSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => ctrl.setConsent(!ctrl.hasConsent),
                child: Text(
                  l.onboardingPublicConsent,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    color: KaziColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: KaziSpacing.xs),
          Text(
            l.errorInvalidInput,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: KaziColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Step 2: Service details ───────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  const _Step2({required this.ctrl, this.error});
  final OnboardingController ctrl;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final catalog = context.watch<CatalogController>();
    final allCommunes = catalog.cities.expand((c) => c.communes).toList();
    final baseCommuneName = ctrl.baseCommune != null
        ? allCommunes
              .where((c) => c.id == ctrl.baseCommune)
              .map((c) => c.name)
              .firstOrNull
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KaziSpacing.screenPadding,
        KaziSpacing.md,
        KaziSpacing.screenPadding,
        KaziSpacing.xxxl,
      ),
      children: [
        Text(
          l.onboardingStep2,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xl),
        Text(
          l.onboardingCategoriesLabel,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.sm),
        Wrap(
          spacing: KaziSpacing.sm,
          runSpacing: KaziSpacing.sm,
          children: catalog.categories.map((cat) {
            final label = locale.startsWith('fr') ? cat.name.fr : cat.name.en;
            final isSelected = ctrl.categoryIds.contains(cat.id);
            final atLimit = ctrl.categoryIds.length >= 3 && !isSelected;
            return KaziChip(
              label: label,
              isSelected: isSelected,
              onTap: atLimit ? null : () => ctrl.toggleCategory(cat.id),
            );
          }).toList(),
        ),
        if (error == 'category') ...[
          const SizedBox(height: KaziSpacing.xs),
          Text(
            l.onboardingCategoryError,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: KaziColors.error,
            ),
          ),
        ],
        const SizedBox(height: KaziSpacing.xl),
        Text(
          l.onboardingBaseCommuneLabel,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        GestureDetector(
          onTap: () => _showCommunePicker(context, ctrl, allCommunes, l),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.lg,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: error == 'commune'
                    ? KaziColors.error
                    : KaziColors.border,
              ),
              borderRadius: BorderRadius.circular(KaziRadius.input),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    baseCommuneName ?? l.onboardingBaseCommuneHint,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      color: baseCommuneName != null
                          ? KaziColors.ink
                          : KaziColors.muted,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronDown,
                  color: KaziColors.muted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (error == 'commune') ...[
          const SizedBox(height: KaziSpacing.xs),
          Text(
            l.onboardingCommuneError,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: KaziColors.error,
            ),
          ),
        ],
        const SizedBox(height: KaziSpacing.xl),
        Text(
          l.onboardingCommunesLabel,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.sm),
        Wrap(
          spacing: KaziSpacing.sm,
          runSpacing: KaziSpacing.sm,
          children: allCommunes.map((commune) {
            final isSelected = ctrl.communes.contains(commune.id);
            final isBase = commune.id == ctrl.baseCommune;
            final atLimit = ctrl.communes.length >= 10 && !isSelected;
            return KaziChip(
              label: commune.name,
              isSelected: isSelected,
              onTap: (isBase || atLimit && !isSelected)
                  ? null
                  : () => ctrl.toggleCommune(commune.id),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCommunePicker(
    BuildContext context,
    OnboardingController ctrl,
    List<Commune> communes,
    AppLocalizations l,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KaziColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KaziRadius.sheet),
        ),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KaziSpacing.lg,
                KaziSpacing.lg,
                KaziSpacing.lg,
                KaziSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.onboardingBaseCommuneLabel,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: KaziColors.ink,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx),
                    child: const Icon(LucideIcons.x, color: KaziColors.muted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: KaziColors.border),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: communes.length,
                itemBuilder: (_, i) {
                  final commune = communes[i];
                  final isBase = ctrl.baseCommune == commune.id;
                  return ListTile(
                    title: Text(
                      commune.name,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: isBase ? FontWeight.w600 : FontWeight.w400,
                        color: isBase ? KaziColors.primary : KaziColors.ink,
                      ),
                    ),
                    trailing: isBase
                        ? const Icon(
                            LucideIcons.check,
                            color: KaziColors.primary,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      ctrl.setBaseCommune(commune.id);
                      Navigator.pop(sheetCtx);
                    },
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

// ── Step 3: Review ────────────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  const _Step3({required this.ctrl});
  final OnboardingController ctrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final catalog = context.watch<CatalogController>();
    final allCommunes = catalog.cities.expand((c) => c.communes).toList();

    final categoryNames = ctrl.categoryIds
        .map((id) => catalog.categoryById(id))
        .whereType<Category>()
        .map((c) => locale.startsWith('fr') ? c.name.fr : c.name.en)
        .join(', ');

    final baseCommuneName = ctrl.baseCommune != null
        ? allCommunes
              .where((c) => c.id == ctrl.baseCommune)
              .map((c) => c.name)
              .firstOrNull
        : null;

    final communeNames = ctrl.communes
        .map(
          (id) => allCommunes
              .where((c) => c.id == id)
              .map((c) => c.name)
              .firstOrNull,
        )
        .whereType<String>()
        .join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KaziSpacing.screenPadding,
        KaziSpacing.md,
        KaziSpacing.screenPadding,
        KaziSpacing.xxxl,
      ),
      children: [
        Text(
          l.onboardingReviewTitle,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xl),
        _ReviewRow(
          label: l.onboardingNameLabel,
          value: ctrl.displayName.trim(),
        ),
        if (ctrl.bio.trim().isNotEmpty) ...[
          const SizedBox(height: KaziSpacing.md),
          _ReviewRow(label: l.onboardingBioLabel, value: ctrl.bio.trim()),
        ],
        const SizedBox(height: KaziSpacing.md),
        _ReviewRow(label: l.onboardingCategoriesLabel, value: categoryNames),
        const SizedBox(height: KaziSpacing.md),
        _ReviewRow(
          label: l.onboardingBaseCommuneLabel,
          value: baseCommuneName ?? '',
        ),
        if (ctrl.communes.length > 1) ...[
          const SizedBox(height: KaziSpacing.md),
          _ReviewRow(label: l.onboardingCommunesLabel, value: communeNames),
        ],
        const SizedBox(height: KaziSpacing.md),
        _ReviewRow(
          label: l.onboardingWhatsAppLabel,
          value: ctrl.whatsappNumber.trim(),
        ),
        if (ctrl.callNumber.trim().isNotEmpty) ...[
          const SizedBox(height: KaziSpacing.md),
          _ReviewRow(
            label: l.onboardingPhoneLabel,
            value: ctrl.callNumber.trim(),
          ),
        ],
        const SizedBox(height: KaziSpacing.md),
        _ReviewRow(
          label: l.onboardingYearsLabel,
          value: '${ctrl.yearsExperience}',
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: KaziColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.sm),
        const Divider(height: 1, color: KaziColors.border),
      ],
    );
  }
}

// ── Photo pickers ─────────────────────────────────────────────────────────────

class _PhotoPickers extends StatelessWidget {
  const _PhotoPickers({required this.ctrl});
  final OnboardingController ctrl;

  static final _picker = ImagePicker();

  Future<void> _pickAvatar(BuildContext context) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) return;
    ctrl.pickAvatar(file);
  }

  Future<void> _pickCover(BuildContext context) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) return;
    ctrl.pickCover(file);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        _AvatarPicker(
          label: l.onboardingAvatarLabel,
          photoUrl: ctrl.photoUrl,
          localFile: ctrl.avatarFile,
          progress: ctrl.avatarUploadProgress,
          onTap: () => _pickAvatar(context),
        ),
        const SizedBox(width: KaziSpacing.lg),
        Expanded(
          child: _CoverPicker(
            label: l.onboardingCoverLabel,
            coverUrl: ctrl.coverUrl,
            localFile: ctrl.coverFile,
            progress: ctrl.coverUploadProgress,
            onTap: () => _pickCover(context),
          ),
        ),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.label,
    required this.onTap,
    this.photoUrl,
    this.localFile,
    this.progress,
  });

  final String label;
  final String? photoUrl;
  final XFile? localFile;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget? imageChild;
    if (localFile != null) {
      imageChild = Image.file(File(localFile!.path), fit: BoxFit.cover);
    } else if (photoUrl != null) {
      imageChild = CachedNetworkImage(imageUrl: photoUrl!, fit: BoxFit.cover);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: progress == null ? onTap : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KaziColors.surfaceAlt,
                  border: Border.all(color: KaziColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    imageChild ??
                    const Icon(
                      LucideIcons.camera,
                      color: KaziColors.muted,
                      size: 24,
                    ),
              ),
              if (progress != null)
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    color: KaziColors.primary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: KaziColors.muted,
          ),
        ),
      ],
    );
  }
}

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.label,
    required this.onTap,
    this.coverUrl,
    this.localFile,
    this.progress,
  });

  final String label;
  final String? coverUrl;
  final XFile? localFile;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget? imageChild;
    if (localFile != null) {
      imageChild = Image.file(
        File(localFile!.path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (coverUrl != null) {
      imageChild = CachedNetworkImage(
        imageUrl: coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: progress == null ? onTap : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: KaziColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(KaziRadius.card),
                  border: Border.all(color: KaziColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    imageChild ??
                    const Center(
                      child: Icon(
                        LucideIcons.image,
                        color: KaziColors.muted,
                        size: 24,
                      ),
                    ),
              ),
              if (progress != null)
                LinearProgressIndicator(
                  value: progress,
                  color: KaziColors.primary,
                ),
            ],
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: KaziColors.muted,
          ),
        ),
      ],
    );
  }
}
