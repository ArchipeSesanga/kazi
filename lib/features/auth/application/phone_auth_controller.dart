import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/phone.dart';
import '../domain/auth_repository.dart';

enum PhoneAuthStep { phone, sendingCode, codeSent, verifying }

/// Drives the phone entry and OTP screens.
class PhoneAuthController extends ChangeNotifier {
  PhoneAuthController(
    this._repo, {
    this.resendCooldown = const Duration(seconds: 60),
    this.codeLength = 6,
  });

  final AuthRepository _repo;
  final Duration resendCooldown;
  final int codeLength;

  PhoneAuthStep _step = PhoneAuthStep.phone;
  String? _e164;
  AuthFailureReason? _failure;
  int _resendSecondsLeft = 0;
  Timer? _timer;
  bool _disposed = false;

  PhoneAuthStep get step => _step;

  /// The number the code was sent to, as E.164.
  String? get e164 => _e164;
  AuthFailureReason? get failure => _failure;
  int get resendSecondsLeft => _resendSecondsLeft;
  bool get canResend =>
      _step == PhoneAuthStep.codeSent && _resendSecondsLeft == 0;
  bool get isBusy =>
      _step == PhoneAuthStep.sendingCode || _step == PhoneAuthStep.verifying;

  /// Clears any previous attempt; call when the phone screen opens.
  void reset() {
    _timer?.cancel();
    _step = PhoneAuthStep.phone;
    _e164 = null;
    _failure = null;
    _resendSecondsLeft = 0;
    _notify();
  }

  /// Back from the OTP screen to change the number.
  void editNumber() => reset();

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    _notify();
  }

  /// Validates [national] (national or international format, default +243)
  /// and requests a code. Returns true when the code was sent.
  Future<bool> submitPhone(String national) async {
    if (isBusy) return false;
    final input = national.trim();
    final compact = input.replaceAll(RegExp(r'[\s.\-()]'), '');
    final e164 = compact.startsWith('+')
        ? (PhoneUtils.isValidE164(compact) ? compact : null)
        : PhoneUtils.toE164(compact);
    if (e164 == null) {
      _failure = AuthFailureReason.invalidPhone;
      _notify();
      return false;
    }
    return _send(e164, resend: false);
  }

  Future<bool> resend() async {
    final e164 = _e164;
    if (e164 == null || !canResend) return false;
    return _send(e164, resend: true);
  }

  Future<bool> _send(String e164, {required bool resend}) async {
    final previous = _step;
    _step = PhoneAuthStep.sendingCode;
    _failure = null;
    _notify();
    try {
      await _repo.verifyPhone(e164, resend: resend);
      _e164 = e164;
      _step = PhoneAuthStep.codeSent;
      _failure = null;
      _startCooldown();
      _notify();
      return true;
    } on AuthFailure catch (f) {
      _step = previous == PhoneAuthStep.codeSent
          ? PhoneAuthStep.codeSent
          : PhoneAuthStep.phone;
      _failure = f.reason;
    } catch (_) {
      _step = previous == PhoneAuthStep.codeSent
          ? PhoneAuthStep.codeSent
          : PhoneAuthStep.phone;
      _failure = AuthFailureReason.unknown;
    }
    _notify();
    return false;
  }

  /// Confirms [code]. On success the session stream emits the signed-in user
  /// and the router leaves the auth flow.
  Future<bool> submitCode(String code) async {
    if (isBusy) return false;
    final trimmed = code.trim();
    if (trimmed.length != codeLength) {
      _failure = AuthFailureReason.invalidCode;
      _notify();
      return false;
    }
    _step = PhoneAuthStep.verifying;
    _failure = null;
    _notify();
    try {
      await _repo.confirmCode(trimmed);
      _step = PhoneAuthStep.codeSent;
      _notify();
      return true;
    } on AuthFailure catch (f) {
      _failure = f.reason;
    } catch (_) {
      _failure = AuthFailureReason.unknown;
    }
    _step = PhoneAuthStep.codeSent;
    _notify();
    return false;
  }

  void _startCooldown() {
    _timer?.cancel();
    _resendSecondsLeft = resendCooldown.inSeconds;
    if (_resendSecondsLeft == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _resendSecondsLeft--;
      if (_resendSecondsLeft <= 0) {
        _resendSecondsLeft = 0;
        t.cancel();
      }
      _notify();
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
