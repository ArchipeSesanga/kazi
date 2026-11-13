import '../../../core/models/enums.dart';
import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';

export '../../../core/models/listing.dart';

abstract interface class ListingRepository {
  Future<Listing?> getListing(String id);
  /// Public listings for a provider (visible only).
  Future<PageResult<Listing>> fetchByProvider(
    String providerId, {
    Object? cursor,
  });
  /// Owner's own listings across all statuses.
  Stream<List<Listing>> watchMine(String uid);
  Future<String> createDraft(Listing draft);
  Future<void> update(String id, Map<String, dynamic> fields);
  Future<void> setStatus(String id, ListingStatus status);
  Future<void> delete(String id);
}
