import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/auth_controller.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l.authEmailInvalid;
    final emailRe = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRe.hasMatch(value.trim())) return l.authEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    final l = AppLocalizations.of(context);
    if (value == null || value.length < 6) return l.authWeakPassword;
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final auth = context.read<AuthController>();
    if (_isRegisterMode) {
      await auth.registerWithEmail(email, password);
    } else {
      await auth.signInWithEmail(email, password);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authEmailInvalid),
        ),
      );
      return;
    }
    await context.read<AuthController>().sendPasswordResetEmail(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authEmailResetSent),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();
    final isLoading = auth.step == AuthStep.signingIn;
    final hasError = auth.step == AuthStep.error && auth.errorKey != null;

    return Scaffold(
      appBar: AppBar(backgroundColor: KaziColors.surface, elevation: 0),
      backgroundColor: KaziColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KaziSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KaziSpacing.lg),
                Text(
                  l.authEmailTitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: KaziColors.ink,
                  ),
                ),
                const SizedBox(height: KaziSpacing.sm),
                Text(
                  l.authEmailSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.muted,
                  ),
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                KaziTextField(
                  controller: _emailController,
                  label: l.authEmailLabel,
                  hint: l.authEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: KaziSpacing.lg),
                KaziTextField(
                  controller: _passwordController,
                  label: l.authPasswordLabel,
                  hint: l.authPasswordHint,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: KaziColors.muted,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: KaziSpacing.sm),
                  Text(
                    _localizeError(l, auth.errorKey!),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: KaziColors.error,
                    ),
                  ),
                ],
                if (!_isRegisterMode) ...[
                  const SizedBox(height: KaziSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: Text(
                        l.authEmailForgotPassword,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: KaziColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: KaziSpacing.xl),
                KaziButton(
                  label: _isRegisterMode ? l.authEmailRegister : l.authEmailSignIn,
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: KaziSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRegisterMode
                          ? l.authEmailHasAccountPrompt
                          : l.authEmailCreateAccountPrompt,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: KaziColors.muted,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _isRegisterMode = !_isRegisterMode);
                        context.read<AuthController>().resetError();
                      },
                      child: Text(
                        _isRegisterMode ? l.authEmailSignIn : l.authEmailRegister,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KaziColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KaziSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(Routes.authPhone),
                    child: Text(
                      l.authEmailUsePhone,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: KaziColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _localizeError(AppLocalizations l, String key) {
    return switch (key) {
      'authEmailInUse' => l.authEmailInUse,
      'authWeakPassword' => l.authWeakPassword,
      'authUserNotFound' => l.authUserNotFound,
      'authWrongPassword' => l.authWrongPassword,
      'authEmailInvalid' => l.authEmailInvalid,
      'errorTooManyRequests' => l.errorTooManyRequests,
      _ => l.errorUnknown,
    };
  }
}
