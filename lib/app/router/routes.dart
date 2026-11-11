abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const home = '/home';
  static const explore = '/explore';
  static const publish = '/publish';
  static const messages = '/messages';
  static const profile = '/me';

  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authSetupProfile = '/auth/profile';

  static const search = '/search';
  static String category(String id) => '/category/$id';
  static String providerProfile(String id) => '/p/$id';
  static String listingDetail(String id) => '/l/$id';
  static String providerReviews(String id) => '/p/$id/reviews';
  static String writeReview(String id) => '/p/$id/review';

  static const providerOnboarding = '/provider/onboarding';
  static const providerDashboard = '/provider/dashboard';
  static const providerNewListing = '/provider/listings/new';
  static String editListing(String id) => '/provider/listings/$id/edit';
  static const providerVerification = '/provider/verification';

  static const myFavorites = '/me/favorites';
  static const mySettings = '/me/settings';
  static const myLanguage = '/me/language';
  static const deleteAccount = '/me/delete';

  static const legalTerms = '/legal/terms';
  static const legalPrivacy = '/legal/privacy';
  static const help = '/help';
  static const updateRequired = '/update-required';
  static const maintenance = '/maintenance';

  // Dev-only
  static const devComponents = '/dev/components';
}
