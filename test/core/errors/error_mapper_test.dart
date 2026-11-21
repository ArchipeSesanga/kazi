import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/errors/app_exception.dart';
import 'package:kazi/core/errors/error_mapper.dart';

void main() {
  test('maps Firestore permission-denied to PermissionDeniedException', () {
    final exception = mapException(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );

    expect(exception, isA<PermissionDeniedException>());
    expect(exception.code, 'permissionDenied');
  });

  test('maps Storage unauthorized to PermissionDeniedException', () {
    final exception = mapException(
      FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
    );

    expect(exception, isA<PermissionDeniedException>());
    expect(exception.code, 'permissionDenied');
  });
}
