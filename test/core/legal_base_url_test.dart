import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/config/app_defaults.dart';

void main() {
  test('AppDefaults.legalBaseUrl is the only place the legal base URL lives', () {
    final host = Uri.parse(AppDefaults.legalBaseUrl).host;
    expect(host, isNotEmpty);

    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Generated Firebase config legitimately names the project's hosts.
      if (entity.path.contains('firebase_options')) continue;
      if (entity.path.endsWith('app_defaults.dart')) continue;
      final text = entity.readAsStringSync();
      if (text.contains(host) || text.contains('kazi-prod-d9c00.web.app')) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test('the base URL is https and has no trailing slash', () {
    expect(AppDefaults.legalBaseUrl, startsWith('https://'));
    expect(AppDefaults.legalBaseUrl, isNot(endsWith('/')));
  });
}
