import '../../../core/models/enums.dart';
import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';

export '../../../core/models/listing.dart';

/// How many listings a provider has versus the configured limit
/// (Firestore `config/limits`, TDD §12).
class ListingQuota {
  const ListingQuota({required this.used, required this.max});

  final int used;
  final int max;

  bool get reached => used >= max;
}

abstract interface class ListingRepository {
  Future<Listing?> getListing(String id);
  /// Public listings for a provider (visible only).
  Future<PageResult<Listing>> fetchByProvider(
    String providerId, {
    Object? cursor,
  });
  /// Owner's own listings across all statuses.
  Stream<List<Listing>> watchMine(String uid);

  /// `config/limits.maxListingsPerProvider`, falling back to
  /// `Limits.maxListingsPerProvider` when the document is missing.
  Future<int> fetchMaxListings();

  /// Provider's non-deleted listing count (the value the Firestore rules
  /// compare) against the configured maximum.
  Future<ListingQuota> getQuota(String uid);
  Future<String> createDraft(Listing draft);
  Future<void> update(String id, Map<String, dynamic> fields);
  Future<void> setStatus(String id, ListingStatus status);
  Future<void> delete(String id);
}
