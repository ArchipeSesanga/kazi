import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/error_mapper.dart';
import '../domain/block_repository.dart';

class FirestoreBlockRepository implements BlockRepository {
  const FirestoreBlockRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid).collection('blocks');

  @override
  Stream<Set<String>> watchBlockedUids(String uid) {
    return _ref(uid)
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet())
        .handleError((Object e, StackTrace s) => throw mapException(e, s));
  }

  @override
  Future<void> block(String uid, String blockedUid) async {
    try {
      await _ref(uid)
          .doc(blockedUid)
          .set({'createdAt': FieldValue.serverTimestamp()});
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<void> unblock(String uid, String blockedUid) async {
    try {
      await _ref(uid).doc(blockedUid).delete();
    } catch (e, s) {
      throw mapException(e, s);
    }
  }
}
