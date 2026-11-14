// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kazi';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonSeeAll => 'See all';

  @override
  String get buttonShare => 'Share';

  @override
  String get buttonSignOut => 'Sign out';

  @override
  String get errorNetwork => 'Cannot connect. Check your connection.';

  @override
  String get errorPermissionDenied => 'Access denied.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorInvalidInput =>
      'Invalid data. Please check the information entered.';

  @override
  String get errorRateLimited => 'Too many attempts. Please wait.';

  @override
  String get errorOtpInvalid => 'Incorrect code. Check and try again.';

  @override
  String get errorOtpExpired => 'Code expired. Request a new code.';

  @override
  String get errorTooManyRequests => 'Too many requests. Try again later.';

  @override
  String get errorQuotaExceeded => 'Quota reached. Try again later.';

  @override
  String get errorUnauthenticated => 'You must be signed in to continue.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get offlineBanner => 'Offline — showing cached data';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navPublish => 'Publish';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Me';

  @override
  String get welcomeTitle => 'Welcome to Kazi';

  @override
  String get welcomeSubtitle => 'Find the best service providers near you';

  @override
  String get welcomeSlide1Title => 'Find a provider';

  @override
  String get welcomeSlide1Body =>
      'Plumbers, electricians, hairdressers… Find the right professional in seconds.';

  @override
  String get welcomeSlide2Title => 'Contact via WhatsApp';

  @override
  String get welcomeSlide2Body =>
      'One tap and you\'re in direct contact. No middleman.';

  @override
  String get welcomeSlide3Title => 'Offer your services';

  @override
  String get welcomeSlide3Body =>
      'Post your listings for free and reach thousands of clients in Kinshasa.';

  @override
  String get welcomeStart => 'Get started';

  @override
  String get welcomeLanguageTitle => 'Choose your language';

  @override
  String get welcomeSkip => 'Skip';

  @override
  String get authPhoneTitle => 'Enter your number';

  @override
  String get authPhoneSubtitle => 'We\'ll send you a confirmation code.';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '081 234 5678';

  @override
  String get authPhoneSend => 'Send code';

  @override
  String get authPhoneTermsPrefix => 'By continuing, you agree to our ';

  @override
  String get authPhoneTermsLink => 'Terms of Use';

  @override
  String get authPhoneTermsAnd => ' and our ';

  @override
  String get authPhonePrivacyLink => 'Privacy Policy';

  @override
  String get authPhoneTermsError => 'Please accept the terms to continue.';

  @override
  String get authPhoneInvalid => 'Invalid number. Check and try again.';

  @override
  String get authOtpTitle => 'Enter the code';

  @override
  String authOtpSubtitle(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String authOtpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authOtpResend => 'Resend code';

  @override
  String get authOtpChangeNumber => 'Change number';

  @override
  String get authProfileTitle => 'Create your profile';

  @override
  String get authProfileNameLabel => 'Your name';

  @override
  String get authProfileNameHint => 'E.g. Jean Mukendi';

  @override
  String get authProfileCommuneLabel => 'Your commune';

  @override
  String get authProfileCommuneHint => 'Choose your commune';

  @override
  String get authProfilePhotoAdd => 'Add a photo';

  @override
  String get authProfileSave => 'Save my profile';

  @override
  String get authEmailTitle => 'Sign in with email';

  @override
  String get authEmailSubtitle => 'Enter your email and password.';

  @override
  String get authEmailLabel => 'Email address';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'At least 6 characters';

  @override
  String get authEmailSignIn => 'Sign in';

  @override
  String get authEmailRegister => 'Create account';

  @override
  String get authEmailCreateAccountPrompt => 'No account yet?';

  @override
  String get authEmailHasAccountPrompt => 'Already have an account?';

  @override
  String get authEmailForgotPassword => 'Forgot password?';

  @override
  String get authEmailResetSent => 'Password reset email sent.';

  @override
  String get authEmailUsePhone => 'Sign in with phone';

  @override
  String get authPhoneUseEmail => 'Sign in with email';

  @override
  String get authEmailInUse => 'This email is already in use.';

  @override
  String get authWeakPassword => 'Password too short (6+ characters).';

  @override
  String get authUserNotFound => 'No account found for this email.';

  @override
  String get authWrongPassword => 'Incorrect email or password.';

  @override
  String get authEmailInvalid => 'Invalid email address.';

  @override
  String get homeSearchHint => 'Search for a service…';

  @override
  String get homePopularProviders => 'Popular providers';

  @override
  String get homeRecentListings => 'Recently added';

  @override
  String get homeLocationLabel => 'Kinshasa';

  @override
  String get homeEmptyProviders => 'No providers yet.';

  @override
  String get homeCommunePickerTitle => 'Choose your commune';

  @override
  String get homePromoTitle => 'Offer your services';

  @override
  String get homePromoSubtitle =>
      'Post your listings for free and reach thousands of clients.';

  @override
  String get homePromoCta => 'Start now';

  @override
  String get homeEmptyRecent => 'No recent listings yet.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'What are you looking for?';

  @override
  String get exploreCategories => 'Categories';

  @override
  String get exploreRecentSearches => 'Recent searches';

  @override
  String get exploreClearRecent => 'Clear';

  @override
  String get searchResultsTitle => 'Results';

  @override
  String searchResultCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterNearMe => 'Near me';

  @override
  String get searchFilterVerified => 'Verified';

  @override
  String get searchFilterTopRated => 'Rating 4+';

  @override
  String get searchFilterPrice => 'Price';

  @override
  String get searchEmpty => 'No providers found.';

  @override
  String get searchEmptyAction => 'See all communes';

  @override
  String get searchSortTitle => 'Sort by';

  @override
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortRating => 'Best rating';

  @override
  String get searchSortRecent => 'Most recent';

  @override
  String get searchSortPrice => 'Price low to high';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterCommune => 'Commune';

  @override
  String get filterCommuneAll => 'All communes';

  @override
  String get filterVerified => 'Verified providers only';

  @override
  String get filterMinRating => 'Minimum rating';

  @override
  String get filterMinRatingAny => 'Any';

  @override
  String get filterPriceType => 'Price type';

  @override
  String get filterApply => 'Apply';

  @override
  String get filterReset => 'Reset';

  @override
  String get providerVerified => 'Verified';

  @override
  String get providerVerifiedSemantic => 'Verified provider';

  @override
  String providerRating(String rating) {
    return '$rating out of 5';
  }

  @override
  String providerReviewCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get providerExperience => 'Experience';

  @override
  String get providerWorks => 'Jobs';

  @override
  String get providerContacts => 'Contacts';

  @override
  String get providerBio => 'About';

  @override
  String get providerServices => 'Services';

  @override
  String get providerPortfolio => 'Portfolio';

  @override
  String get providerReviews => 'Reviews';

  @override
  String get providerCallButton => 'Call';

  @override
  String get providerWhatsAppButton => 'WhatsApp';

  @override
  String get providerFavoriteAdd => 'Add to favourites';

  @override
  String get providerFavoriteRemove => 'Remove from favourites';

  @override
  String get providerReport => 'Report';

  @override
  String get providerShare => 'Share profile';

  @override
  String providerShareMessage(String name) {
    return 'Check out $name on Kazi';
  }

  @override
  String providerWhatsAppMessage(String name, String listing) {
    return 'Hello $name, I found you on Kazi for \"$listing\". Are you available?';
  }

  @override
  String listingPriceFrom(String price) {
    return 'from $price';
  }

  @override
  String get listingPriceQuote => 'Quote on request';

  @override
  String get listingCommunesServed => 'Service areas';

  @override
  String get listingProviderCard => 'Provider';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsEmpty => 'No reviews yet.';

  @override
  String get reviewsWrite => 'Write a review';

  @override
  String reviewsRatingSummary(String rating, num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reviews',
      one: '1 review',
    );
    return '$rating out of 5 · $_temp0';
  }

  @override
  String get reviewsPublish => 'Publish review';

  @override
  String get reviewsRateLabel => 'Your rating';

  @override
  String get reviewsTextLabel => 'Your review';

  @override
  String get reviewsTextHint => 'Describe your experience with this provider…';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportReason => 'Reason';

  @override
  String get reportDetails => 'Details (optional)';

  @override
  String get reportSubmit => 'Report';

  @override
  String get reportSuccess => 'Report submitted. Thank you.';

  @override
  String get publishHubTitle => 'Publish a service';

  @override
  String get publishHubGuestCta => 'Sign in to publish';

  @override
  String get publishHubBecomeProvider => 'Become a provider';

  @override
  String get publishHubBecomeProviderSubtitle =>
      'Post your services for free and reach thousands of clients.';

  @override
  String get publishHubPending => 'Your application is under review.';

  @override
  String get publishHubRejected => 'Your application was rejected.';

  @override
  String get publishHubNewListing => 'New listing';

  @override
  String get publishHubApproved =>
      'Your profile is approved. Start publishing your services.';

  @override
  String get publishHubGoToDashboard => 'My provider space';

  @override
  String get publishHubResubmit => 'Edit and resubmit';

  @override
  String get publishHubSuspended =>
      'Your account has been suspended. Contact our support team for more information.';

  @override
  String get publishHubSupportCta => 'Contact support';

  @override
  String get onboardingTitle => 'Become a provider';

  @override
  String get onboardingStep1 => 'Identity';

  @override
  String get onboardingStep2 => 'Services';

  @override
  String get onboardingStep3 => 'Area';

  @override
  String get onboardingStep4 => 'Contact';

  @override
  String get onboardingStep5 => 'Review';

  @override
  String get onboardingSubmit => 'Submit my application';

  @override
  String get onboardingNameLabel => 'Full name / business name';

  @override
  String get onboardingBioLabel => 'About you';

  @override
  String get onboardingBioHint => 'Describe your skills and experience…';

  @override
  String get onboardingCategoriesLabel => 'Categories (max 3)';

  @override
  String get onboardingCommunesLabel => 'Communes served (max 10)';

  @override
  String get onboardingWhatsAppLabel => 'WhatsApp number';

  @override
  String get onboardingPhoneLabel => 'Call number (optional)';

  @override
  String get onboardingAvatarLabel => 'Profile photo';

  @override
  String get onboardingCoverLabel => 'Cover photo (optional)';

  @override
  String get onboardingUploadError => 'Upload failed. Try again.';

  @override
  String get onboardingPublicConsent =>
      'I agree that these numbers will be visible to clients.';

  @override
  String get onboardingYearsLabel => 'Years of experience';

  @override
  String get onboardingBaseCommuneLabel => 'Main commune';

  @override
  String get onboardingBaseCommuneHint => 'Choose your main commune';

  @override
  String get onboardingCategoryError => 'Select at least one category';

  @override
  String get onboardingCommuneError => 'Choose your main commune';

  @override
  String get onboardingReviewTitle => 'Review your application';

  @override
  String get listingFormTitle => 'Post a service';

  @override
  String get listingFormEditTitle => 'Edit listing';

  @override
  String listingFormPhotosLabel(int max) {
    return 'Photos (max $max)';
  }

  @override
  String get listingFormAddPhoto => 'Add';

  @override
  String get listingFormTitleLabel => 'Service title';

  @override
  String get listingFormTitleHint => 'E.g. Fast home plumbing';

  @override
  String get listingFormCategoryLabel => 'Category';

  @override
  String get listingFormDescriptionLabel => 'Description';

  @override
  String get listingFormPriceLabel => 'Starting price';

  @override
  String get listingFormPriceQuoteToggle => 'Quote on request';

  @override
  String get listingFormCommunesLabel => 'Service area';

  @override
  String get listingFormPublish => 'Publish';

  @override
  String get listingFormSaveDraft => 'Save draft';

  @override
  String get listingFormPhotoPickGallery => 'Gallery';

  @override
  String get listingFormPhotoPickCamera => 'Camera';

  @override
  String get listingFormCategoryHint => 'Choose a category';

  @override
  String get listingFormDescriptionHint =>
      'Describe your service, strengths and pricing…';

  @override
  String get listingFormPriceTypeFixed => 'Fixed';

  @override
  String get listingFormPriceTypeFrom => 'From';

  @override
  String get listingFormAmountHint => '0';

  @override
  String get listingFormCommuneHint => 'Select service zones (max 10)';

  @override
  String get listingFormTitleError => '4–80 characters required';

  @override
  String get listingFormCategoryError => 'Choose a category';

  @override
  String get listingFormCommuneError => 'Choose at least one zone';

  @override
  String get listingFormPublished => 'Listing published!';

  @override
  String get listingFormDraftSaved => 'Draft saved';

  @override
  String get dashboardTitle => 'My space';

  @override
  String get dashboardStatusPending => 'Application under review';

  @override
  String get dashboardStatusApproved => 'Profile approved';

  @override
  String get dashboardStatusRejected => 'Application rejected';

  @override
  String get dashboardMyListings => 'My listings';

  @override
  String get dashboardNewListing => 'New listing';

  @override
  String get dashboardVerification => 'Identity verification';

  @override
  String get dashboardListingPause => 'Pause';

  @override
  String get dashboardListingResume => 'Resume';

  @override
  String get dashboardListingEdit => 'Edit';

  @override
  String get dashboardListingDelete => 'Delete';

  @override
  String get dashboardListingDeleteConfirm => 'Delete this listing?';

  @override
  String get dashboardListingDeleteBody => 'This action cannot be undone.';

  @override
  String get dashboardListingPublishing => 'Publishing…';

  @override
  String get verificationTitle => 'Identity verification';

  @override
  String get verificationExplain =>
      'Your identity will be verified by our team within 48 hours. Documents will be deleted after verification.';

  @override
  String get verificationIdPhoto => 'Photo of ID document';

  @override
  String get verificationSelfie => 'Selfie with ID';

  @override
  String get verificationSubmit => 'Submit';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get verificationApproved => 'Identity verified';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No contacts yet.';

  @override
  String get messagesChatSoon => 'Integrated messaging coming soon';

  @override
  String messagesLastContact(String date) {
    return 'Last contact $date';
  }

  @override
  String get messagesSignInCta => 'Sign in to see your contact history';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileProviderSpace => 'Provider space';

  @override
  String get profileFavorites => 'My favourites';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileTerms => 'Terms of use';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profileDeleteAccount => 'Delete my account';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignInCta => 'Sign in to access your profile';

  @override
  String get profileSignInButton => 'Sign in';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileEditPhoto => 'Edit photo';

  @override
  String get favoritesTitle => 'My favourites';

  @override
  String get favoritesEmpty => 'You have no favourites yet.';

  @override
  String get favoritesEmptyAction => 'Explore providers';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEditProfile => 'Edit my profile';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageFr => 'Français';

  @override
  String get languageEn => 'English';

  @override
  String get deleteAccountTitle => 'Delete my account';

  @override
  String get deleteAccountWarning =>
      'This will permanently delete your account and all your data. This action cannot be undone.';

  @override
  String get deleteAccountConsequences =>
      'Your listings and provider profile will be deleted.';

  @override
  String get deleteAccountConfirmLabel => 'Type DELETE to confirm';

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String get deleteAccountButton => 'Delete my account';

  @override
  String get legalTermsTitle => 'Terms of use';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpWhatsApp => 'Contact support on WhatsApp';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'A new version of Kazi is available. Please update the app to continue.';

  @override
  String get updateRequiredButton => 'Update';

  @override
  String get maintenanceTitle => 'Maintenance in progress';

  @override
  String get maintenanceBody =>
      'Kazi is temporarily unavailable. Please check back in a few minutes.';

  @override
  String get profileFirstNameLabel => 'First name';

  @override
  String get profileFirstNameHint => 'e.g. Jean';

  @override
  String get profileLastNameLabel => 'Last name';

  @override
  String get profileLastNameHint => 'e.g. Mukendi';

  @override
  String get profileCommuneLabel => 'Your commune';

  @override
  String get profileCommuneHint => 'Choose your commune';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get profileSignOutConfirmBody => 'Are you sure you want to sign out?';

  @override
  String get errorSaveFailed => 'Failed to save. Please try again.';

  @override
  String get errorDeleteFailed => 'Failed to delete account. Please try again.';

  @override
  String get contactWhatsAppNotInstalled => 'WhatsApp is not installed';

  @override
  String get contactCopyNumber => 'Copy number';

  @override
  String get contactNumberCopied => 'Number copied';

  @override
  String get providerBlock => 'Block';

  @override
  String get providerUnblock => 'Unblock';

  @override
  String providerBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get providerBlockBody =>
      'They will disappear from your search results and home screen.';

  @override
  String get providerBlockConfirm => 'Block';

  @override
  String get providerBlockedSnackbar => 'Blocked';

  @override
  String get providerUnblockedSnackbar => 'Unblocked';
}
