import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../application/phone_auth_controller.dart';
import 'auth_error_text.dart';

/// One-time code entry with resend timer. On success the session stream
/// signs the user in and the router leaves the auth flow.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() =>
      context.read<PhoneAuthController>().submitCode(_controller.text);

  void _onChanged(String value) {
    final auth = context.read<PhoneAuthController>();
    auth.clearFailure();
    if (value.length == auth.codeLength && !auth.isBusy) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<PhoneAuthController>();
    final verifying = auth.step == PhoneAuthStep.verifying;
    final failure = auth.failure;
    final phone = auth.e164 == null ? '' : PhoneUtils.formatDisplay(auth.e164!);

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
                l.authOtpTitle,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: KaziColors.ink,
                ),
              ),
              const SizedBox(height: KaziSpacing.sm),
              Text(
                l.authOtpSubtitle(phone),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: KaziColors.muted,
                ),
              ),
              const SizedBox(height: KaziSpacing.xxxl),
              KaziTextField(
                controller: _controller,
                label: l.authOtpCodeLabel,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !verifying,
                maxLength: auth.codeLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText:
                    failure == null ? null : authFailureText(l, failure),
                onChanged: _onChanged,
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: KaziSpacing.xl),
              KaziButton(
                label: l.authOtpVerify,
                onPressed: verifying ? null : _verify,
                isLoading: verifying,
              ),
              const SizedBox(height: KaziSpacing.md),
              Center(
                child: TextButton(
                  key: const Key('resend-code'),
                  onPressed: auth.canResend && !auth.isBusy
                      ? () => auth.resend()
                      : null,
                  child: Text(
                    auth.resendSecondsLeft > 0
                        ? l.authOtpResendIn(auth.resendSecondsLeft)
                        : l.authOtpResend,
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: verifying
                      ? null
                      : () {
                          auth.editNumber();
                          Navigator.of(context).pop();
                        },
                  child: Text(l.authOtpChangeNumber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
