import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/config/app_defaults.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/app_user.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../legal/presentation/legal_notice.dart';
import '../application/session_controller.dart';
import '../domain/user_repository.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _hasError = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().length < 2) {
      return AppLocalizations.of(context).authProfileNameHint;
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final session = context.read<SessionController>();
    final uid = session.uid;
    if (uid == null) return;

    setState(() {
      _saving = true;
      _hasError = false;
    });

    final displayName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    final user = AppUser(
      uid: uid,
      displayName: displayName,
      phone: session.authUser?.phone ?? '',
      email: session.authUser?.email,
      termsVersion: AppDefaults.termsVersion,
    );

    try {
      await context.read<UserRepository>().createUser(user);
      if (mounted) context.go(Routes.home);
    } catch (e) {
      debugPrint('[SetupProfile] save failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authUser = context.watch<SessionController>().authUser;
    final identity = (authUser?.phone?.isNotEmpty ?? false)
        ? PhoneUtils.formatDisplay(authUser!.phone!)
        : (authUser?.email ?? '');

    return Scaffold(
      backgroundColor: KaziColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KaziSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KaziSpacing.xxxl),
                const Center(child: _Avatar()),
                const SizedBox(height: KaziSpacing.xxxl),
                Text(
                  l.authProfileTitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: KaziColors.ink,
                  ),
                ),
                if (identity.isNotEmpty) ...[
                  const SizedBox(height: KaziSpacing.xs),
                  Text(
                    identity,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: KaziColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: KaziSpacing.xxxl),
                KaziTextField(
                  controller: _firstNameController,
                  label: l.profileFirstNameLabel,
                  hint: l.profileFirstNameHint,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _validateRequired,
                ),
                const SizedBox(height: KaziSpacing.lg),
                KaziTextField(
                  controller: _lastNameController,
                  label: l.profileLastNameLabel,
                  hint: l.profileLastNameHint,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  validator: _validateRequired,
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                if (_hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(KaziSpacing.md),
                    decoration: BoxDecoration(
                      color: KaziColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: KaziColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: KaziSpacing.sm),
                        Expanded(
                          child: Text(
                            l.errorSaveFailed,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              color: KaziColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KaziSpacing.lg),
                ],
                const LegalNotice(),
                const SizedBox(height: KaziSpacing.lg),
                KaziButton(
                  label: l.authProfileSave,
                  onPressed: _saving ? null : _save,
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    height: 88,
    decoration: const BoxDecoration(
      gradient: KaziColors.brandGradient,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
  );
}
