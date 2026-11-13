// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  authorUid: json['authorUid'] as String,
  authorName: json['authorName'] as String,
  authorPhotoUrl: json['authorPhotoUrl'] as String?,
  rating: (json['rating'] as num).toInt(),
  text: json['text'] as String? ?? '',
  providerReply: json['providerReply'] as String?,
  providerReplyAt: const TimestampConverter().fromJson(json['providerReplyAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'authorUid': instance.authorUid,
  'authorName': instance.authorName,
  'authorPhotoUrl': instance.authorPhotoUrl,
  'rating': instance.rating,
  'text': instance.text,
  'providerReply': instance.providerReply,
  'providerReplyAt': const TimestampConverter().toJson(
    instance.providerReplyAt,
  ),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
