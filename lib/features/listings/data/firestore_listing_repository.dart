import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/models/enums.dart';
import '../../../core/state/paged_state.dart';
import '../domain/listing_repository.dart';

class FirestoreListingRepository implements ListingRepository {
  const FirestoreListingRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('listings');

  @override
  Future<Listing?> getListing(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return Listing.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<PageResult<Listing>> fetchByProvider(
    String providerId, {
    Object? cursor,
  }) async {
    try {
      var query = _col
          .where('providerId', isEqualTo: providerId)
          .where('visible', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .limit(20);
      if (cursor != null) {
        query = query.startAfterDocument(cursor as DocumentSnapshot);
      }
      final snap = await query.get();
      final items = snap.docs
          .map((d) => Listing.fromJson({'id': d.id, ...d.data()}))
          .toList();
      return PageResult(
        items: items,
        hasMore: items.length == 20,
        cursor: snap.docs.isNotEmpty ? snap.docs.last : null,
      );
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Stream<List<Listing>> watchMine(String uid) {
    return _col
        .where('providerId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Listing.fromJson({'id': d.id, ...d.data()}))
              .toList(),
        );
  }

  @override
  Future<String> createDraft(Listing draft) async {
    try {
      final ref = await _col.add(draft.toCreateMap());
      return ref.id;
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> fields) async {
    try {
      await _col.doc(id).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> setStatus(String id, ListingStatus status) async {
    try {
      await _col.doc(id).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (e, s) {
      throw mapException(e, s);
    }
  }
}
