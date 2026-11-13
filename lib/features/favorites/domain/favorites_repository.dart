import '../../../core/models/favorite.dart';
import '../../../core/models/provider_profile.dart';

export '../../../core/models/favorite.dart';

abstract interface class FavoritesRepository {
  Stream<List<Favorite>> watch(String uid);
  Future<void> add(String uid, ProviderProfile provider);
  Future<void> remove(String uid, String providerId);
}
