/// Thin wrapper around Firebase Auth user for the domain layer.
class AuthUser {
  const AuthUser({required this.uid, this.phone});

  final String uid;
  final String? phone;
}
