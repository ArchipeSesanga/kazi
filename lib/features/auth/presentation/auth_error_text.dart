import '../../../core/l10n/app_localizations.dart';
import '../domain/auth_repository.dart';

/// Localised message for a phone sign-in failure.
String authFailureText(AppLocalizations l, AuthFailureReason reason) =>
    switch (reason) {
      AuthFailureReason.invalidPhone => l.authPhoneInvalid,
      AuthFailureReason.invalidCode => l.authOtpWrong,
      AuthFailureReason.codeExpired => l.authOtpExpired,
      AuthFailureReason.tooManyRequests => l.authOtpTooMany,
      AuthFailureReason.quotaExceeded => l.authPhoneQuota,
      AuthFailureReason.network => l.authPhoneNetwork,
      AuthFailureReason.unknown => l.errorUnknown,
    };
