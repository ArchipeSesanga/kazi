import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_providers.dart';
import 'app/kazi_app.dart';
import 'core/config/env.dart';
import 'core/config/flavor.dart';
import 'core/config/remote_config_keys.dart';
import 'firebase_options_dev.dart' as dev_opts;
import 'firebase_options_prod.dart' as prod_opts;

const bool _enableCrashlytics = bool.fromEnvironment('CRASHLYTICS');

Future<void> bootstrap({bool admin = false}) async {
  // 1.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase init with flavor-appropriate options.
  await Firebase.initializeApp(
    options: FlavorConfig.current == Flavor.prod
        ? prod_opts.DefaultFirebaseOptionsProd.currentPlatform
        : dev_opts.DefaultFirebaseOptions.currentPlatform,
  );

  // 3. App Check — debug provider in dev, Play Integrity in prod.
  //    Wrapped in a timeout so a network hiccup never freezes the launch.
  await FirebaseAppCheck.instance
      .activate(
        androidProvider:
            Env.isDev ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        webProvider: ReCaptchaEnterpriseProvider(''), // TODO: set prod site key
      )
      .timeout(const Duration(seconds: 5), onTimeout: () {})
      .catchError((_) {});

  // 4 + 5. Emulator wiring (combined with Firestore settings to avoid double-write).
  if (Env.useEmulators) {
    final host = Env.emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.settings = Settings(
      host: '$host:8080',
      sslEnabled: false,
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instanceFor(region: Env.functionsRegion)
        .useFunctionsEmulator(host, 5001);
  } else {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
  }

  // 6. Crashlytics — enabled in prod or when CRASHLYTICS=true in dev.
  final enableCrashlytics = Env.isProd || _enableCrashlytics;
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(enableCrashlytics);
  if (enableCrashlytics) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // 7. Remote Config — set defaults then fetch with a 3 s timeout.
  await _initRemoteConfig();

  // 8. SharedPreferences — needed by LocaleController.
  final prefs = await SharedPreferences.getInstance();

  // 9. Run the app.
  runApp(AppProviders(prefs: prefs, child: KaziApp(admin: admin)));
}

Future<void> _initRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({
    RemoteConfigKeys.minSupportedBuild: 1,
    RemoteConfigKeys.maintenanceMode: false,
    RemoteConfigKeys.maintenanceMessageFr: '',
    RemoteConfigKeys.maintenanceMessageEn: '',
    RemoteConfigKeys.promoBannerEnabled: true,
    RemoteConfigKeys.supportWhatsapp: '',
    RemoteConfigKeys.termsVersion: '2026-11',
    RemoteConfigKeys.maxListingPhotos: 6,
    RemoteConfigKeys.storeUrl: '',
  });
  try {
    await remoteConfig
        .fetchAndActivate()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
  } catch (_) {
    // Fetch failed — defaults already applied above, app continues normally.
  }
}
