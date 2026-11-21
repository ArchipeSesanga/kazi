/// Thin wrapper around the signed-in user for the domain layer.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.phone,
    this.email,
    this.isAdmin = false,
    this.isModerator = false,
  });

  final String uid;

  /// E.164 phone number: the account identity for consumer accounts.
  final String? phone;
  final String? email;

  /// The `admin` custom claim on the ID token.
  final bool isAdmin;

  /// The `moderator` custom claim (moderation actions only).
  final bool isModerator;
}
