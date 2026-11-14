import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/listing_repository.dart';

sealed class ListingDetailState {
  const ListingDetailState();
}

final class ListingDetailLoading extends ListingDetailState {
  const ListingDetailLoading();
}

final class ListingDetailLoaded extends ListingDetailState {
  const ListingDetailLoaded(this.listing);
  final Listing listing;
}

final class ListingDetailNotFound extends ListingDetailState {
  const ListingDetailNotFound();
}

final class ListingDetailError extends ListingDetailState {
  const ListingDetailError(this.error);
  final AppException error;
}

class ListingDetailController extends ChangeNotifier {
  ListingDetailController(this._repo, this._listingId);

  final ListingRepository _repo;
  final String _listingId;

  ListingDetailState _state = const ListingDetailLoading();
  ListingDetailState get state => _state;

  void init() => _load();

  Future<void> refresh() => _load();

  Future<void> _load() async {
    _state = const ListingDetailLoading();
    notifyListeners();
    try {
      final listing = await _repo.getListing(_listingId);
      _state = listing == null
          ? const ListingDetailNotFound()
          : ListingDetailLoaded(listing);
    } catch (e, s) {
      _state = ListingDetailError(mapException(e, s));
    }
    notifyListeners();
  }
}
