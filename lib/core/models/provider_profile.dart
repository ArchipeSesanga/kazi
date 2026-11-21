import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/phone.dart';
import 'enums.dart';
import 'timestamp_converter.dart';

part 'provider_profile.freezed.dart';
part 'provider_profile.g.dart';

@freezed
abstract class ProviderHeadline with _$ProviderHeadline {
  const factory ProviderHeadline({
    String? categoryId,
    double? fromAmount,
    String? fromCurrency,
    String? fromPriceType,
  }) = _ProviderHeadline;

  factory ProviderHeadline.fromJson(Map<String, dynamic> json) =>
      _$ProviderHeadlineFromJson(json);
}

@freezed
abstract class ProviderStats with _$ProviderStats {
  const factory ProviderStats({
    @Default(0) int contactsTotal,
    @Default({}) Map<String, int> contactsByMonth,
  }) = _ProviderStats;

  factory ProviderStats.fromJson(Map<String, dynamic> json) =>
      _$ProviderStatsFromJson(json);
}

@freezed
abstract class PortfolioPhoto with _$PortfolioPhoto {
  const factory PortfolioPhoto({
    required String id,
    required String path,
    required String url,
  }) = _PortfolioPhoto;

  factory PortfolioPhoto.fromJson(Map<String, dynamic> json) =>
      _$PortfolioPhotoFromJson(json);
}

@freezed
abstract class ProviderProfile with _$ProviderProfile {
  const factory ProviderProfile({
    required String uid,
    required String displayName,
    @Default('') String bio,
    String? photoUrl,
    String? coverUrl,
    @Default([]) List<String> categoryIds,
    @Default('kinshasa') String city,
    required String baseCommune,
    @Default([]) List<String> communes,
    required String whatsappNumber,
    String? callNumber,
    @Default(0) int yearsExperience,
    @Default([]) List<PortfolioPhoto> portfolio,
    @Default(ProviderStatus.pending) ProviderStatus status,
    String? statusReason,
    @Default(false) bool verified,
    @Default(0.0) double ratingAvg,
    @Default(0) int ratingCount,
    @Default(0) int ratingSum,
    @Default(0) int listingCount,
    ProviderHeadline? headline,
    ProviderStats? stats,
    @Default([]) List<String> searchKeywords,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? approvedAt,
  }) = _ProviderProfile;

  factory ProviderProfile.fromJson(Map<String, dynamic> json) =>
      _$ProviderProfileFromJson(json);
}

extension ProviderProfileWrite on ProviderProfile {
  /// Create payload: client fields + zeroed server fields per TDD §4.4.
  Map<String, dynamic> toCreateMap() => {
    'displayName': displayName,
    'bio': bio,
    'photoUrl': _optionalUrl(photoUrl),
    'coverUrl': _optionalUrl(coverUrl),
    'categoryIds': categoryIds,
    'city': city,
    'baseCommune': baseCommune,
    'communes': <String>{baseCommune, ...communes}.toList(),
    'whatsappNumber': _normalisePhone(whatsappNumber),
    'callNumber': callNumber == null || callNumber!.trim().isEmpty
        ? null
        : _normalisePhone(callNumber!),
    'yearsExperience': yearsExperience,
    'portfolio': portfolio.map((p) => p.toJson()).toList(),
    // Server fields must be sent with initial values on create:
    'status': 'pending',
    'verified': false,
    'ratingAvg': 0,
    'ratingCount': 0,
    'ratingSum': 0,
    'listingCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Update payload: only mutable client fields.
  Map<String, dynamic> toUpdateMap() => {
    'displayName': displayName,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (coverUrl != null) 'coverUrl': coverUrl,
    'bio': bio,
    'categoryIds': categoryIds,
    'baseCommune': baseCommune,
    'communes': communes,
    'whatsappNumber': whatsappNumber,
    if (callNumber != null) 'callNumber': callNumber,
    'yearsExperience': yearsExperience,
    'portfolio': portfolio.map((p) => p.toJson()).toList(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

String? _optionalUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return trimmed;
}

String _normalisePhone(String value) =>
    PhoneUtils.toE164(value) ?? value.trim();
