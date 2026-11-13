import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/remote_config_keys.dart';
import '../domain/gate_service.dart';

class RemoteConfigGateService implements GateService {
  RemoteConfigGateService(this._rc);

  final FirebaseRemoteConfig _rc;

  @override
  Future<bool> isMaintenanceMode() async {
    await _fetchSafely();
    return _rc.getBool(RemoteConfigKeys.maintenanceMode);
  }

  @override
  Future<bool> isUpdateRequired() async {
    await _fetchSafely();
    final minBuild = _rc.getInt(RemoteConfigKeys.minSupportedBuild);
    if (minBuild <= 0) return false;
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;
    return currentBuild < minBuild;
  }

  @override
  String get storeUrl => _rc.getString(RemoteConfigKeys.storeUrl);

  /// Silently swallows network errors — cached values are used as fallback.
  Future<void> _fetchSafely() async {
    try {
      await _rc.fetchAndActivate();
    } catch (_) {}
  }
}
