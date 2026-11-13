import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/controllers/locale_controller.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/kazi_theme.dart';
import 'router/app_router.dart';

class KaziApp extends StatelessWidget {
  const KaziApp({super.key, this.admin = false});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
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
      routerConfig: appRouter,
    );
  }
}
