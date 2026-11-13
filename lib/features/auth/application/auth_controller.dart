import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';

enum AuthStep { idle, sendingOtp, otpSent, confirmingOtp, done, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  AuthStep _step = AuthStep.idle;
  PhoneVerification? _verification;
  String? _errorKey;
  String? _phone;
  bool _isNewUser = false; // reassigned in confirmOtp

  AuthStep get step => _step;
  PhoneVerification? get verification => _verification;
  String? get errorKey => _errorKey;
  String? get phone => _phone;
  bool get isNewUser => _isNewUser;

  Future<void> sendOtp(String e164Phone, {int? resendToken}) async {
    _step = AuthStep.sendingOtp;
    _errorKey = null;
    _phone = e164Phone;
    notifyListeners();

    try {
      _verification = await _repo.sendOtp(e164Phone, resendToken: resendToken);
      _step = AuthStep.otpSent;
    } catch (e) {
      _step = AuthStep.error;
      _errorKey = _mapError(e);
    }
    notifyListeners();
  }

  Future<void> confirmOtp(String smsCode) async {
    if (_verification == null) return;
    _step = AuthStep.confirmingOtp;
    _errorKey = null;
    notifyListeners();

    try {
      _isNewUser = await _repo.confirmOtp(_verification!, smsCode);
      _step = AuthStep.done;
    } catch (e) {
      _step = AuthStep.error;
      _errorKey = _mapError(e);
    }
    notifyListeners();
  }

  void resetError() {
    if (_step == AuthStep.error) {
      _step = _verification != null ? AuthStep.otpSent : AuthStep.idle;
      _errorKey = null;
      notifyListeners();
    }
  }

  static String _mapError(Object e) {
    final code = e is Exception ? e.toString() : '';
    if (code.contains('invalid-phone-number')) return 'authPhoneInvalid';
    if (code.contains('invalid-verification-code')) return 'errorOtpInvalid';
    if (code.contains('session-expired')) return 'errorOtpExpired';
    if (code.contains('too-many-requests')) return 'errorTooManyRequests';
    if (code.contains('quota-exceeded')) return 'errorQuotaExceeded';
    return 'errorUnknown';
  }
}
