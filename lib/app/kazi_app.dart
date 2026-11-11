import 'package:flutter/material.dart';

import 'router/app_router.dart';

// TODO(KZ-006): wire KaziTheme
// TODO(KZ-012): wire AppLocalizations
// TODO(KZ-002): wrap with AppProviders once Firebase is wired
class KaziApp extends StatelessWidget {
  const KaziApp({super.key, this.admin = false});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kazi',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
