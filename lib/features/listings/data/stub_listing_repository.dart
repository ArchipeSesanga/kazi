import '../../../core/models/enums.dart';
import '../../../core/state/paged_state.dart';
import '../domain/listing_repository.dart';

/// Returns empty data for all queries until FirestoreListingRepository (KZ-050+) is implemented.
class StubListingRepository implements ListingRepository {
  const StubListingRepository();

  @override
  Future<Listing?> getListing(String id) async => null;

  @override
  Future<PageResult<Listing>> fetchByProvider(
    String providerId, {
    Object? cursor,
  }) async =>
      const PageResult(items: [], hasMore: false);

  @override
  Stream<List<Listing>> watchMine(String uid) => const Stream.empty();
  @override
  Future<int> fetchMaxListings() async => 10;

  @override
  Future<ListingQuota> getQuota(String uid) async =>
      const ListingQuota(used: 0, max: 10);


  @override
  Future<String> createDraft(Listing draft) async => '';

  @override
  Future<void> update(String id, Map<String, dynamic> fields) async {}

  @override
  Future<void> setStatus(String id, ListingStatus status) async {}

  @override
  Future<void> delete(String id) async {}
}
