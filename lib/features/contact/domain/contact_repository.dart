abstract interface class ContactRepository {
  Future<void> record(ContactDraft draft);
}

class ContactDraft {
  const ContactDraft({
    required this.clientUid,
    required this.providerId,
    required this.providerName,
    this.providerPhotoUrl,
    this.listingId,
    required this.channel,
  });

  final String clientUid;
  final String providerId;
  final String providerName;
  final String? providerPhotoUrl;
  final String? listingId;

  /// 'whatsapp' or 'call'
  final String channel;
}
