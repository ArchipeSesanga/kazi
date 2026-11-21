import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/app/router/guards.dart';
import 'package:kazi/app/router/routes.dart';
import 'package:kazi/core/models/app_user.dart';
import 'package:kazi/features/auth/application/session_controller.dart';
import 'package:kazi/features/auth/domain/auth_repository.dart';
import 'package:kazi/features/auth/domain/user_repository.dart';
import 'package:kazi/features/gate/application/gate_controller.dart';
import 'package:kazi/features/gate/domain/gate_service.dart';
import 'package:kazi/features/welcome/application/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/fake_auth_repository.dart';

class _Users implements UserRepository {
  _Users(this.user);
  final AppUser? user;
  @override
  Stream<AppUser?> watchUser(String uid) => Stream.value(user);
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
  _Gate({this.maintenance = false, this.update = false});
  final bool maintenance;
  final bool update;
  @override
  Future<bool> isMaintenanceMode() async => maintenance;
  @override
  Future<bool> isUpdateRequired() async => update;
  @override
  String get storeUrl => '';
}

const _profile = AppUser(
  uid: 'u1',
  displayName: 'Alice Mbuyi',
  phone: '+243810000001',
);

class _Env {
  _Env(this.session, this.gate, this.onboarding, this.providerLookups);
  final SessionController session;
  final GateController gate;
  final OnboardingController onboarding;
  final List<String> providerLookups;

  Future<String?> redirect(String location, {bool email = false}) async =>
      resolveRedirect(
        location: location,
        session: session,
        gate: gate,
        onboarding: onboarding,
        emailAuthEnabled: email,
      );

  /// Follows redirects like go_router does; fails on a loop.
  Future<String> settle(String location, {bool email = false}) async {
    var current = location;
    for (var i = 0; i < 4; i++) {
      final next = await redirect(current, email: email);
      if (next == null) return current;
      current = next;
    }
    fail('redirect loop starting at $location, ended at $current');
  }
}

Future<_Env> _env({
  bool signedIn = false,
  bool withProfile = false,
  bool admin = false,
  bool moderator = false,
  bool phone = true,
  bool providerDoc = false,
  bool onboarded = true,
  _Gate? gate,
}) async {
  SharedPreferences.setMockInitialValues({'onboarding_complete': onboarded});
  final prefs = await SharedPreferences.getInstance();
  final lookups = <String>[];
  final session = SessionController(
    _Users(withProfile ? _profile : null),
    FakeAuthRepository(
      signedIn: signedIn
          ? AuthUser(
              uid: 'u1',
              phone: phone ? '+243810000001' : null,
              isAdmin: admin,
              isModerator: moderator,
            )
          : null,
    ),
    providerExists: (uid) async {
      lookups.add(uid);
      return providerDoc;
    },
  );
  final gateController = GateController(gate ?? _Gate());
  // Let the auth and user streams and the gate check resolve.
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return _Env(session, gateController, OnboardingController(prefs), lookups);
}

