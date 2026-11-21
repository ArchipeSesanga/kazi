import 'package:flutter/foundation.dart';

import '../../auth/domain/auth_repository.dart';
import '../../auth/domain/user_repository.dart';

enum DeleteAccountStep { confirm, sendingCode, codeSent, deleting, done }

/// Deleting an account needs a fresh OTP: the server rejects the call unless
/// the sign-in is at most five minutes old.
class DeleteAccountController extends ChangeNotifier {
  DeleteAccountController(
    this._auth,
    this._users, {
    required this.phone,
    this.codeLength = 6,
    DateTime Function()? clock,
    this.reauthValidity = const Duration(minutes: 4),
  }) : _now = clock ?? DateTime.now;

  final AuthRepository _auth;
  final UserRepository _users;

  /// The signed-in user's verified phone number (E.164), or null.
  final String? phone;
  final int codeLength;

  /// How long a successful re-confirmation is reused for a retry. Kept below
  /// the server's five-minute limit.
  final Duration reauthValidity;
  final DateTime Function() _now;

  DeleteAccountStep _step = DeleteAccountStep.confirm;
  AuthFailureReason? _authFailure;
  DeleteAccountFailureReason? _deleteFailure;
  DateTime? _reauthAt;

  DeleteAccountStep get step => _step;
  AuthFailureReason? get authFailure => _authFailure;
  DeleteAccountFailureReason? get deleteFailure => _deleteFailure;

  /// No verified phone: the account cannot be re-confirmed from the app.
  bool get canReauthenticate => phone != null && phone!.isNotEmpty;
  bool get isBusy =>
      _step == DeleteAccountStep.sendingCode ||
      _step == DeleteAccountStep.deleting;
  bool get hasFreshReauth =>
      _reauthAt != null && _now().difference(_reauthAt!) < reauthValidity;

  /// Sends the code to the user's own number.
  Future<bool> sendCode() async {
    if (isBusy || !canReauthenticate) return false;
    _step = DeleteAccountStep.sendingCode;
    _authFailure = null;
    _deleteFailure = null;
    notifyListeners();
    try {
      await _auth.verifyPhone(phone!);
      _step = DeleteAccountStep.codeSent;
      notifyListeners();
      return true;
    } on AuthFailure catch (f) {
      _authFailure = f.reason;
    } catch (_) {
      _authFailure = AuthFailureReason.unknown;
    }
    _step = DeleteAccountStep.confirm;
    notifyListeners();
    return false;
  }

  /// Re-confirms with [code], then deletes the account.
  Future<bool> submitCode(String code) async {
    if (isBusy) return false;
    final trimmed = code.trim();
    if (trimmed.length != codeLength) {
      _authFailure = AuthFailureReason.invalidCode;
      notifyListeners();
      return false;
    }
    _step = DeleteAccountStep.deleting;
    _authFailure = null;
    _deleteFailure = null;
    notifyListeners();
    try {
      await _auth.confirmCode(trimmed, reauthenticate: true);
      _reauthAt = _now();
    } on AuthFailure catch (f) {
      _authFailure = f.reason;
      _step = DeleteAccountStep.codeSent;
      notifyListeners();
      return false;
    } catch (_) {
      _authFailure = AuthFailureReason.unknown;
      _step = DeleteAccountStep.codeSent;
      notifyListeners();
      return false;
    }
    return _delete();
  }

  /// Runs the deletion again after a failure, without a new code while the
  /// last re-confirmation is still fresh. Otherwise asks for a new code.
  Future<bool> retryDelete() async {
    if (isBusy) return false;
    if (!hasFreshReauth) {
      _deleteFailure = DeleteAccountFailureReason.recentLoginRequired;
      _step = DeleteAccountStep.confirm;
      notifyListeners();
      return false;
    }
    _step = DeleteAccountStep.deleting;
    _deleteFailure = null;
    notifyListeners();
    return _delete();
  }

  Future<bool> _delete() async {
    try {
      await _users.deleteAccount();
      _step = DeleteAccountStep.done;
      notifyListeners();
      return true;
    } on DeleteAccountFailure catch (f) {
      _deleteFailure = f.reason;
      if (f.reason == DeleteAccountFailureReason.recentLoginRequired) {
        _reauthAt = null;
      }
    } catch (_) {
      _deleteFailure = DeleteAccountFailureReason.failed;
    }
    // A failed run leaves the account in "deleting"; retrying is safe.
    _step = _deleteFailure == DeleteAccountFailureReason.recentLoginRequired
        ? DeleteAccountStep.confirm
        : DeleteAccountStep.codeSent;
    notifyListeners();
    return false;
  }
}
