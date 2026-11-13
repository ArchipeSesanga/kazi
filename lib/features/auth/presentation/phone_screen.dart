import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/auth_controller.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  String _countryCode = '+243';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).authPhoneInvalid;
    }
    try {
      final e164 = '$_countryCode${value.replaceAll(RegExp(r'\s+'), '')}';
      final phone = PhoneNumber.fromRaw(e164);
      if (!phone.validate()) return AppLocalizations.of(context).authPhoneInvalid;
      return null;
    } catch (_) {
      return AppLocalizations.of(context).authPhoneInvalid;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).authPhoneTermsError)),
      );
      return;
    }
    final raw = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    final e164 = '$_countryCode$raw';
    await context.read<AuthController>().sendOtp(e164);

    if (mounted) {
      final step = context.read<AuthController>().step;
      if (step == AuthStep.otpSent) {
        unawaited(context.push(Routes.authOtp));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();
    final isLoading = auth.step == AuthStep.sendingOtp;

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
                  l.authPhoneTitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: KaziColors.ink,
                  ),
                ),
                const SizedBox(height: KaziSpacing.sm),
                Text(
                  l.authPhoneSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    color: KaziColors.muted,
                  ),
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                _CountryCodeSelector(
                  selected: _countryCode,
                  onChanged: (code) => setState(() => _countryCode = code),
                ),
                const SizedBox(height: KaziSpacing.sm),
                KaziTextField(
                  controller: _phoneController,
                  label: l.authPhoneLabel,
                  hint: l.authPhoneHint,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                if (auth.step == AuthStep.error && auth.errorKey != null) ...[
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
                const SizedBox(height: KaziSpacing.xl),
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                      activeColor: KaziColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: KaziColors.muted,
                            ),
                            children: [
                              TextSpan(text: l.authPhoneTermsPrefix),
                              TextSpan(
                                text: l.authPhoneTermsLink,
                                style: const TextStyle(
                                  color: KaziColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: l.authPhoneTermsAnd),
                              TextSpan(
                                text: l.authPhonePrivacyLink,
                                style: const TextStyle(
                                  color: KaziColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KaziSpacing.xxxl),
                KaziButton(
                  label: l.authPhoneSend,
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
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
      'authPhoneInvalid' => l.authPhoneInvalid,
      'errorTooManyRequests' => l.errorTooManyRequests,
      'errorQuotaExceeded' => l.errorQuotaExceeded,
      _ => l.errorUnknown,
    };
  }
}

// ---------------------------------------------------------------------------

class _CountryCodeSelector extends StatelessWidget {
  const _CountryCodeSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('+243', 'CD', '🇨🇩 +243'),
    ('+242', 'CG', '🇨🇬 +242'),
    ('+237', 'CM', '🇨🇲 +237'),
    ('+33', 'FR', '🇫🇷 +33'),
    ('+1', 'US', '🇺🇸 +1'),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: 'Pays',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KaziRadius.input),
          borderSide: const BorderSide(color: KaziColors.border),
        ),
        filled: true,
        fillColor: KaziColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KaziSpacing.lg,
          vertical: KaziSpacing.md,
        ),
      ),
      items: _options
          .map(
            (o) => DropdownMenuItem(
              value: o.$1,
              child: Text(
                o.$3,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
