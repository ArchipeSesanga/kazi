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
  }) async {
    late PhoneVerification result;
    Object? caught;

    await _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) => caught = e,
      codeSent: (verificationId, token) {
        result = PhoneVerification(
          verificationId: verificationId,
          resendToken: token,
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    if (caught != null) throw caught!;
    return result;
  }

  @override
  Future<void> confirmOtp(PhoneVerification verification, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verification.verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
