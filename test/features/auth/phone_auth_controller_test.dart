import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/application/phone_auth_controller.dart';
import 'package:kazi/features/auth/domain/auth_repository.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repo;
  late PhoneAuthController c;

  setUp(() {
    repo = FakeAuthRepository();
    c = PhoneAuthController(repo, resendCooldown: const Duration(seconds: 30));
  });
  tearDown(() => c.dispose());

  test('national number is normalised to E.164 with +243', () async {
    expect(await c.submitPhone('81 000 0001'), isTrue);
    expect(repo.sent, [FakeAuthRepository.testPhone]);
    expect(c.step, PhoneAuthStep.codeSent);
    expect(c.e164, FakeAuthRepository.testPhone);
  });

  test('leading zero and international format are accepted', () async {
    expect(await c.submitPhone('0810000001'), isTrue);
    c.reset();
    expect(await c.submitPhone('+243 81 000 0001'), isTrue);
    expect(repo.sent, everyElement(FakeAuthRepository.testPhone));
  });

  test('invalid number is rejected without calling the provider', () async {
    expect(await c.submitPhone('12'), isFalse);
    expect(c.failure, AuthFailureReason.invalidPhone);
    expect(c.step, PhoneAuthStep.phone);
    expect(repo.sent, isEmpty);
  });

  test('provider send failures stay on the phone step with a reason', () async {
    for (final reason in [
      AuthFailureReason.tooManyRequests,
      AuthFailureReason.quotaExceeded,
      AuthFailureReason.network,
    ]) {
      repo.verifyFailure = reason;
      expect(await c.submitPhone('810000001'), isFalse);
      expect(c.failure, reason);
      expect(c.step, PhoneAuthStep.phone);
    }
  });

  group('code entry', () {
    setUp(() async => c.submitPhone('810000001'));

    test('correct code signs in', () async {
      expect(await c.submitCode(FakeAuthRepository.testCode), isTrue);
      expect(repo.signedIn?.phone, FakeAuthRepository.testPhone);
    });

    test('wrong code reports invalidCode and allows retry', () async {
      expect(await c.submitCode('000000'), isFalse);
      expect(c.failure, AuthFailureReason.invalidCode);
      expect(c.step, PhoneAuthStep.codeSent);
      expect(await c.submitCode(FakeAuthRepository.testCode), isTrue);
      expect(c.failure, isNull);
    });

    test('short code is rejected locally', () async {
      expect(await c.submitCode('123'), isFalse);
      expect(c.failure, AuthFailureReason.invalidCode);
    });

    test('expired and too-many-tries are surfaced', () async {
      repo.confirmFailure = AuthFailureReason.codeExpired;
      await c.submitCode('123456');
      expect(c.failure, AuthFailureReason.codeExpired);
      repo.confirmFailure = AuthFailureReason.tooManyRequests;
      await c.submitCode('123456');
      expect(c.failure, AuthFailureReason.tooManyRequests);
    });
  });

  testWidgets('resend is locked until the cooldown ends', (tester) async {
    await c.submitPhone('810000001');
    expect(c.canResend, isFalse);
    expect(c.resendSecondsLeft, 30);

    await tester.pump(const Duration(seconds: 29));
    expect(c.canResend, isFalse);
    await c.resend();
    expect(repo.resends, 0);

    await tester.pump(const Duration(seconds: 1));
    expect(c.canResend, isTrue);
    await c.resend();
    expect(repo.resends, 1);
    expect(c.resendSecondsLeft, 30);
    await tester.pump(const Duration(seconds: 30));
  });

  test('editNumber returns to the phone step', () async {
    await c.submitPhone('810000001');
    c.editNumber();
    expect(c.step, PhoneAuthStep.phone);
    expect(c.e164, isNull);
  });
}
