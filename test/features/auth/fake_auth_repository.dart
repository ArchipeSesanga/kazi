import 'dart:async';

import 'package:kazi/features/auth/domain/auth_repository.dart';

/// Mimics Firebase test phone numbers: no real SMS is ever sent.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.signedIn});

  /// Firebase "test phone number" and its fixed code.
  static const testPhone = '+243810000001';
  static const testCode = '123456';

  AuthUser? signedIn;
  final _controller = StreamController<AuthUser?>.broadcast();

  AuthFailureReason? verifyFailure;
  AuthFailureReason? confirmFailure;
  final sent = <String>[];
  int resends = 0;
  int reauthenticated = 0;
  String? _pending;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield signedIn;
    yield* _controller.stream;
  }

  @override
  Future<void> verifyPhone(String e164, {bool resend = false}) async {
    if (verifyFailure != null) throw AuthFailure(verifyFailure!);
    if (resend) resends++;
    sent.add(e164);
    _pending = e164;
  }

  @override
  Future<void> confirmCode(String code, {bool reauthenticate = false}) async {
    if (confirmFailure != null) throw AuthFailure(confirmFailure!);
    if (_pending == null) throw const AuthFailure(AuthFailureReason.codeExpired);
    if (code != testCode) throw const AuthFailure(AuthFailureReason.invalidCode);
    if (reauthenticate) {
      reauthenticated++;
      return;
    }
    signedIn = AuthUser(uid: 'u1', phone: _pending);
    _controller.add(signedIn);
  }

  @override
  Future<bool> signInWithEmail(String email, String password) async => false;

  @override
  Future<bool> registerWithEmail(String email, String password) async => true;

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    signedIn = null;
    _controller.add(null);
  }
}
