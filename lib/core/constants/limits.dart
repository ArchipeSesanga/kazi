// Single source of truth for all app limits — mirrors functions/src/config.ts.
abstract final class Limits {
  static const int maxListingsPerProvider = 10;
  static const int maxPhotosPerListing = 6;
  static const int maxPortfolioPhotos = 12;
  static const int maxCategoriesPerProvider = 3;
  static const int maxCommunesServed = 10;
  static const int maxBioChars = 600;
  static const int maxListingTitleChars = 80;
  static const int minListingTitleChars = 4;
  static const int maxListingDescriptionChars = 1000;
  static const int maxReviewTextChars = 500;
  static const int maxReportDetailsChars = 500;
  static const int maxUploadSizeMb = 2;
  static const int maxPrivateUploadSizeMb = 5;
  static const int otpResendCooldownSeconds = 60;
  static const int autoHideReportThreshold = 3;
  static const int contactCountCooldownMinutes = 10;
  static const int pageSize = 20;
  static const int searchKeywordsPrefixMinLength = 2;
  static const int searchKeywordsPrefixMaxLength = 15;
  static const int maxSearchKeywords = 200;
  static const int maxRecentLocalSearches = 10;
}
