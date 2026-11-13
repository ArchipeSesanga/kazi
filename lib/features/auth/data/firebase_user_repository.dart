import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/app_user.dart';
import '../domain/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromJson({...snap.data()!, 'uid': snap.id});
    });
  }

  @override
  Future<void> createUser(AppUser user) async {
    await _users.doc(user.uid).set(user.toCreateMap(), SetOptions(merge: true));
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _users.doc(uid).delete();
    await _auth.currentUser?.delete();
  }

  @override
  Future<void> registerDevice(String uid, String fcmToken) async {
    await _users.doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([fcmToken]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
