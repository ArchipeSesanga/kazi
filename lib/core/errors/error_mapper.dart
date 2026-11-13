import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app_exception.dart';

AppException mapException(Object e, [StackTrace? stack]) {
  if (e is AppException) return e;

  if (e is FirebaseAuthException) return _mapAuthException(e);
  if (e is FirebaseFunctionsException) return _mapFunctionsException(e);
  if (e is FirebaseException) return _mapFirebaseException(e);

  if (e is SocketException) return const NetworkException();
  if (e is TimeoutException) return const NetworkException('timeout');

  FirebaseCrashlytics.instance.recordError(e, stack ?? StackTrace.current);
  return UnknownException(e.toString());
}

AppException _mapAuthException(FirebaseAuthException e) {
  return switch (e.code) {
    'network-request-failed' => const NetworkException(),
    'too-many-requests' => const TooManyRequestsException(),
    'invalid-verification-code' ||
    'invalid-sms-code' =>
      const OtpInvalidException(),
    'session-expired' || 'code-expired' => const OtpExpiredException(),
    'user-not-found' ||
    'user-disabled' ||
    'account-exists-with-different-credential' =>
      PermissionDeniedException(e.message),
    'requires-recent-login' => const UnauthenticatedException(),
    'operation-not-allowed' || 'web-storage-unsupported' =>
      PermissionDeniedException(e.message),
    _ => UnknownException('auth/${e.code}'),
  };
}

AppException _mapFunctionsException(FirebaseFunctionsException e) {
  return switch (e.code) {
    'unauthenticated' => const UnauthenticatedException(),
    'permission-denied' => const PermissionDeniedException(),
    'invalid-argument' || 'failed-precondition' =>
      InvalidInputException(e.message),
    'resource-exhausted' => const RateLimitedException(),
    'not-found' => const NotFoundException(),
    'unavailable' || 'deadline-exceeded' => const NetworkException(),
    'internal' => UnknownException(e.message),
    _ => UnknownException('functions/${e.code}'),
  };
}

AppException _mapFirebaseException(FirebaseException e) {
  return switch (e.code) {
    'permission-denied' => const PermissionDeniedException(),
    'not-found' => const NotFoundException(),
    'unavailable' || 'deadline-exceeded' || 'cancelled' =>
      const NetworkException(),
    'unauthenticated' => const UnauthenticatedException(),
    'resource-exhausted' => const QuotaExceededException(),
    'already-exists' => InvalidInputException(e.message),
    _ => UnknownException('${e.plugin}/${e.code}'),
  };
}
