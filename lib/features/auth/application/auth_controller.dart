import 'package:flutter/foundation.dart';

import '../domain/auth_repository.dart';

enum AuthStep { idle, signingIn, done, error }

class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;

  AuthStep _step = AuthStep.idle;
  String? _errorKey;
  bool _isNewUser = false;

  AuthStep get step => _step;
  String? get errorKey => _errorKey;
  bool get isNewUser => _isNewUser;

  Future<void> signInWithEmail(String email, String password) async {
    _step = AuthStep.signingIn;
    _errorKey = null;
    notifyListeners();
    try {
      _isNewUser = await _repo.signInWithEmail(email, password);
      _step = AuthStep.done;
    } catch (e) {
      _step = AuthStep.error;
      _errorKey = _mapEmailError(e);
    }
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password) async {
    _step = AuthStep.signingIn;
    _errorKey = null;
    notifyListeners();
    try {
      _isNewUser = await _repo.registerWithEmail(email, password);
      _step = AuthStep.done;
    } catch (e) {
      _step = AuthStep.error;
      _errorKey = _mapEmailError(e);
    }
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _step = AuthStep.signingIn;
    _errorKey = null;
    notifyListeners();
    try {
      await _repo.sendPasswordResetEmail(email);
      _step = AuthStep.idle;
      _errorKey = 'authEmailResetSent';
    } catch (e) {
      _step = AuthStep.error;
      _errorKey = _mapEmailError(e);
    }
    notifyListeners();
  }

  void resetError() {
    if (_step == AuthStep.error) {
      _step = AuthStep.idle;
      _errorKey = null;
      notifyListeners();
    }
  }

  static String _mapEmailError(Object e) {
    final code = e is Exception ? e.toString() : '';
    if (code.contains('email-already-in-use')) return 'authEmailInUse';
    if (code.contains('weak-password')) return 'authWeakPassword';
    if (code.contains('user-not-found')) return 'authUserNotFound';
    if (code.contains('wrong-password') ||
        code.contains('invalid-credential')) {
      return 'authWrongPassword';
    }
    if (code.contains('invalid-email')) return 'authEmailInvalid';
    if (code.contains('too-many-requests')) return 'errorTooManyRequests';
    return 'errorUnknown';
  }
}
