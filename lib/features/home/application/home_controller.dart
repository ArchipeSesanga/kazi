import 'package:flutter/foundation.dart';

import '../../provider_profile/domain/provider_repository.dart';

export '../../provider_profile/domain/provider_repository.dart'
    show ProviderProfile;

class HomeController extends ChangeNotifier {
  HomeController(this._providerRepo);

  final ProviderRepository _providerRepo;

  List<ProviderProfile> _providers = [];
  bool _isLoading = false;
  Object? _error;
  String? _selectedCommuneId;

  List<ProviderProfile> get providers => _providers;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  String? get selectedCommuneId => _selectedCommuneId;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _providerRepo.fetchPopular(city: 'kinshasa');
      _providers = result.items;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  void setCommune(String? communeId) {
    if (_selectedCommuneId == communeId) return;
    _selectedCommuneId = communeId;
    notifyListeners();
    load();
  }
}
