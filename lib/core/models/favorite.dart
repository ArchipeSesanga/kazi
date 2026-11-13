import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'timestamp_converter.dart';

part 'favorite.freezed.dart';
part 'favorite.g.dart';

@freezed
abstract class Favorite with _$Favorite {
  const factory Favorite({
    required String providerId,
    required String displayName,
    String? photoUrl,
    String? headline,
    @TimestampConverter() DateTime? createdAt,
  }) = _Favorite;

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);
}

extension FavoriteWrite on Favorite {
  Map<String, dynamic> toCreateMap() => {
        'providerId': providerId,
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (headline != null) 'headline': headline,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
