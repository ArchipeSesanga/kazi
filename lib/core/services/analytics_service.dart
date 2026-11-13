/// Event names follow lower_snake_case. No PII — IDs only (TDD §9.11).
abstract interface class AnalyticsService {
  Future<void> logSearch({String? keyword, String? categoryId, String? commune});
  Future<void> logViewProvider(String providerId);
  Future<void> logViewListing(String listingId);
  Future<void> logContactProvider({
    required String providerId,
    required String channel,
    String? listingId,
  });
  Future<void> logAddFavorite(String providerId);
  Future<void> logRemoveFavorite(String providerId);
  Future<void> logSubmitReview(String providerId);
  Future<void> logSubmitReport({required String targetType, required String targetKey});
  Future<void> logSignIn();
  Future<void> logSignOut();
  Future<void> setUserId(String? uid);
}
