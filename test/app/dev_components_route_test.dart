import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kazi/app/router/app_router.dart';
import 'package:kazi/app/router/routes.dart';
import 'package:kazi/core/config/env.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/gate/application/gate_controller.dart';
import 'package:kazi/features/gate/domain/gate_service.dart';
import 'package:kazi/features/welcome/application/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';

class _Users implements UserRepository {
  @override
  Stream<AppUser?> watchUser(String uid) => const Stream.empty();
  @override
  Future<void> createUser(AppUser user) async {}
  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> registerDevice(String uid, String fcmToken) async {}
}

class _Gate implements GateService {
  @override
  Future<bool> isMaintenanceMode() async => false;
  @override
  Future<bool> isUpdateRequired() async => false;
  @override
  String get storeUrl => '';
}

Future<GoRouter> _router({bool? devToolsEnabled}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return createAppRouter(
    SessionController(_Users(), FakeAuthRepository()),
    GateController(_Gate()),
    OnboardingController(prefs),
    devToolsEnabled: devToolsEnabled,
  );
}

bool _hasDevRoute(GoRouter r) => r.configuration.routes
    .whereType<GoRoute>()
    .any((g) => g.path == Routes.devComponents);

void main() {
  test('prod build: /dev/components is not registered', () async {
    expect(_hasDevRoute(await _router(devToolsEnabled: false)), isFalse);
  });

  test('dev build: /dev/components is registered', () async {
    expect(_hasDevRoute(await _router(devToolsEnabled: true)), isTrue);
  });

  test('the default follows the flavor (dev in tests)', () async {
    expect(Env.isDev, isTrue);
    expect(_hasDevRoute(await _router()), isTrue);
  });
}
