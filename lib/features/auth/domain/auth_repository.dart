import 'auth_user.dart';
import 'phone_verification.dart';

export 'auth_user.dart';
export 'phone_verification.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  Future<PhoneVerification> sendOtp(String e164Phone, {int? resendToken});
  /// Returns true if this is the user's first sign-in.
  Future<bool> confirmOtp(PhoneVerification verification, String smsCode);
  /// Returns true if this is a new user.
  Future<bool> signInWithEmail(String email, String password);
  /// Creates a new account; always returns true.
  Future<bool> registerWithEmail(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
