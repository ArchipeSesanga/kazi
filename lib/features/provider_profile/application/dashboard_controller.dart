import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/limits.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/models/enums.dart';
import '../../listings/domain/listing_repository.dart';
import '../domain/provider_repository.dart';

enum ListingAction { pause, resume, delete }

/// Result of a pause / resume / delete, for the screen to turn into a
/// success or error message.
class ListingActionResult {
  const ListingActionResult.success(this.action) : error = null;
  const ListingActionResult.failure(this.action, AppException this.error);

  final ListingAction action;
  final AppException? error;

  bool get isSuccess => error == null;
}

class DashboardController extends ChangeNotifier {
  DashboardController(this._providerRepo, this._listingRepo);

  final ProviderRepository _providerRepo;
  final ListingRepository _listingRepo;

  StreamSubscription<ProviderProfile?>? _profileSub;
  StreamSubscription<List<Listing>>? _listingsSub;
  String? _uid;
  bool _disposed = false;

  ProviderProfile? profile;
  List<Listing> listings = [];
  bool isLoading = true;
  bool isLoadingListings = true;
  AppException? error;
  AppException? listingsError;

  /// Configured limit (Firestore `config/limits`); fallback until loaded.
  int maxListings = Limits.maxListingsPerProvider;

  final Set<String> _busy = {};

  /// Listing ids with a pause / resume / delete in flight.
  bool isBusy(String listingId) => _busy.contains(listingId);

  /// Listings counted against the limit: active + paused only (drafts and
  /// listings hidden for the limit do not count). The server count is what
  /// the rules compare, the local list is what the user sees; use the larger.
  int get usedListings {
    final server = profile?.listingCount ?? 0;
    final local = listings.where((l) => l.countsTowardLimit).length;
    return server > local ? server : local;
  }

  bool get limitReached => usedListings >= maxListings;

  void init(String uid) {
    _uid = uid;
    unawaited(_loadLimit());

    _profileSub = _providerRepo
        .watchProvider(uid)
        .listen(
          (p) {
            profile = p;
            isLoading = false;
            _notify();
          },
          onError: (Object e, StackTrace s) {
            error = mapException(e, s);
            isLoading = false;
            _notify();
          },
        );
    _listen(uid);
  }

  void _listen(String uid) {
    unawaited(_listingsSub?.cancel());
    listingsError = null;
    _listingsSub = _listingRepo
        .watchMine(uid)
        .listen(
          (list) {
            listings = list;
            listingsError = null;
            isLoadingListings = false;
            _notify();
          },
          onError: (Object e, StackTrace s) {
            listingsError = mapException(e, s);
            isLoadingListings = false;
            _notify();
          },
        );
  }

  /// Re-subscribes after a listings query error.
  void retryListings() {
    final uid = _uid;
    if (uid == null) return;
    isLoadingListings = true;
    _notify();
    _listen(uid);
  }

  Future<void> _loadLimit() async {
    maxListings = await _listingRepo.fetchMaxListings();
    _notify();
  }

  Future<ListingActionResult> pauseListing(String id) => _run(
    ListingAction.pause,
    id,
    () => _listingRepo.setStatus(id, ListingStatus.paused),
  );

  Future<ListingActionResult> resumeListing(String id) => _run(
    ListingAction.resume,
    id,
    () => _listingRepo.setStatus(id, ListingStatus.active),
  );

  Future<ListingActionResult> deleteListing(String id) =>
      _run(ListingAction.delete, id, () => _listingRepo.delete(id));

  Future<ListingActionResult> _run(
    ListingAction action,
    String id,
    Future<void> Function() op,
  ) async {
    if (!_busy.add(id)) {
      return ListingActionResult.failure(
        action,
        const UnknownException('busy'),
      );
    }
    _notify();
    try {
      await op();
      return ListingActionResult.success(action);
    } catch (e, s) {
      return ListingActionResult.failure(action, mapException(e, s));
    } finally {
      _busy.remove(id);
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _profileSub?.cancel();
    _listingsSub?.cancel();
    super.dispose();
  }
}
