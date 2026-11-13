import 'auth_user.dart';
import 'phone_verification.dart';

export 'auth_user.dart';
export 'phone_verification.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  Future<PhoneVerification> sendOtp(String e164Phone, {int? resendToken});
  Future<void> confirmOtp(PhoneVerification verification, String smsCode);
  Future<void> signOut();
}
