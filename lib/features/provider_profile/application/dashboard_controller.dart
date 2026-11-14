import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/models/enums.dart';
import '../../listings/domain/listing_repository.dart';
import '../domain/provider_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._providerRepo, this._listingRepo);

  final ProviderRepository _providerRepo;
  final ListingRepository _listingRepo;

  StreamSubscription<ProviderProfile?>? _profileSub;
  StreamSubscription<List<Listing>>? _listingsSub;

  ProviderProfile? profile;
  List<Listing> listings = [];
  bool isLoading = true;
  bool isLoadingListings = true;
  AppException? error;

  void init(String uid) {
    _profileSub = _providerRepo.watchProvider(uid).listen(
      (p) {
        profile = p;
        isLoading = false;
        notifyListeners();
      },
      onError: (e, s) {
        error = mapException(e, s);
        isLoading = false;
        notifyListeners();
      },
    );

    _listingsSub = _listingRepo.watchMine(uid).listen(
      (list) {
        listings = list;
        isLoadingListings = false;
        notifyListeners();
      },
      onError: (_, __) {
        isLoadingListings = false;
        notifyListeners();
      },
    );
  }

  Future<void> pauseListing(String id) =>
      _listingRepo.setStatus(id, ListingStatus.paused);

  Future<void> resumeListing(String id) =>
      _listingRepo.setStatus(id, ListingStatus.active);

  Future<void> deleteListing(String id) => _listingRepo.delete(id);

  @override
  void dispose() {
    _profileSub?.cancel();
    _listingsSub?.cancel();
    super.dispose();
  }
}
