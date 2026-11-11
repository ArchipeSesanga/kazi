// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kazi';

  @override
  String get errorNetwork => 'Cannot connect. Check your connection.';

  @override
  String get errorPermissionDenied => 'Access denied.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorInvalidInput =>
      'Invalid data. Please check the information entered.';

  @override
  String get errorRateLimited => 'Too many attempts. Please wait.';

  @override
  String get errorOtpInvalid => 'Incorrect code. Check and try again.';

  @override
  String get errorOtpExpired => 'Code expired. Request a new code.';

  @override
  String get errorTooManyRequests => 'Too many requests. Try again later.';

  @override
  String get errorQuotaExceeded => 'Quota reached. Try again later.';

  @override
  String get errorUnauthenticated => 'You must be signed in to continue.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get offlineBanner => 'Offline — showing cached data';
}
