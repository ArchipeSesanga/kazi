import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/config/env.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/phone_auth_controller.dart';
import 'auth_error_text.dart';

/// Phone number entry: the real sign-in path (default country +243).
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key, this.emailAuthEnabled});

  /// Overrides [Env.emailAuthEnabled] (tests).
  final bool? emailAuthEnabled;

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();

  bool get _showEmail => widget.emailAuthEnabled ?? Env.emailAuthEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PhoneAuthController>().reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<PhoneAuthController>();
    final sent = await auth.submitPhone(_controller.text);
    if (sent && mounted) await context.push(Routes.authOtp);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<PhoneAuthController>();
    final sending = auth.step == PhoneAuthStep.sendingCode;
    final failure = auth.failure;

    return Scaffold(
      backgroundColor: KaziColors.surface,
      appBar: AppBar(backgroundColor: KaziColors.surface, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KaziSpacing.screenPadding),
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
              KaziTextField(
                controller: _controller,
                label: l.authPhoneLabel,
                hint: l.authPhoneHint,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofocus: true,
                enabled: !sending,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                ],
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: KaziSpacing.md),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      '+243',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        color: KaziColors.ink,
                      ),
                    ),
                  ),
                ),
                errorText:
                    failure == null ? null : authFailureText(l, failure),
                onChanged: (_) => auth.clearFailure(),
                onSubmitted: (_) => sending ? null : _submit(),
              ),
              const SizedBox(height: KaziSpacing.xl),
              KaziButton(
                label: l.authPhoneContinue,
                onPressed: sending ? null : _submit,
                isLoading: sending,
              ),
              if (_showEmail) ...[
                const SizedBox(height: KaziSpacing.lg),
                Center(
                  child: TextButton(
                    key: const Key('use-email-sign-in'),
                    onPressed: () => context.push(Routes.authEmail),
                    child: Text(l.authPhoneUseEmail),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
