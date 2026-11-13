import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'timestamp_converter.dart';

part 'contact_record.freezed.dart';
part 'contact_record.g.dart';

@freezed
abstract class ContactRecord with _$ContactRecord {
  const factory ContactRecord({
    required String clientUid,
    required String providerId,
    required String providerName,
    String? providerPhotoUrl,
    String? listingId,
    required ContactChannel channel,
    @TimestampConverter() DateTime? firstAt,
    @TimestampConverter() DateTime? lastAt,
  }) = _ContactRecord;

  factory ContactRecord.fromJson(Map<String, dynamic> json) =>
      _$ContactRecordFromJson(json);
}

extension ContactRecordWrite on ContactRecord {
  Map<String, dynamic> toCreateMap() => {
        'clientUid': clientUid,
        'providerId': providerId,
        'providerName': providerName,
        if (providerPhotoUrl != null) 'providerPhotoUrl': providerPhotoUrl,
        if (listingId != null) 'listingId': listingId,
        'channel': channel.name,
        'firstAt': FieldValue.serverTimestamp(),
        'lastAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'providerName': providerName,
        if (providerPhotoUrl != null) 'providerPhotoUrl': providerPhotoUrl,
        if (listingId != null) 'listingId': listingId,
        'channel': channel.name,
        'lastAt': FieldValue.serverTimestamp(),
      };
}
