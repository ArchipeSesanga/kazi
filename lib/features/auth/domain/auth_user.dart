/// Thin wrapper around the signed-in user for the domain layer.
class AuthUser {
  const AuthUser({required this.uid, this.phone, this.email});

  final String uid;

  /// E.164 phone number: the account identity for consumer accounts.
  final String? phone;
  final String? email;
}
