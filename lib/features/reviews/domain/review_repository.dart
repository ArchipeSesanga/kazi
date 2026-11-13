import '../../../core/models/review.dart';
import '../../../core/state/paged_state.dart';

export '../../../core/models/review.dart';

abstract interface class ReviewRepository {
  Future<PageResult<Review>> fetch(String providerId, {Object? cursor});
  Future<Review?> getMine(String providerId, String uid);
  Future<void> upsert(String providerId, Review review);
  Future<void> delete(String providerId, String uid);
}