void main() {
  group('level 1 — no session', () {
    test('only welcome and phone sign-in are open after onboarding', () async {
      final e = await _env();
      expect(await e.settle(Routes.authPhone), Routes.authPhone);
      expect(await e.settle(Routes.authOtp), Routes.authOtp);
      expect(await e.settle(Routes.welcome), Routes.authPhone);
      for (final blocked in [
        Routes.home,
        Routes.explore,
        Routes.publish,
        Routes.messages,
        Routes.profile,
        Routes.providerDashboard,
        Routes.authSetupProfile,
        '/p/abc',
        '/admin/users',
      ]) {
        expect(await e.settle(blocked), Routes.authPhone, reason: blocked);
      }
    });

    test('before onboarding everything leads to welcome', () async {
      final e = await _env(onboarded: false);
      expect(await e.settle(Routes.welcome), Routes.welcome);
      expect(await e.settle(Routes.authPhone), Routes.welcome);
      expect(await e.settle(Routes.home), Routes.welcome);
    });

    test('email sign-in is only reachable when enabled', () async {
      final e = await _env();
      expect(await e.settle(Routes.authEmail), Routes.authPhone);
      expect(await e.settle(Routes.authEmail, email: true), Routes.authEmail);
    });
  });

  group('level 2 — session without users/{uid}', () {
    test('profile setup is the only allowed route', () async {
      final e = await _env(signedIn: true);
      expect(await e.settle(Routes.authSetupProfile), Routes.authSetupProfile);
      for (final other in [
        Routes.home,
        Routes.authPhone,
        Routes.welcome,
        Routes.publish,
        Routes.providerDashboard,
        Routes.legalTerms,
        '/admin',
      ]) {
        expect(await e.settle(other), Routes.authSetupProfile, reason: other);
      }
    });
  });

  group('level 3 — complete profile', () {
    test('the app is open and auth screens bounce to home', () async {
      final e = await _env(signedIn: true, withProfile: true);
      expect(await e.settle(Routes.home), Routes.home);
      expect(await e.settle('/p/abc'), '/p/abc');
      expect(await e.settle(Routes.providerOnboarding), Routes.providerOnboarding);
      expect(await e.settle(Routes.splash), Routes.home);
      expect(await e.settle(Routes.welcome), Routes.home);
      expect(await e.settle(Routes.authPhone), Routes.home);
      expect(await e.settle(Routes.authSetupProfile), Routes.home);
    });

    test('provider routes need providers/{uid}', () async {
      final without = await _env(signedIn: true, withProfile: true);
      for (final r in [
        Routes.providerDashboard,
        Routes.providerNewListing,
        Routes.providerVerification,
        Routes.editListing('l1'),
      ]) {
        expect(await without.settle(r), providerFallback, reason: r);
      }
      // The fallback itself is not guarded, so no loop.
      expect(await without.settle(providerFallback), providerFallback);

      final withDoc =
          await _env(signedIn: true, withProfile: true, providerDoc: true);
      expect(await withDoc.settle(Routes.providerDashboard),
          Routes.providerDashboard);
      expect(await withDoc.settle(Routes.editListing('l1')),
          Routes.editListing('l1'));
    });

    test('a positive provider check is cached, a negative one is not',
        () async {
      final yes =
          await _env(signedIn: true, withProfile: true, providerDoc: true);
      await yes.redirect(Routes.providerDashboard);
      await yes.redirect(Routes.providerNewListing);
      await yes.redirect(Routes.providerVerification);
      expect(yes.providerLookups, hasLength(1));

      final no = await _env(signedIn: true, withProfile: true);
      await no.redirect(Routes.providerDashboard);
      await no.redirect(Routes.providerDashboard);
      expect(no.providerLookups, hasLength(2));
    });

    test('admin routes need a staff claim', () async {
      final user = await _env(signedIn: true, withProfile: true);
      expect(await user.settle('/admin'), Routes.home);
      expect(await user.settle('/admin/providers'), Routes.home);
      expect(await user.settle('/admin/categories'), Routes.home);

      final admin =
          await _env(signedIn: true, withProfile: true, admin: true);
      expect(await admin.settle('/admin/providers'), '/admin/providers');
      // Lookalike paths are not admin routes.
      expect(await user.settle('/administrators'), '/administrators');
    });

    test('staff without a phone or a profile bypass profile setup (twins)',
        () async {
      // Twin 1: a plain email-style account with no profile is held at setup.
      final plain = await _env(signedIn: true, phone: false);
      expect(await plain.settle('/admin/reports'), Routes.authSetupProfile);
      expect(await plain.settle(Routes.home), Routes.authSetupProfile);

      // Same account with the moderator claim goes straight in.
      final mod = await _env(signedIn: true, phone: false, moderator: true);
      expect(await mod.settle('/admin/reports'), '/admin/reports');
      expect(await mod.settle(Routes.home), Routes.home);

      // And with the admin claim, including admin-only routes.
      final admin = await _env(signedIn: true, phone: false, admin: true);
      expect(await admin.settle('/admin/roles'), '/admin/roles');
      // A moderator still cannot reach admin-only routes without a phone.
      expect(await mod.settle('/admin/roles'), Routes.home);
    });

    test('moderators get moderation routes, not admin-only ones', () async {
      final mod =
          await _env(signedIn: true, withProfile: true, moderator: true);
      for (final r in ['/admin', '/admin/providers', '/admin/reports']) {
        expect(await mod.settle(r), r, reason: r);
      }
      for (final r in [
        '/admin/categories',
        '/admin/categories/new',
        '/admin/roles',
        '/admin/logs',
      ]) {
        expect(await mod.settle(r), Routes.home, reason: r);
      }

      final admin =
          await _env(signedIn: true, withProfile: true, admin: true);
      for (final r in ['/admin/categories', '/admin/roles', '/admin/logs']) {
        expect(await admin.settle(r), r, reason: r);
      }
    });
  });

  group('gates and loading', () {
    test('maintenance wins over every level and cannot be escaped', () async {
      for (final signedIn in [false, true]) {
        final e = await _env(
          signedIn: signedIn,
          withProfile: signedIn,
          gate: _Gate(maintenance: true),
        );
        expect(await e.settle(Routes.home), Routes.maintenance);
        expect(await e.settle(Routes.maintenance), Routes.maintenance);
      }
    });

    test('update-required blocks a signed-in user', () async {
      final e = await _env(
        signedIn: true,
        withProfile: true,
        gate: _Gate(update: true),
      );
      expect(await e.settle(Routes.home), Routes.updateRequired);
    });

    test('splash is held while the session resolves', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final never = StreamController<AuthUser?>();
      final session = SessionController(_Users(null), _Hanging(never.stream));
      final r = resolveRedirect(
        location: Routes.home,
        session: session,
        gate: GateController(_Gate()),
        onboarding: OnboardingController(prefs),
        emailAuthEnabled: false,
      );
      expect(r, Routes.splash);
      await never.close();
    });
  });

  test('route classification', () {
    expect(isProviderRoute(Routes.providerOnboarding), isFalse);
    expect(isProviderRoute('/provider/listings/new'), isTrue);
    expect(isAdminRoute('/admin'), isTrue);
    expect(isAdminRoute('/administrators'), isFalse);
    expect(isAdminOnlyRoute('/admin/roles'), isTrue);
    expect(isAdminOnlyRoute('/admin/reports'), isFalse);
  });
}

class _Hanging extends FakeAuthRepository {
  _Hanging(this._stream);
  final Stream<AuthUser?> _stream;
  @override
  Stream<AuthUser?> authStateChanges() => _stream;
}
