// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderHeadline _$ProviderHeadlineFromJson(Map<String, dynamic> json) =>
    _ProviderHeadline(
      categoryId: json['categoryId'] as String?,
      fromAmount: (json['fromAmount'] as num?)?.toDouble(),
      fromCurrency: json['fromCurrency'] as String?,
      fromPriceType: json['fromPriceType'] as String?,
    );

Map<String, dynamic> _$ProviderHeadlineToJson(_ProviderHeadline instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'fromAmount': instance.fromAmount,
      'fromCurrency': instance.fromCurrency,
      'fromPriceType': instance.fromPriceType,
    };

_ProviderStats _$ProviderStatsFromJson(Map<String, dynamic> json) =>
    _ProviderStats(
      contactsTotal: (json['contactsTotal'] as num?)?.toInt() ?? 0,
      contactsByMonth:
          (json['contactsByMonth'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ProviderStatsToJson(_ProviderStats instance) =>
    <String, dynamic>{
      'contactsTotal': instance.contactsTotal,
      'contactsByMonth': instance.contactsByMonth,
    };

_PortfolioPhoto _$PortfolioPhotoFromJson(Map<String, dynamic> json) =>
    _PortfolioPhoto(
      id: json['id'] as String,
      path: json['path'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$PortfolioPhotoToJson(_PortfolioPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'url': instance.url,
    };

_ProviderProfile _$ProviderProfileFromJson(Map<String, dynamic> json) =>
    _ProviderProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      city: json['city'] as String? ?? 'kinshasa',
      baseCommune: json['baseCommune'] as String,
      communes:
          (json['communes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      whatsappNumber: json['whatsappNumber'] as String,
      callNumber: json['callNumber'] as String?,
      yearsExperience: (json['yearsExperience'] as num?)?.toInt() ?? 0,
      portfolio:
          (json['portfolio'] as List<dynamic>?)
              ?.map((e) => PortfolioPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status:
          $enumDecodeNullable(_$ProviderStatusEnumMap, json['status']) ??
          ProviderStatus.pending,
      statusReason: json['statusReason'] as String?,
      verified: json['verified'] as bool? ?? false,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      ratingSum: (json['ratingSum'] as num?)?.toInt() ?? 0,
      listingCount: (json['listingCount'] as num?)?.toInt() ?? 0,
      headline: json['headline'] == null
          ? null
          : ProviderHeadline.fromJson(json['headline'] as Map<String, dynamic>),
      stats: json['stats'] == null
          ? null
          : ProviderStats.fromJson(json['stats'] as Map<String, dynamic>),
      searchKeywords:
          (json['searchKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      approvedAt: const TimestampConverter().fromJson(json['approvedAt']),
    );

Map<String, dynamic> _$ProviderProfileToJson(_ProviderProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'bio': instance.bio,
      'photoUrl': instance.photoUrl,
      'coverUrl': instance.coverUrl,
      'categoryIds': instance.categoryIds,
      'city': instance.city,
      'baseCommune': instance.baseCommune,
      'communes': instance.communes,
      'whatsappNumber': instance.whatsappNumber,
      'callNumber': instance.callNumber,
      'yearsExperience': instance.yearsExperience,
      'portfolio': instance.portfolio,
      'status': _$ProviderStatusEnumMap[instance.status]!,
      'statusReason': instance.statusReason,
      'verified': instance.verified,
      'ratingAvg': instance.ratingAvg,
      'ratingCount': instance.ratingCount,
      'ratingSum': instance.ratingSum,
      'listingCount': instance.listingCount,
      'headline': instance.headline,
      'stats': instance.stats,
      'searchKeywords': instance.searchKeywords,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'approvedAt': const TimestampConverter().toJson(instance.approvedAt),
    };

const _$ProviderStatusEnumMap = {
  ProviderStatus.pending: 'pending',
  ProviderStatus.approved: 'approved',
  ProviderStatus.rejected: 'rejected',
  ProviderStatus.suspended: 'suspended',
};
