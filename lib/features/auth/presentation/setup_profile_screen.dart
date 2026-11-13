import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';

import '../../../core/models/app_user.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/session_controller.dart';
import '../domain/user_repository.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Entrez au moins 2 caractères.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final session = context.read<SessionController>();
    final uid = session.uid;
    if (uid == null) return;

    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

    final user = AppUser(
      uid: uid,
      displayName: _nameController.text.trim(),
      phone: phone,
    );

    try {
      await context.read<UserRepository>().createUser(user);
      if (mounted) context.go(Routes.home);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

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
                const _Avatar(),
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
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: KaziSpacing.xs),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: KaziColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: KaziSpacing.xxxl),
                KaziTextField(
                  controller: _nameController,
                  label: l.authProfileNameLabel,
                  hint: l.authProfileNameHint,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateName,
                ),
                const SizedBox(height: KaziSpacing.xxxl),
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
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          gradient: KaziColors.brandGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
      ),
    );
  }
}
