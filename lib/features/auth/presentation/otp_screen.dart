import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../application/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _codeLength = 6;
  static const _resendSeconds = 60;

  final _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  Timer? _resendTimer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = _resendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code =>
      _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < _codeLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = digits.length < _codeLength ? digits.length : _codeLength - 1;
      _focusNodes[next].requestFocus();
      if (_code.length == _codeLength) _submit();
      return;
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_code.length == _codeLength) _submit();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submit() async {
    if (_code.length < _codeLength) return;
    await context.read<AuthController>().confirmOtp(_code);
    if (mounted) {
      final auth = context.read<AuthController>();
      if (auth.step == AuthStep.done) {
        context.go(auth.isNewUser ? Routes.authSetupProfile : Routes.home);
      }
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthController>();
    if (auth.phone == null) return;
    await auth.sendOtp(
      auth.phone!,
      resendToken: auth.verification?.resendToken,
    );
    if (mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();
    final phone = auth.phone ?? '';
    final isLoading = auth.step == AuthStep.confirmingOtp;
    final canResend = _secondsLeft == 0 && auth.step != AuthStep.sendingOtp;

    return Scaffold(
      appBar: AppBar(backgroundColor: KaziColors.surface, elevation: 0),
      backgroundColor: KaziColors.surface,
      body: SafeArea(
        child: Padding(
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
              _OtpInputRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onChanged: _onDigitChanged,
                onBackspace: _onBackspace,
              ),
              if (auth.step == AuthStep.error && auth.errorKey != null) ...[
                const SizedBox(height: KaziSpacing.md),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      l.authOtpChangeNumber,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: KaziColors.muted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: canResend ? _resend : null,
                    child: Text(
                      _secondsLeft > 0
                          ? l.authOtpResendIn(_secondsLeft)
                          : l.authOtpResend,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: canResend ? KaziColors.primary : KaziColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              KaziButton(
                label: l.buttonConfirm,
                onPressed: isLoading || _code.length < _codeLength ? null : _submit,
                isLoading: isLoading,
              ),
              const SizedBox(height: KaziSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  String _localizeError(AppLocalizations l, String key) {
    return switch (key) {
      'errorOtpInvalid' => l.errorOtpInvalid,
      'errorOtpExpired' => l.errorOtpExpired,
      'errorTooManyRequests' => l.errorTooManyRequests,
      _ => l.errorUnknown,
    };
  }
}

// ---------------------------------------------------------------------------

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onBackspace,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onBackspace;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        controllers.length,
        (i) => _OtpCell(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) => onChanged(i, v),
          onBackspace: () => onBackspace(i),
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: KaziColors.ink,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KaziRadius.input),
              borderSide: const BorderSide(color: KaziColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KaziRadius.input),
              borderSide: const BorderSide(color: KaziColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
