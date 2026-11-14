import 'auth_user.dart';

export 'auth_user.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  /// Returns true if this is a new user.
  Future<bool> signInWithEmail(String email, String password);

  /// Creates a new account; always returns true.
  Future<bool> registerWithEmail(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
