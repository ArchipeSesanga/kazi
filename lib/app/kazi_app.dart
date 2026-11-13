import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/kazi_theme.dart';
import 'router/app_router.dart';

class KaziApp extends StatelessWidget {
  const KaziApp({super.key, this.admin = false});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kazi',
      debugShowCheckedModeBanner: false,
      theme: KaziTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
