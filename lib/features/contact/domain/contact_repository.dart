abstract interface class ContactRepository {
  Future<void> record(ContactDraft draft);
  Stream<List<ContactRecord>> watchContacts(String clientUid);

  /// Whether [clientUid] has already contacted [providerId] (the document
  /// `contacts/{clientUid}_{providerId}` exists). The security rules require it
  /// before a review can be written.
  Future<bool> hasContacted(String clientUid, String providerId);
}

class ContactDraft {
  const ContactDraft({
    required this.clientUid,
    required this.providerId,
    required this.providerName,
    this.providerPhotoUrl,
    this.listingId,
    required this.channel,
    this.providerVerified = false,
    required this.whatsappNumber,
    this.callNumber,
  });

  final String clientUid;
  final String providerId;
  final String providerName;
  final String? providerPhotoUrl;
  final String? listingId;

  /// 'whatsapp' or 'call'
  final String channel;
  final bool providerVerified;
  final String whatsappNumber;
  final String? callNumber;
}

class ContactRecord {
  const ContactRecord({
    required this.clientUid,
    required this.providerId,
    required this.providerName,
    this.providerPhotoUrl,
    this.listingId,
    required this.channel,
    required this.providerVerified,
    required this.whatsappNumber,
    this.callNumber,
    required this.lastAt,
  });

  final String clientUid;
  final String providerId;
  final String providerName;
  final String? providerPhotoUrl;
  final String? listingId;
  final String channel;
  final bool providerVerified;
  final String whatsappNumber;
  final String? callNumber;
  final DateTime lastAt;
}
