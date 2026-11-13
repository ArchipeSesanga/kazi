import '../../../core/models/contact_record.dart';

export '../../../core/models/contact_record.dart';

abstract interface class ContactRepository {
  /// Set-with-merge on contacts/{uid}_{pid}.
  Future<void> record(ContactRecord contact);
  Stream<List<ContactRecord>> watchMine(String uid);
  Future<bool> hasContacted(String uid, String providerId);
}
