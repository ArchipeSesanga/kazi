import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/env.dart';
import '../../../core/models/app_user.dart';
import '../domain/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._db, this._auth, [FirebaseFunctions? functions])
      : _functionsOverride = functions;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions? _functionsOverride;

  // Resolved lazily so tests that never delete an account need no Firebase app.
  FirebaseFunctions get _functions =>
      _functionsOverride ??
      FirebaseFunctions.instanceFor(region: Env.functionsRegion);

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
    if (_auth.currentUser == null) return;
    try {
      await _functions.httpsCallable('deleteAccount').call<void>();
    } on FirebaseFunctionsException catch (e) {
      throw DeleteAccountFailure(switch (e.code) {
        'failed-precondition' => DeleteAccountFailureReason.recentLoginRequired,
        'permission-denied' => DeleteAccountFailureReason.notVerified,
        _ => DeleteAccountFailureReason.failed,
      });
    }
    // The Auth user no longer exists on the server; clear the local session.
    await _auth.signOut();
  }

  @override
  Future<void> registerDevice(String uid, String fcmToken) async {
    await _users.doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([fcmToken]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
