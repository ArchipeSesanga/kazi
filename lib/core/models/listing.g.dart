// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingPhoto _$ListingPhotoFromJson(Map<String, dynamic> json) =>
    _ListingPhoto(
      id: json['id'] as String,
      path: json['path'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ListingPhotoToJson(_ListingPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'url': instance.url,
    };

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  providerId: json['providerId'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  categoryId: json['categoryId'] as String,
  priceType: $enumDecode(_$PriceTypeEnumMap, json['priceType']),
  priceAmount: (json['priceAmount'] as num?)?.toDouble(),
  currency:
      $enumDecodeNullable(_$CurrencyEnumMap, json['currency']) ?? Currency.usd,
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => ListingPhoto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  city: json['city'] as String,
  communes:
      (json['communes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ListingStatusEnumMap, json['status']) ??
      ListingStatus.draft,
  visible: json['visible'] as bool? ?? false,
  moderation:
      $enumDecodeNullable(_$ModerationEnumMap, json['moderation']) ??
      Moderation.ok,
  moderationReason: json['moderationReason'] as String?,
  providerStatus: json['providerStatus'] as String?,
  providerName: json['providerName'] as String?,
  providerPhotoUrl: json['providerPhotoUrl'] as String?,
  providerVerified: json['providerVerified'] as bool? ?? false,
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  categoryName: json['categoryName'] == null
      ? null
      : LocalizedText.fromJson(json['categoryName'] as Map<String, dynamic>),
  searchKeywords:
      (json['searchKeywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  contactCount: (json['contactCount'] as num?)?.toInt() ?? 0,
  publishedAt: const TimestampConverter().fromJson(json['publishedAt']),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'providerId': instance.providerId,
  'title': instance.title,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'priceType': _$PriceTypeEnumMap[instance.priceType]!,
  'priceAmount': instance.priceAmount,
  'currency': _$CurrencyEnumMap[instance.currency]!,
  'photos': instance.photos,
  'city': instance.city,
  'communes': instance.communes,
  'status': _$ListingStatusEnumMap[instance.status]!,
  'visible': instance.visible,
  'moderation': _$ModerationEnumMap[instance.moderation]!,
  'moderationReason': instance.moderationReason,
  'providerStatus': instance.providerStatus,
  'providerName': instance.providerName,
  'providerPhotoUrl': instance.providerPhotoUrl,
  'providerVerified': instance.providerVerified,
  'ratingAvg': instance.ratingAvg,
  'ratingCount': instance.ratingCount,
  'categoryName': instance.categoryName,
  'searchKeywords': instance.searchKeywords,
  'contactCount': instance.contactCount,
  'publishedAt': const TimestampConverter().toJson(instance.publishedAt),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$PriceTypeEnumMap = {
  PriceType.fixed: 'fixed',
  PriceType.from: 'from',
  PriceType.quote: 'quote',
};

const _$CurrencyEnumMap = {Currency.usd: 'USD', Currency.cdf: 'CDF'};

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.active: 'active',
  ListingStatus.paused: 'paused',
};

const _$ModerationEnumMap = {Moderation.ok: 'ok', Moderation.hidden: 'hidden'};
