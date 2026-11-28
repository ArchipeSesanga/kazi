abstract final class AppDefaults {
  /// Current terms-of-service version string.
  /// Used as the fallback when Remote Config hasn't fetched yet.
  static const String termsVersion = '2026-11';

  /// Base URL of the public legal pages (Firebase Hosting `web` target).
  /// Pages live at `/fr/terms`, `/en/privacy`, `/delete-account`, ...
  static const String legalBaseUrl = 'https://kazi-prod-d9c00.web.app';
}
