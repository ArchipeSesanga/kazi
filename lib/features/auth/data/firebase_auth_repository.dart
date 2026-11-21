import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_repository.dart';

/// Phone OTP through Firebase SMS. A different provider (for example a
/// WhatsApp OTP service) can replace this class without touching callers.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  String? _verificationId;
  int? _resendToken;
  String? _pendingPhone;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(
      (user) => user == null
          ? null
          : AuthUser(
              uid: user.uid,
              phone: user.phoneNumber,
              email: user.email,
            ),
    );
  }

  @override
  Future<void> verifyPhone(String e164, {bool resend = false}) {
    final done = Completer<void>();
    if (!resend || _pendingPhone != e164) _resendToken = null;
    _pendingPhone = e164;
    _verificationId = null;

    unawaited(
      _auth.verifyPhoneNumber(
        phoneNumber: e164,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (credential) async {
          // Instant verification / SMS auto-retrieval (Android).
          try {
            await _auth.signInWithCredential(credential);
          } on FirebaseAuthException catch (_) {
            // The user can still type the code.
          }
          if (!done.isCompleted) done.complete();
        },
        verificationFailed: (e) {
          if (!done.isCompleted) done.completeError(AuthFailure(_reason(e)));
        },
        codeSent: (id, token) {
          _verificationId = id;
          _resendToken = token;
          if (!done.isCompleted) done.complete();
        },
        codeAutoRetrievalTimeout: (id) => _verificationId = id,
      ).catchError((Object e) {
        if (!done.isCompleted) {
          done.completeError(
            AuthFailure(e is FirebaseAuthException
                ? _reason(e)
                : AuthFailureReason.unknown),
          );
        }
      }),
    );
    return done.future;
  }

  @override
  Future<void> confirmCode(String code) async {
    final id = _verificationId;
    if (id == null) throw const AuthFailure(AuthFailureReason.codeExpired);
    try {
      await _auth.signInWithCredential(
        PhoneAuthProvider.credential(verificationId: id, smsCode: code),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_reason(e));
    }
  }

  static AuthFailureReason _reason(FirebaseAuthException e) =>
      switch (e.code) {
        'invalid-phone-number' => AuthFailureReason.invalidPhone,
        'invalid-verification-code' => AuthFailureReason.invalidCode,
        'session-expired' ||
        'code-expired' ||
        'invalid-verification-id' =>
          AuthFailureReason.codeExpired,
        'too-many-requests' => AuthFailureReason.tooManyRequests,
        'quota-exceeded' => AuthFailureReason.quotaExceeded,
        'network-request-failed' => AuthFailureReason.network,
        _ => AuthFailureReason.unknown,
      };

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.additionalUserInfo?.isNewUser ?? false;
  }

  @override
  Future<bool> registerWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.additionalUserInfo?.isNewUser ?? true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() => _auth.signOut();
}
