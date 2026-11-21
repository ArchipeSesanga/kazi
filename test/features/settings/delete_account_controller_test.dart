import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/features/auth/domain/auth_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/settings/application/delete_account_controller.dart';

import '../auth/fake_auth_repository.dart';

class _Users implements UserRepository {
  final failures = <DeleteAccountFailureReason?>[];
  int deleteCalls = 0;

  @override
  Future<void> deleteAccount() async {
    deleteCalls++;
    if (failures.isNotEmpty) {
      final next = failures.removeAt(0);
      if (next != null) throw DeleteAccountFailure(next);
    }
  }

  @override
  Stream<AppUser?> watchUser(String uid) => const Stream.empty();
  @override
  Future<void> createUser(AppUser user) async {}
  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {}
  @override
  Future<void> registerDevice(String uid, String fcmToken) async {}
}

void main() {
  const phone = FakeAuthRepository.testPhone;
  late FakeAuthRepository auth;
  late _Users users;
  var now = DateTime(2026, 11, 21, 12);

  DeleteAccountController make({String? number = phone}) =>
      DeleteAccountController(auth, users, phone: number, clock: () => now);

  setUp(() {
    auth = FakeAuthRepository(signedIn: const AuthUser(uid: 'u1', phone: phone));
    users = _Users();
    now = DateTime(2026, 11, 21, 12);
  });

  test('the code goes to the account’s own number', () async {
    final c = make();
    expect(await c.sendCode(), isTrue);
    expect(auth.sent, [phone]);
    expect(c.step, DeleteAccountStep.codeSent);
    expect(users.deleteCalls, 0);
  });

  test('an account without a verified phone cannot be re-confirmed', () async {
    for (final number in [null, '']) {
      final c = make(number: number);
      expect(c.canReauthenticate, isFalse);
      expect(await c.sendCode(), isFalse);
      expect(auth.sent, isEmpty);
    }
  });

  test('a send failure stays on the first step with the reason', () async {
    auth.verifyFailure = AuthFailureReason.tooManyRequests;
    final c = make();
    expect(await c.sendCode(), isFalse);
    expect(c.step, DeleteAccountStep.confirm);
    expect(c.authFailure, AuthFailureReason.tooManyRequests);
  });

  group('re-confirmation before deleting', () {
    late DeleteAccountController c;
    setUp(() async {
      c = make();
      await c.sendCode();
    });

    test('a wrong code never reaches the delete call', () async {
      expect(await c.submitCode('000000'), isFalse);
      expect(c.authFailure, AuthFailureReason.invalidCode);
      expect(c.step, DeleteAccountStep.codeSent);
      expect(users.deleteCalls, 0);
      expect(auth.reauthenticated, 0);
    });

    test('a short code is rejected locally', () async {
      expect(await c.submitCode('12'), isFalse);
      expect(c.authFailure, AuthFailureReason.invalidCode);
      expect(users.deleteCalls, 0);
    });

    test('expired or throttled codes are surfaced', () async {
      auth.confirmFailure = AuthFailureReason.codeExpired;
      await c.submitCode(FakeAuthRepository.testCode);
      expect(c.authFailure, AuthFailureReason.codeExpired);
      expect(users.deleteCalls, 0);
    });

    test('the right code re-confirms the current user, then deletes', () async {
      expect(await c.submitCode(FakeAuthRepository.testCode), isTrue);
      expect(auth.reauthenticated, 1);
      expect(users.deleteCalls, 1);
      expect(c.step, DeleteAccountStep.done);
    });
  });

  group('deletion failures', () {
    late DeleteAccountController c;
    setUp(() async {
      c = make();
      await c.sendCode();
    });

    test('a failed run can be retried without a new code while fresh', () async {
      users.failures.add(DeleteAccountFailureReason.failed);
      expect(await c.submitCode(FakeAuthRepository.testCode), isFalse);
      expect(c.deleteFailure, DeleteAccountFailureReason.failed);
      expect(c.step, DeleteAccountStep.codeSent);
      expect(c.hasFreshReauth, isTrue);

      expect(await c.retryDelete(), isTrue);
      expect(auth.reauthenticated, 1); // no second OTP
      expect(users.deleteCalls, 2);
      expect(c.step, DeleteAccountStep.done);
    });

    test('after the validity window a retry asks for a new code', () async {
      users.failures.add(DeleteAccountFailureReason.failed);
      await c.submitCode(FakeAuthRepository.testCode);
      now = now.add(const Duration(minutes: 5));
      expect(c.hasFreshReauth, isFalse);

      expect(await c.retryDelete(), isFalse);
      expect(users.deleteCalls, 1); // the server is not called with a stale login
      expect(c.deleteFailure, DeleteAccountFailureReason.recentLoginRequired);
      expect(c.step, DeleteAccountStep.confirm);
    });

    test('the server’s recent-login error drops back to a new code', () async {
      users.failures.add(DeleteAccountFailureReason.recentLoginRequired);
      expect(await c.submitCode(FakeAuthRepository.testCode), isFalse);
      expect(c.step, DeleteAccountStep.confirm);
      expect(c.hasFreshReauth, isFalse);
    });

    test('an unexpected error is reported as a plain failure', () async {
      users.failures.add(DeleteAccountFailureReason.notVerified);
      await c.submitCode(FakeAuthRepository.testCode);
      expect(c.deleteFailure, DeleteAccountFailureReason.notVerified);
      expect(c.step, DeleteAccountStep.codeSent);
    });
  });
}
