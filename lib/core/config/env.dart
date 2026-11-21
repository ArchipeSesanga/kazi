import 'flavor.dart';

abstract final class Env {
  static const bool useEmulators =
      bool.fromEnvironment('USE_EMULATORS');

  static const String emulatorHost =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');

  /// Compile-time opt-in for email/password sign-in in a prod build
  /// (e.g. a QA build). Never set in store builds.
  static const bool _emailAuthOverride = bool.fromEnvironment('EMAIL_AUTH');

  /// Email/password sign-in is for dev/test/emulator builds only; phone OTP is
  /// the real sign-in path in production.
  static bool get emailAuthEnabled =>
      isDev || useEmulators || _emailAuthOverride;

  static bool get isDev => FlavorConfig.current == Flavor.dev;
  static bool get isProd => FlavorConfig.current == Flavor.prod;

  // Region for Firebase services — matches all Firebase products per TDD §1.1.
  static const String functionsRegion = 'africa-south1';
}
