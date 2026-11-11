// All Firestore collection / document paths. No string literals in repositories.
abstract final class FirestorePaths {
  static const String users = 'users';
  static String user(String uid) => 'users/$uid';
  static String userFavorites(String uid) => 'users/$uid/favorites';
  static String userFavorite(String uid, String providerId) =>
      'users/$uid/favorites/$providerId';
  static String userBlocks(String uid) => 'users/$uid/blocks';
  static String userDevices(String uid) => 'users/$uid/devices';

  static const String providers = 'providers';
  static String provider(String uid) => 'providers/$uid';
  static String providerReviews(String providerId) =>
      'providers/$providerId/reviews';
  static String providerReview(String providerId, String reviewerUid) =>
      'providers/$providerId/reviews/$reviewerUid';

  static const String listings = 'listings';
  static String listing(String id) => 'listings/$id';

  static const String contacts = 'contacts';
  static String contact(String clientUid, String providerId) =>
      'contacts/${clientUid}_$providerId';

  static const String reports = 'reports';

  static const String verificationRequests = 'verificationRequests';
  static String verificationRequest(String uid) => 'verificationRequests/$uid';

  static const String categories = 'categories';
  static const String configLocations = 'config/locations';

  static const String adminLogs = 'adminLogs';
}
