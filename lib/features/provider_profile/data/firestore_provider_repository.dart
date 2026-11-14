import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/state/paged_state.dart';
import '../domain/provider_repository.dart';

class FirestoreProviderRepository implements ProviderRepository {
  const FirestoreProviderRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('providers');

  @override
  Future<ProviderProfile?> getProvider(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return ProviderProfile.fromJson({...doc.data()!, 'uid': doc.id});
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Stream<ProviderProfile?> watchProvider(String id) {
    return _col.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProviderProfile.fromJson({...doc.data()!, 'uid': doc.id});
    }).handleError((Object e, StackTrace s) => throw mapException(e, s));
  }

  @override
  Future<PageResult<ProviderProfile>> fetchPopular({
    required String city,
    String? commune,
    Object? cursor,
  }) async {
    try {
      // Index: status ASC, city ASC, ratingAvg DESC, ratingCount DESC
      Query<Map<String, dynamic>> q = _col
          .where('status', isEqualTo: 'approved')
          .where('city', isEqualTo: city)
          .orderBy('ratingAvg', descending: true)
          .orderBy('ratingCount', descending: true);

      if (cursor != null) {
        q = q.startAfterDocument(cursor as DocumentSnapshot);
      }
      q = q.limit(20);

      final snap = await q.get();
      var items = snap.docs
          .map((d) => ProviderProfile.fromJson({...d.data(), 'uid': d.id}))
          .toList();

      // No composite index for status+city+communes+ratingAvg — filter client-side.
      if (commune != null) {
        items = items
            .where((p) => p.communes.contains(commune))
            .toList();
      }

      return PageResult(
        items: items,
        hasMore: snap.docs.length == 20,
        cursor: snap.docs.isNotEmpty ? snap.docs.last : null,
      );
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> createProvider(ProviderProfile profile) async {
    try {
      await _col.doc(profile.uid).set(profile.toCreateMap());
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> updateProvider(String id, Map<String, dynamic> fields) async {
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
  Future<void> resubmit(String id) async {
    try {
      await _col.doc(id).update({
        'status': 'pending',
        'statusReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, s) {
      throw mapException(e, s);
    }
  }
}
