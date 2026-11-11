import 'flavor.dart';

abstract final class Env {
  static const bool useEmulators =
      bool.fromEnvironment('USE_EMULATORS');

  static const String emulatorHost =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');

  static bool get isDev => FlavorConfig.current == Flavor.dev;
  static bool get isProd => FlavorConfig.current == Flavor.prod;

  // Region for Firebase services — matches all Firebase products per TDD §1.1.
  static const String functionsRegion = 'africa-south1';
}
