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
          if (draft.providerPhotoUrl != null) 'providerPhotoUrl': draft.providerPhotoUrl,
          if (draft.listingId != null) 'listingId': draft.listingId,
          'channel': draft.channel,
          'lastAt': FieldValue.serverTimestamp(),
          if (!snap.exists) 'firstAt': FieldValue.serverTimestamp(),
        };
        tx.set(ref, data, SetOptions(merge: true));
      });
    } catch (e, s) {
      throw mapException(e, s);
    }
  }
}
