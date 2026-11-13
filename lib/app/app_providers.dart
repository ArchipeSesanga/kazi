import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/env.dart';
import '../core/controllers/locale_controller.dart';
import '../core/services/analytics_service.dart';
import '../core/services/connectivity_controller.dart';
import '../core/services/firebase_analytics_service.dart';
import '../core/services/launcher_service.dart';
import '../core/services/url_launcher_service.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.prefs,
    required this.child,
    super.key,
  });

  final SharedPreferences prefs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase singletons — per TDD §9.5.
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseStorage>.value(value: FirebaseStorage.instance),
        Provider<FirebaseFunctions>.value(
          value: FirebaseFunctions.instanceFor(region: Env.functionsRegion),
        ),

        // Services.
        Provider<AnalyticsService>(create: (_) => FirebaseAnalyticsService()),
        Provider<LauncherService>(create: (_) => UrlLauncherService()),

        // Repositories.
        ProxyProvider<FirebaseAuth, AuthRepository>(
          update: (_, auth, __) => FirebaseAuthRepository(auth),
        ),

        // Global controllers.
        ChangeNotifierProvider(create: (_) => ConnectivityController()),
        ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
        ChangeNotifierProxyProvider<AuthRepository, AuthController>(
          create: (ctx) => AuthController(ctx.read<AuthRepository>()),
          update: (_, repo, prev) => prev ?? AuthController(repo),
        ),

        // TODO(KZ-023): SessionController (needs UserRepository).
        // TODO(KZ-031): CatalogController (needs CatalogRepository).
        // TODO(KZ-023): FavoritesController (needs FavoritesRepository + SessionController).
      ],
      child: child,
    );
  }
}
