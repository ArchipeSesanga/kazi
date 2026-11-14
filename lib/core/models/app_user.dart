import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../config/app_defaults.dart';
import 'enums.dart';
import 'timestamp_converter.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String displayName,
    String? photoUrl,
    @Default('') String phone,
    @Default('fr') String locale,
    @Default('kinshasa') String city,
    String? commune,
    String? termsVersion,
    @TimestampConverter() DateTime? termsAcceptedAt,
    @Default(false) bool isProvider,
    @Default(UserStatus.active) UserStatus status,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}

extension AppUserWrite on AppUser {
  /// Fields the client may send on account creation.
  Map<String, dynamic> toCreateMap() => {
        'displayName': displayName,
        'phone': phone,
        'locale': locale,
        'city': city,
        if (commune != null) 'commune': commune,
        // termsVersion and termsAcceptedAt are required by security rules.
        // isNow('termsAcceptedAt') requires FieldValue.serverTimestamp().
        'termsVersion': termsVersion ?? AppDefaults.termsVersion,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Fields the client may send on profile update.
  Map<String, dynamic> toUpdateMap() => {
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'locale': locale,
        'city': city,
        if (commune != null) 'commune': commune,
        if (termsVersion != null) 'termsVersion': termsVersion,
        if (termsAcceptedAt != null)
          'termsAcceptedAt': Timestamp.fromDate(termsAcceptedAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
