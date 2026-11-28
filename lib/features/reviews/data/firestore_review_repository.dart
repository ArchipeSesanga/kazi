import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/state/paged_state.dart';
import '../domain/review_repository.dart';

/// `providers/{providerId}/reviews/{authorUid}`: the document id is the
/// author's uid, so a user can only ever have one review per provider.
class FirestoreReviewRepository implements ReviewRepository {
  const FirestoreReviewRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String providerId) =>
      _db.collection('providers').doc(providerId).collection('reviews');

  @override
  Future<PageResult<Review>> fetch(String providerId, {Object? cursor}) async {
    try {
      var q = _col(providerId).orderBy('createdAt', descending: true);
      if (cursor != null) q = q.startAfterDocument(cursor as DocumentSnapshot);
      final snap = await q.limit(reviewPageSize).get();
      return PageResult(
        items: snap.docs.map((d) => Review.fromJson(d.data())).toList(),
        hasMore: snap.docs.length == reviewPageSize,
        cursor: snap.docs.isEmpty ? cursor : snap.docs.last,
      );
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<Review?> getMine(String providerId, String uid) async {
    try {
      final snap = await _col(providerId).doc(uid).get();
      final data = snap.data();
      return data == null ? null : Review.fromJson(data);
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  /// Create or edit. The rules treat them differently (create needs a prior
  /// contact; an edit may only change rating and text), so look first.
  @override
  Future<void> upsert(String providerId, Review review) async {
    try {
      final ref = _col(providerId).doc(review.authorUid);
      final existing = await ref.get();
      if (existing.exists) {
        await ref.update(review.toUpdateMap());
      } else {
        await ref.set(review.toCreateMap());
      }
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> delete(String providerId, String uid) async {
    try {
      await _col(providerId).doc(uid).delete();
    } catch (e, s) {
      throw mapException(e, s);
    }
  }
}
