import '../../../core/models/provider_profile.dart';
import '../../../core/state/paged_state.dart';

export '../../../core/models/provider_profile.dart';

abstract interface class ProviderRepository {
  Future<ProviderProfile?> getProvider(String id);
  Stream<ProviderProfile?> watchProvider(String id);
  Future<PageResult<ProviderProfile>> fetchPopular({
    required String city,
    String? commune,
    Object? cursor,
  });
  Future<void> createProvider(ProviderProfile profile);
  Future<void> updateProvider(String id, Map<String, dynamic> fields);
  Future<void> resubmit(String id);
}
