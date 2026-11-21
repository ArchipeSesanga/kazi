import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/kazi_button.dart';
import '../../../core/widgets/kazi_text_field.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/user_repository.dart';
import '../../auth/presentation/auth_error_text.dart';
import '../application/delete_account_controller.dart';

/// Delete my account: type the confirmation word, re-confirm with a fresh OTP
/// sent to the account's number, then the server deletes everything.
class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => DeleteAccountController(
        c.read<AuthRepository>(),
        c.read<UserRepository>(),
        phone: c.read<SessionController>().authUser?.phone,
      ),
      child: const _DeleteAccountView(),
    );
  }
}

class _DeleteAccountView extends StatefulWidget {
  const _DeleteAccountView();

  @override
  State<_DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<_DeleteAccountView> {
  final _word = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _word.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.watch<DeleteAccountController>();
    final confirmWord = l.deleteAccountConfirmWord;
    final inCodeStep = c.step == DeleteAccountStep.codeSent ||
        c.step == DeleteAccountStep.deleting;

    String? error;
    if (c.authFailure != null) {
      error = authFailureText(l, c.authFailure!);
    } else if (c.deleteFailure ==
        DeleteAccountFailureReason.recentLoginRequired) {
      error = l.deleteAccountReauthExpired;
    } else if (c.deleteFailure != null) {
      error = l.errorDeleteFailed;
    }

    return Scaffold(
      backgroundColor: KaziColors.surface,
      appBar: AppBar(
        title: Text(
          l.deleteAccountTitle,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: KaziColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KaziSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(KaziSpacing.lg),
              decoration: BoxDecoration(
                color: KaziColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(KaziSpacing.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: KaziColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: KaziSpacing.md),
                  Expanded(
                    child: Text(
                      l.deleteAccountWarning,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: KaziColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KaziSpacing.xl),
            Text(
              l.deleteAccountConsequences,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: KaziColors.body,
              ),
            ),
            const SizedBox(height: KaziSpacing.xxxl),
            if (!c.canReauthenticate)
              Text(
                l.deleteAccountNoPhone,
                key: const Key('delete-no-phone'),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: KaziColors.error,
                ),
              )
            else if (!inCodeStep)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _word,
                builder: (context, value, _) {
                  final typed = value.text.trim() == confirmWord;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KaziTextField(
                        controller: _word,
                        label: l.deleteAccountConfirmLabel,
                        hint: confirmWord,
                        textInputAction: TextInputAction.done,
                      ),
                      if (error != null) _ErrorText(error),
                      const SizedBox(height: KaziSpacing.xxxl),
                      KaziButton(
                        label: l.deleteAccountContinue,
                        onPressed: (typed && !c.isBusy) ? c.sendCode : null,
                        isLoading: c.step == DeleteAccountStep.sendingCode,
                        variant: KaziButtonVariant.danger,
                      ),
                    ],
                  );
                },
              )
            else ...[
              Text(
                l.deleteAccountOtpIntro(PhoneUtils.formatDisplay(c.phone!)),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: KaziColors.body,
                ),
              ),
              const SizedBox(height: KaziSpacing.lg),
              KaziTextField(
                controller: _code,
                label: l.authOtpCodeLabel,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !c.isBusy,
                maxLength: c.codeLength,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {},
              ),
              if (error != null) _ErrorText(error),
              const SizedBox(height: KaziSpacing.xxxl),
              KaziButton(
                label: c.deleteFailure == DeleteAccountFailureReason.failed &&
                        c.hasFreshReauth
                    ? l.deleteAccountRetry
                    : l.deleteAccountButton,
                onPressed: c.isBusy
                    ? null
                    : () => c.deleteFailure ==
                                DeleteAccountFailureReason.failed &&
                            c.hasFreshReauth
                        ? c.retryDelete()
                        : c.submitCode(_code.text),
                isLoading: c.step == DeleteAccountStep.deleting,
                variant: KaziButtonVariant.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: KaziSpacing.sm),
        child: Text(
          text,
          key: const Key('delete-error'),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            color: KaziColors.error,
          ),
        ),
      );
}
