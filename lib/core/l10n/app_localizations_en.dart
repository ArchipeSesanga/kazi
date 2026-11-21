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
  String get publishHubPending => 'Activating your profile…';

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
  String get listingFormBaseCommuneLabel => 'Main commune';

  @override
  String get listingFormBaseCommuneHint => 'Choose your main commune';

  @override
  String get listingFormBaseCommuneError => 'Choose your main commune';

  @override
  String get listingFormCommuneHint =>
      'Select additional service zones (max 10)';

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
  String get listingFormDraftDialogTitle => 'Keep draft?';

  @override
  String get listingFormDraftDialogBody =>
      'You have an unsaved draft. Do you want to keep it or discard it?';

  @override
  String get listingFormDraftKeep => 'Keep';

  @override
  String get listingFormDraftDiscard => 'Discard';

  @override
  String get listingFormPhotoUploadError =>
      'Photo upload failed. Tap Retry to resume.';

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
  String get dashboardStatusSuspended => 'Account suspended';

  @override
  String get dashboardListingStatusDraft => 'Draft';

  @override
  String get dashboardListingStatusActive => 'Active';

  @override
  String get dashboardListingStatusPaused => 'Paused';

  @override
  String get dashboardListingsEmpty => 'No listings yet.';

  @override
  String get dashboardStatContactsMonth => 'contacts this month';

  @override
  String get dashboardStatContactsTotal => 'total contacts';

  @override
  String get dashboardStatRating => 'avg rating';

  @override
  String get dashboardStatListings => 'listings';

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
      'Your listings, provider profile, favourites, contacts and photos will be deleted. Reviews you wrote stay visible, without your name.';

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

  @override
  String listingLimitUsage(int used, int max) {
    return '$used/$max listings';
  }

  @override
  String get listingLimitReachedTitle => 'Listing limit reached';

  @override
  String listingLimitReachedBody(int max) {
    return 'You have reached the limit of $max listings. Delete an existing listing to create a new one.';
  }

  @override
  String get listingFormUpdated => 'Listing updated.';

  @override
  String get listingActionPaused => 'Listing paused.';

  @override
  String get listingActionResumed => 'Listing resumed.';

  @override
  String get listingActionDeleted => 'Listing deleted.';

  @override
  String get listingActionFailed => 'The action failed. Please try again.';

  @override
  String get listingsLoadFailed => 'Couldn\'t load listings.';

  @override
  String get dashboardListingHidden => 'Hidden';

  @override
  String get dashboardListingOverLimit => 'Limit reached';

  @override
  String get listingOverLimitNote =>
      'This listing is hidden: you have reached the limit of active or paused listings. Delete a listing, then save this one to republish it.';

  @override
  String get dashboardViewPublicProfile => 'View my public profile';

  @override
  String get profilePhotoAdd => 'Add a photo';

  @override
  String get profilePhotoChange => 'Change photo';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get authPhoneTitle => 'Your phone number';

  @override
  String get authPhoneSubtitle => 'We\'ll text you a code to sign in.';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '81 234 5678';

  @override
  String get authPhoneContinue => 'Send code';

  @override
  String get authPhoneInvalid => 'Invalid phone number.';

  @override
  String get authPhoneUseEmail => 'Email sign-in (test)';

  @override
  String get authOtpTitle => 'Enter the code';

  @override
  String get authOtpCodeLabel => '6-digit code';

  @override
  String get authOtpVerify => 'Verify';

  @override
  String get authOtpResend => 'Resend code';

  @override
  String get authOtpChangeNumber => 'Change number';

  @override
  String get authOtpWrong => 'Wrong code. Check it and try again.';

  @override
  String get authOtpExpired => 'This code has expired. Request a new one.';

  @override
  String get authOtpTooMany => 'Too many attempts. Try again in a few minutes.';

  @override
  String get authPhoneNetwork => 'No connection. Check your network.';

  @override
  String get authPhoneQuota =>
      'SMS service temporarily unavailable. Try again later.';

  @override
  String authOtpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String authOtpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone.';
  }

  @override
  String get deleteAccountContinue => 'Continue';

  @override
  String deleteAccountOtpIntro(String phone) {
    return 'For your security, confirm with the code sent to $phone.';
  }

  @override
  String get deleteAccountRetry => 'Try again';

  @override
  String get deleteAccountReauthExpired =>
      'The confirmation expired. Request a new code.';

  @override
  String get deleteAccountNoPhone =>
      'Your account has no verified number: it cannot be deleted from the app.';

  @override
  String get onboardingPhoneInvalid =>
      'Invalid number. Example: +243 81 234 5678';

  @override
  String get reportReasonScam => 'Scam';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonFake => 'Fake profile or listing';

  @override
  String get reportReasonWrongCategory => 'Wrong category';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportAlready => 'Already reported';

  @override
  String get reportRateLimited => 'Too many reports today. Try again tomorrow.';

  @override
  String get reportOwnTarget => 'You can\'t report your own content.';

  @override
  String get reportNotFound => 'This content no longer exists.';

  @override
  String get reportNotVerified => 'Sign in with your phone number to report.';

  @override
  String get legalOpenHint =>
      'This document is published on our website. It opens in your browser.';

  @override
  String get legalOpenButton => 'Open the page';
}
