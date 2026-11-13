import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(
          (user) =>
              user == null ? null : AuthUser(uid: user.uid, phone: user.phoneNumber),
        );
  }

  @override
  Future<PhoneVerification> sendOtp(
    String e164Phone, {
    int? resendToken,
  }) {
    // verifyPhoneNumber returns immediately; codeSent fires later (after reCAPTCHA).
    // Use a Completer so callers can await the actual callback.
    final completer = Completer<PhoneVerification>();

    _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, token) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerification(verificationId: verificationId, resendToken: token),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future<bool> confirmOtp(PhoneVerification verification, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verification.verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.additionalUserInfo?.isNewUser ?? false;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
