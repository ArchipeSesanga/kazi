import 'package:flutter/foundation.dart';

import '../domain/gate_service.dart';

class GateController extends ChangeNotifier {
  GateController(GateService service) {
    _init(service);
  }

  bool _isChecking = true;
  bool _isMaintenanceMode = false;
  bool _isUpdateRequired = false;
  String _storeUrl = '';

  bool get isChecking => _isChecking;
  bool get isMaintenanceMode => _isMaintenanceMode;
  bool get isUpdateRequired => _isUpdateRequired;
  String get storeUrl => _storeUrl;

  Future<void> _init(GateService service) async {
    try {
      // Both calls share one fetchAndActivate() internally (cached after first).
      _isMaintenanceMode = await service.isMaintenanceMode();
      _isUpdateRequired = await service.isUpdateRequired();
      _storeUrl = service.storeUrl;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }
}
