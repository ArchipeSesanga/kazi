import 'auth_user.dart';

export 'auth_user.dart';

enum AuthFailureReason {
  invalidPhone,
  invalidCode,
  codeExpired,
  tooManyRequests,
  quotaExceeded,
  network,
  unknown,
}

/// Provider-agnostic sign-in failure. Implementations map their own error
/// codes to a [reason] so controllers and screens never parse provider strings.
class AuthFailure implements Exception {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;

  @override
  String toString() => 'AuthFailure($reason)';
}

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  /// Starts phone verification for [e164] and sends a one-time code.
  ///
  /// Completes once the code has been sent. Set [resend] to request a new
  /// code for the same number. On some devices the provider verifies
  /// automatically; the user then appears on [authStateChanges] without
  /// [confirmCode] being called. Throws [AuthFailure].
  Future<void> verifyPhone(String e164, {bool resend = false});

  /// Confirms the code for the number passed to [verifyPhone] and signs in.
  ///
  /// With [reauthenticate] the code re-confirms the *current* user instead of
  /// signing in (used before deleting the account), which refreshes the
  /// sign-in time that sensitive callables check. Throws [AuthFailure].
  Future<void> confirmCode(String code, {bool reauthenticate = false});

  Future<void> signOut();
}
