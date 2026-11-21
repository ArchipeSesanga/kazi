import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/controllers/locale_controller.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/kazi_theme.dart';

/// Lets the router handle the system back button first, then swallows it so
/// Android back never closes the app (internal navigation only).
class _NoExitBackButtonDispatcher extends RootBackButtonDispatcher {
  @override
  Future<bool> didPopRoute() async {
    await super.didPopRoute();
    return true;
  }
}

class KaziApp extends StatefulWidget {
  const KaziApp({super.key});

  @override
  State<KaziApp> createState() => _KaziAppState();
}

class _KaziAppState extends State<KaziApp> {
  final _backDispatcher = _NoExitBackButtonDispatcher();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
    final router = context.watch<GoRouter>();
    return MaterialApp.router(
      title: 'Kazi',
      debugShowCheckedModeBanner: false,
      theme: KaziTheme.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: _backDispatcher,
    );
  }
}
