import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/state/paged_state.dart';
import '../../../core/utils/phone.dart';
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
    return _col
        .doc(id)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ProviderProfile.fromJson({...doc.data()!, 'uid': doc.id});
        })
        .handleError((Object e, StackTrace s) => throw mapException(e, s));
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
        items = items.where((p) => p.communes.contains(commune)).toList();
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
      final payload = profile.toCreateMap();
      _logCreatePayload(payload, profile.uid);

      final user = await _db
          .collection('users')
          .doc(profile.uid)
          .get(const GetOptions(source: Source.server));
      final userStatus = user.data()?['status'];
      debugPrint(
        '[ProviderRepo] createProvider userExists=${user.exists} '
        'userStatus=$userStatus',
      );
      if (!user.exists || userStatus != 'active') {
        debugPrint(
          '[ProviderRepo] createProvider condition failed: '
          'users/${profile.uid} must exist with status active',
        );
        throw const PermissionDeniedException('provider-user-not-active');
      }

      if (!PhoneUtils.isValidE164(payload['whatsappNumber'] as String)) {
        debugPrint(
          '[ProviderRepo] payload condition failed: whatsappNumber E.164',
        );
        throw const InvalidInputException('provider-whatsapp-not-e164');
      }
      final callNumber = payload['callNumber'];
      if (callNumber != null && !PhoneUtils.isValidE164(callNumber as String)) {
        debugPrint('[ProviderRepo] payload condition failed: callNumber E.164');
        throw const InvalidInputException('provider-call-not-e164');
      }

      await _col.doc(profile.uid).set(payload);
      // Firestore resolves set() optimistically from local cache.
      // Wait for the server to confirm, then verify the doc persisted.
      await _db.waitForPendingWrites().timeout(const Duration(seconds: 10));
      final doc = await _col
          .doc(profile.uid)
          .get(const GetOptions(source: Source.server));
      if (!doc.exists) {
        debugPrint('[ProviderRepo] createProvider: server rejected write');
        throw const PermissionDeniedException();
      }
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  void _logCreatePayload(Map<String, dynamic> payload, String uid) {
    if (!kDebugMode) return;
    debugPrint('[ProviderRepo] createProvider path=providers/$uid');
    for (final entry in payload.entries) {
      debugPrint(
        '[ProviderRepo] payload.${entry.key}=${entry.value} '
        'runtimeType=${entry.value.runtimeType}',
      );
    }

    const expectedKeys = {
      'displayName',
      'bio',
      'photoUrl',
      'coverUrl',
      'categoryIds',
      'city',
      'baseCommune',
      'communes',
      'whatsappNumber',
      'callNumber',
      'yearsExperience',
      'portfolio',
      'status',
      'verified',
      'ratingAvg',
      'ratingCount',
      'ratingSum',
      'listingCount',
      'createdAt',
      'updatedAt',
    };
    final communes = payload['communes'];
    final photoUrl = payload['photoUrl'];
    final coverUrl = payload['coverUrl'];
    debugPrint(
      '[ProviderRepo] payloadChecks '
      'exactKeys=${payload.keys.toSet().containsAll(expectedKeys) && payload.keys.toSet().difference(expectedKeys).isEmpty} '
      'yearsExperienceIsInt=${payload['yearsExperience'] is int} '
      'whatsappE164=${PhoneUtils.isValidE164(payload['whatsappNumber'] as String)} '
      'callNumberE164=${payload['callNumber'] == null || PhoneUtils.isValidE164(payload['callNumber'] as String)} '
      'baseCommuneIncluded=${communes is List && communes.contains(payload['baseCommune'])} '
      'photoUrlValid=${photoUrl == null || _isFullUrl(photoUrl)} '
      'coverUrlValid=${coverUrl == null || _isFullUrl(coverUrl)}',
    );
  }

  bool _isFullUrl(Object? value) {
    if (value is! String || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
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
