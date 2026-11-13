import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService() : _analytics = FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logSearch({
    String? keyword,
    String? categoryId,
    String? commune,
  }) =>
      _analytics.logEvent(name: 'search', parameters: {
        if (keyword != null) 'keyword': keyword,
        if (categoryId != null) 'category_id': categoryId,
        if (commune != null) 'commune': commune,
      });

  @override
  Future<void> logViewProvider(String providerId) =>
      _analytics.logEvent(
        name: 'view_provider',
        parameters: {'provider_id': providerId},
      );

  @override
  Future<void> logViewListing(String listingId) =>
      _analytics.logEvent(
        name: 'view_listing',
        parameters: {'listing_id': listingId},
      );

  @override
  Future<void> logContactProvider({
    required String providerId,
    required String channel,
    String? listingId,
  }) =>
      _analytics.logEvent(name: 'contact_provider', parameters: {
        'provider_id': providerId,
        'channel': channel,
        if (listingId != null) 'listing_id': listingId,
      });

  @override
  Future<void> logAddFavorite(String providerId) =>
      _analytics.logEvent(
        name: 'add_favorite',
        parameters: {'provider_id': providerId},
      );

  @override
  Future<void> logRemoveFavorite(String providerId) =>
      _analytics.logEvent(
        name: 'remove_favorite',
        parameters: {'provider_id': providerId},
      );

  @override
  Future<void> logSubmitReview(String providerId) =>
      _analytics.logEvent(
        name: 'submit_review',
        parameters: {'provider_id': providerId},
      );

  @override
  Future<void> logSubmitReport({
    required String targetType,
    required String targetKey,
  }) =>
      _analytics.logEvent(name: 'submit_report', parameters: {
        'target_type': targetType,
        'target_key': targetKey,
      });

  @override
  Future<void> logSignIn() => _analytics.logLogin(loginMethod: 'phone');

  @override
  Future<void> logSignOut() =>
      _analytics.logEvent(name: 'sign_out');

  @override
  Future<void> setUserId(String? uid) => _analytics.setUserId(id: uid);
}
