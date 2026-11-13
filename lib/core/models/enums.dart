import 'package:json_annotation/json_annotation.dart';

enum UserStatus {
  @JsonValue('active') active,
  @JsonValue('suspended') suspended,
  @JsonValue('deleting') deleting,
}

enum ProviderStatus {
  @JsonValue('pending') pending,
  @JsonValue('approved') approved,
  @JsonValue('rejected') rejected,
  @JsonValue('suspended') suspended,
}

enum ListingStatus {
  @JsonValue('draft') draft,
  @JsonValue('active') active,
  @JsonValue('paused') paused,
}

enum PriceType {
  @JsonValue('fixed') fixed,
  @JsonValue('from') from,
  @JsonValue('quote') quote,
}

enum Currency {
  @JsonValue('USD') usd,
  @JsonValue('CDF') cdf,
}

enum Moderation {
  @JsonValue('ok') ok,
  @JsonValue('hidden') hidden,
}

enum ReportTargetType {
  @JsonValue('listing') listing,
  @JsonValue('provider') provider,
  @JsonValue('review') review,
}

enum ReportReason {
  @JsonValue('scam') scam,
  @JsonValue('inappropriate') inappropriate,
  @JsonValue('fake') fake,
  @JsonValue('wrong_category') wrongCategory,
  @JsonValue('other') other,
}

enum ReportStatus {
  @JsonValue('open') open,
  @JsonValue('dismissed') dismissed,
  @JsonValue('actioned') actioned,
}

enum VerificationStatus {
  @JsonValue('pending') pending,
  @JsonValue('approved') approved,
  @JsonValue('rejected') rejected,
}

enum ContactChannel {
  @JsonValue('whatsapp') whatsapp,
  @JsonValue('call') call,
}
