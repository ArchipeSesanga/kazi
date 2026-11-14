import '../../../core/state/paged_state.dart';
import '../domain/provider_repository.dart';

/// Returns empty data for all queries until FirestoreProviderRepository (KZ-040) is implemented.
class StubProviderRepository implements ProviderRepository {
  const StubProviderRepository();

  @override
  Future<ProviderProfile?> getProvider(String id) async => null;

  @override
  Stream<ProviderProfile?> watchProvider(String id) => const Stream.empty();

  @override
  Future<PageResult<ProviderProfile>> fetchPopular({
    required String city,
    String? commune,
    Object? cursor,
  }) async =>
      const PageResult(items: [], hasMore: false);

  @override
  Future<void> createProvider(ProviderProfile profile) async {}

  @override
  Future<void> updateProvider(String id, Map<String, dynamic> fields) async {}

  @override
  Future<void> resubmit(String id) async {}
}
