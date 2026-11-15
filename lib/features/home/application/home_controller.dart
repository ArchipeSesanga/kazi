import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/models/listing.dart';
import '../../provider_profile/domain/provider_repository.dart';
import '../../search/domain/search_repository.dart';

export '../../provider_profile/domain/provider_repository.dart'
    show ProviderProfile;

class HomeController extends ChangeNotifier {
  HomeController(this._providerRepo, this._searchRepo);

  static const _recentLimit = 10;

  final ProviderRepository _providerRepo;
  final SearchRepository _searchRepo;

  List<ProviderProfile> _providers = [];
  List<Listing> _recent = [];
  bool _isLoading = false;
  bool _isLoadingRecent = false;
  Object? _error;
  AppException? _recentError;
  String? _selectedCommuneId;
  bool _disposed = false;

  List<ProviderProfile> get providers => _providers;

  /// "Ajoutés récemment": visible listings, `publishedAt` descending.
  List<Listing> get recentListings => _recent;
  bool get isLoading => _isLoading;
  bool get isLoadingRecent => _isLoadingRecent;
  Object? get error => _error;

  /// Query error of the recent listings (e.g. a missing index), surfaced
  /// instead of an empty list.
  AppException? get recentError => _recentError;
  String? get selectedCommuneId => _selectedCommuneId;

  Future<void> load() async {
    await Future.wait([_loadProviders(), _loadRecent()]);
  }

  Future<void> _loadProviders() async {
    _isLoading = true;
    _error = null;
    _notify();
    try {
      final result = await _providerRepo.fetchPopular(
        city: 'kinshasa',
        commune: _selectedCommuneId,
      );
      _providers = result.items;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<void> _loadRecent() async {
    _isLoadingRecent = true;
    _recentError = null;
    _notify();
    try {
      // City-wide on purpose: a commune filter would switch the search
      // query to `ratingAvg` ordering (TDD §8.2).
      final result = await _searchRepo.search(
        const SearchQuery(sort: SearchSort.recent),
      );
      _recent = result.items.take(_recentLimit).toList();
    } catch (e, s) {
      _recentError = mapException(e, s);
    } finally {
      _isLoadingRecent = false;
      _notify();
    }
  }

  Future<void> refresh() => load();

  void setCommune(String? communeId) {
    if (_selectedCommuneId == communeId) return;
    _selectedCommuneId = communeId;
    notifyListeners();
    _loadProviders();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
