import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/error_mapper.dart';
import '../domain/contact_repository.dart';

class FirestoreContactRepository implements ContactRepository {
  const FirestoreContactRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Future<void> record(ContactDraft draft) async {
    try {
      final docId = '${draft.clientUid}_${draft.providerId}';
      final ref = _db.collection('contacts').doc(docId);
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = <String, dynamic>{
          'clientUid': draft.clientUid,
          'providerId': draft.providerId,
          'providerName': draft.providerName,
          if (draft.providerPhotoUrl != null)
            'providerPhotoUrl': draft.providerPhotoUrl,
          if (draft.listingId != null) 'listingId': draft.listingId,
          'channel': draft.channel,
          'providerVerified': draft.providerVerified,
          'whatsappNumber': draft.whatsappNumber,
          if (draft.callNumber != null) 'callNumber': draft.callNumber,
          'lastAt': FieldValue.serverTimestamp(),
          if (!snap.exists) 'firstAt': FieldValue.serverTimestamp(),
        };
        tx.set(ref, data, SetOptions(merge: true));
      });
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Future<bool> hasContacted(String clientUid, String providerId) async {
    try {
      final snap = await _db
          .collection('contacts')
          .doc('${clientUid}_$providerId')
          .get();
      return snap.exists;
    } catch (e, s) {
      throw mapException(e, s);
    }
  }

  @override
  Stream<List<ContactRecord>> watchContacts(String clientUid) {
    return _db
        .collection('contacts')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('lastAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_recordFromSnap).toList())
        .handleError((Object e, StackTrace s) => throw mapException(e, s));
  }

  ContactRecord _recordFromSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    return ContactRecord(
      clientUid: d['clientUid'] as String,
      providerId: d['providerId'] as String,
      providerName: d['providerName'] as String,
      providerPhotoUrl: d['providerPhotoUrl'] as String?,
      listingId: d['listingId'] as String?,
      channel: d['channel'] as String,
      providerVerified: (d['providerVerified'] as bool?) ?? false,
      whatsappNumber: (d['whatsappNumber'] as String?) ?? '',
      callNumber: d['callNumber'] as String?,
      lastAt: (d['lastAt'] as Timestamp).toDate(),
    );
  }
}
