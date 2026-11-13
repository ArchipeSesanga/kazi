abstract interface class GateService {
  /// Fetches latest Remote Config values and checks maintenance mode.
  Future<bool> isMaintenanceMode();

  /// Fetches latest Remote Config values and checks if the installed build
  /// is below the minimum supported build number.
  Future<bool> isUpdateRequired();

  /// Play Store URL from Remote Config (empty string if not set).
  String get storeUrl;
}
