/// Holds the in-flight OTP state between sendOtp and confirmOtp.
class PhoneVerification {
  const PhoneVerification({
    required this.verificationId,
    this.resendToken,
  });

  final String verificationId;
  final int? resendToken;
}
