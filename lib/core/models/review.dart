import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'timestamp_converter.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String authorUid,
    required String authorName,
    String? authorPhotoUrl,
    required int rating,
    @Default('') String text,
    String? providerReply,
    @TimestampConverter() DateTime? providerReplyAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}

extension ReviewWrite on Review {
  Map<String, dynamic> toCreateMap() => {
        'authorUid': authorUid,
        'authorName': authorName,
        if (authorPhotoUrl != null) 'authorPhotoUrl': authorPhotoUrl,
        'rating': rating,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
        'rating': rating,
        'text': text,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
