import 'package:flutter/material.dart';

import 'app/kazi_app.dart';

// TODO(KZ-002): add Firebase init, App Check, emulator wiring,
//               Crashlytics, Remote Config per TDD §3.2.
Future<void> bootstrap({bool admin = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KaziApp(admin: admin));
}
