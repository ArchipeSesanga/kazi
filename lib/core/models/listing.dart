import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'localized_text.dart';
import 'timestamp_converter.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

@freezed
abstract class ListingPhoto with _$ListingPhoto {
  const factory ListingPhoto({
    required String id,
    required String path,
    required String url,
  }) = _ListingPhoto;

  factory ListingPhoto.fromJson(Map<String, dynamic> json) =>
      _$ListingPhotoFromJson(json);
}

@freezed
abstract class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String providerId,
    required String title,
    @Default('') String description,
    required String categoryId,
    required PriceType priceType,
    double? priceAmount,
    @Default(Currency.usd) Currency currency,
    @Default([]) List<ListingPhoto> photos,
    required String city,
    @Default([]) List<String> communes,
    @Default(ListingStatus.draft) ListingStatus status,
    @Default(false) bool visible,
    @Default(Moderation.ok) Moderation moderation,
    String? moderationReason,
    String? providerStatus,
    String? providerName,
    String? providerPhotoUrl,
    @Default(false) bool providerVerified,
    @Default(0.0) double ratingAvg,
    @Default(0) int ratingCount,
    LocalizedText? categoryName,
    @Default([]) List<String> searchKeywords,
    @Default(0) int contactCount,
    @TimestampConverter() DateTime? publishedAt,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}

extension ListingWrite on Listing {
  Map<String, dynamic> toCreateMap() => {
        'providerId': providerId,
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'priceType': priceType.name,
        if (priceAmount != null) 'priceAmount': priceAmount,
        'currency': currency == Currency.usd ? 'USD' : 'CDF',
        'photos': [],
        'city': city,
        'communes': communes,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, dynamic> toUpdateMap() => {
    'title': title,
    'description': description,
    'categoryId': categoryId,
    'priceType': priceType.name,
    if (priceAmount != null) 'priceAmount': priceAmount,
    'currency': currency == Currency.usd ? 'USD' : 'CDF',
    'photos': photos.map((p) => p.toJson()).toList(),
    'communes': communes,
    'status': status.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// Moderation reason written by `onListingWritten` when a provider is over
/// `config/limits.maxListingsPerProvider` (TDD §4.6).
const kOverLimitReason = 'over_limit';

extension ListingOverLimit on Listing {
  bool get isOverLimit =>
      moderation == Moderation.hidden && moderationReason == kOverLimitReason;

  /// Counts toward the limit: active or paused, and not hidden for the limit.
  bool get countsTowardLimit =>
      (status == ListingStatus.active || status == ListingStatus.paused) &&
      !isOverLimit;
}
