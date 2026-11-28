import '../../../core/models/review.dart';
import '../../../core/state/paged_state.dart';

export '../../../core/models/review.dart';

const int reviewPageSize = 20;

/// Reviews of a provider (`providers/{pid}/reviews/{authorUid}`). The aggregate
/// (`ratingAvg` …) is server-written; the client never touches it.
abstract interface class ReviewRepository {
  Future<PageResult<Review>> fetch(String providerId, {Object? cursor});
  Future<Review?> getMine(String providerId, String uid);

  /// Creates the review, or edits it when [review.authorUid] already has one.
  Future<void> upsert(String providerId, Review review);
  Future<void> delete(String providerId, String uid);
}
