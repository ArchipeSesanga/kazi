import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application title
  ///
  /// In fr, this message translates to:
  /// **'Kazi'**
  String get appTitle;

  /// Retry button
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get buttonRetry;

  /// Continue button
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get buttonContinue;

  /// Cancel button
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get buttonCancel;

  /// Confirm button
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get buttonConfirm;

  /// Save button
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get buttonSave;

  /// Close button
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get buttonClose;

  /// See all link
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get buttonSeeAll;

  /// Share button
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get buttonShare;

  /// Sign out button
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get buttonSignOut;

  /// Network error
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter. Vérifiez votre connexion.'**
  String get errorNetwork;

  /// Permission denied
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé.'**
  String get errorPermissionDenied;

  /// Not found
  ///
  /// In fr, this message translates to:
  /// **'Introuvable.'**
  String get errorNotFound;

  /// Validation error
  ///
  /// In fr, this message translates to:
  /// **'Données incorrectes. Vérifiez les informations saisies.'**
  String get errorInvalidInput;

  /// Rate limited
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Veuillez patienter.'**
  String get errorRateLimited;

  /// Too many requests
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Réessayez plus tard.'**
  String get errorTooManyRequests;

  /// Quota exceeded
  ///
  /// In fr, this message translates to:
  /// **'Quota atteint. Réessayez plus tard.'**
  String get errorQuotaExceeded;

  /// Unauthenticated
  ///
  /// In fr, this message translates to:
  /// **'Vous devez être connecté pour continuer.'**
  String get errorUnauthenticated;

  /// Unknown error
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue s\'est produite.'**
  String get errorUnknown;

  /// Offline banner
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion — affichage des données enregistrées'**
  String get offlineBanner;

  /// Home tab label
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// Explore tab label
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get navExplore;

  /// Publish tab label
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get navPublish;

  /// Messages tab label
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Profile tab label
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get navProfile;

  /// Welcome screen title
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Kazi'**
  String get welcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In fr, this message translates to:
  /// **'Trouvez les meilleurs prestataires près de vous'**
  String get welcomeSubtitle;

  /// Onboarding slide 1 title
  ///
  /// In fr, this message translates to:
  /// **'Trouvez un prestataire'**
  String get welcomeSlide1Title;

  /// Onboarding slide 1 body
  ///
  /// In fr, this message translates to:
  /// **'Plombiers, électriciens, coiffeuses… Trouvez le bon professionnel en quelques secondes.'**
  String get welcomeSlide1Body;

  /// Onboarding slide 2 title
  ///
  /// In fr, this message translates to:
  /// **'Contactez via WhatsApp'**
  String get welcomeSlide2Title;

  /// Onboarding slide 2 body
  ///
  /// In fr, this message translates to:
  /// **'Un tap et vous êtes en contact direct. Pas d\'intermédiaire.'**
  String get welcomeSlide2Body;

  /// Onboarding slide 3 title
  ///
  /// In fr, this message translates to:
  /// **'Proposez vos services'**
  String get welcomeSlide3Title;

  /// Onboarding slide 3 body
  ///
  /// In fr, this message translates to:
  /// **'Publiez vos annonces gratuitement et touchez des milliers de clients à Kinshasa.'**
  String get welcomeSlide3Body;

  /// Start button on welcome screen
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get welcomeStart;

  /// Language picker title
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get welcomeLanguageTitle;

  /// Skip onboarding button
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get welcomeSkip;

  /// Profile setup title
  ///
  /// In fr, this message translates to:
  /// **'Créez votre profil'**
  String get authProfileTitle;

  /// Name field label
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get authProfileNameLabel;

  /// Name field hint
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Jean Mukendi'**
  String get authProfileNameHint;

  /// Commune field label
  ///
  /// In fr, this message translates to:
  /// **'Votre commune'**
  String get authProfileCommuneLabel;

  /// Commune picker hint
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune'**
  String get authProfileCommuneHint;

  /// Add photo button
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get authProfilePhotoAdd;

  /// Save profile button
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mon profil'**
  String get authProfileSave;

  /// Email auth screen title
  ///
  /// In fr, this message translates to:
  /// **'Connexion par e-mail'**
  String get authEmailTitle;

  /// Email auth screen subtitle
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre e-mail et mot de passe.'**
  String get authEmailSubtitle;

  /// Email field label
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get authEmailLabel;

  /// Email field hint
  ///
  /// In fr, this message translates to:
  /// **'exemple@email.com'**
  String get authEmailHint;

  /// Password field label
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPasswordLabel;

  /// Password field hint
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get authPasswordHint;

  /// Email sign-in button
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authEmailSignIn;

  /// Email register button
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authEmailRegister;

  /// Prompt to switch to register mode
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get authEmailCreateAccountPrompt;

  /// Prompt to switch to sign-in mode
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get authEmailHasAccountPrompt;

  /// Forgot password link
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authEmailForgotPassword;

  /// Password reset confirmation
  ///
  /// In fr, this message translates to:
  /// **'E-mail de réinitialisation envoyé.'**
  String get authEmailResetSent;

  /// Email already in use error
  ///
  /// In fr, this message translates to:
  /// **'Cet e-mail est déjà utilisé.'**
  String get authEmailInUse;

  /// Weak password error
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court (6 caractères min).'**
  String get authWeakPassword;

  /// User not found error
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte trouvé pour cet e-mail.'**
  String get authUserNotFound;

  /// Wrong password error
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get authWrongPassword;

  /// Invalid email error
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get authEmailInvalid;

  /// Home search bar hint
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un service…'**
  String get homeSearchHint;

  /// Popular providers section title
  ///
  /// In fr, this message translates to:
  /// **'Prestataires populaires'**
  String get homePopularProviders;

  /// Recent listings section title
  ///
  /// In fr, this message translates to:
  /// **'Ajoutés récemment'**
  String get homeRecentListings;

  /// Default location chip label
  ///
  /// In fr, this message translates to:
  /// **'Kinshasa'**
  String get homeLocationLabel;

  /// Empty providers state
  ///
  /// In fr, this message translates to:
  /// **'Aucun prestataire pour l\'instant.'**
  String get homeEmptyProviders;

  /// Title of commune picker bottom sheet
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune'**
  String get homeCommunePickerTitle;

  /// Promo banner title on home screen
  ///
  /// In fr, this message translates to:
  /// **'Proposez vos services'**
  String get homePromoTitle;

  /// Promo banner subtitle on home screen
  ///
  /// In fr, this message translates to:
  /// **'Publiez vos annonces gratuitement et touchez des milliers de clients.'**
  String get homePromoSubtitle;

  /// Promo banner CTA button on home screen
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get homePromoCta;

  /// Empty recent listings state on home screen
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce récente pour l\'instant.'**
  String get homeEmptyRecent;

  /// Explore screen title
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get exploreTitle;

  /// Explore search hint
  ///
  /// In fr, this message translates to:
  /// **'Que cherchez-vous ?'**
  String get exploreSearchHint;

  /// Categories section title
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get exploreCategories;

  /// Recent searches section title
  ///
  /// In fr, this message translates to:
  /// **'Recherches récentes'**
  String get exploreRecentSearches;

  /// Clear recent searches button
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get exploreClearRecent;

  /// Search results screen title
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get searchResultsTitle;

  /// Result count
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String searchResultCount(num count);

  /// Near me filter chip
  ///
  /// In fr, this message translates to:
  /// **'Près de moi'**
  String get searchFilterNearMe;

  /// Verified filter chip
  ///
  /// In fr, this message translates to:
  /// **'Vérifiés'**
  String get searchFilterVerified;

  /// Top rated filter chip
  ///
  /// In fr, this message translates to:
  /// **'Note 4+'**
  String get searchFilterTopRated;

  /// Price filter chip
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get searchFilterPrice;

  /// Empty search results
  ///
  /// In fr, this message translates to:
  /// **'Aucun prestataire trouvé.'**
  String get searchEmpty;

  /// Empty search results action
  ///
  /// In fr, this message translates to:
  /// **'Voir toutes les communes'**
  String get searchEmptyAction;

  /// Sort sheet title
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get searchSortTitle;

  /// Sort by relevance
  ///
  /// In fr, this message translates to:
  /// **'Pertinence'**
  String get searchSortRelevance;

  /// Sort by rating
  ///
  /// In fr, this message translates to:
  /// **'Meilleure note'**
  String get searchSortRating;

  /// Sort by recent
  ///
  /// In fr, this message translates to:
  /// **'Plus récent'**
  String get searchSortRecent;

  /// Sort by price
  ///
  /// In fr, this message translates to:
  /// **'Prix croissant'**
  String get searchSortPrice;

  /// Filter sheet title
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filterTitle;

  /// Commune filter label
  ///
  /// In fr, this message translates to:
  /// **'Commune'**
  String get filterCommune;

  /// All communes option in filter sheet
  ///
  /// In fr, this message translates to:
  /// **'Toutes les communes'**
  String get filterCommuneAll;

  /// Verified toggle label
  ///
  /// In fr, this message translates to:
  /// **'Prestataires vérifiés uniquement'**
  String get filterVerified;

  /// Min rating label
  ///
  /// In fr, this message translates to:
  /// **'Note minimale'**
  String get filterMinRating;

  /// No minimum rating filter option
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterMinRatingAny;

  /// Price type label
  ///
  /// In fr, this message translates to:
  /// **'Type de prix'**
  String get filterPriceType;

  /// Apply filters button
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get filterApply;

  /// Reset filters button
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get filterReset;

  /// Verified badge label
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get providerVerified;

  /// Verified badge semantics
  ///
  /// In fr, this message translates to:
  /// **'Prestataire vérifié'**
  String get providerVerifiedSemantic;

  /// Rating text
  ///
  /// In fr, this message translates to:
  /// **'{rating} sur 5'**
  String providerRating(String rating);

  /// Review count
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun avis} =1{1 avis} other{{count} avis}}'**
  String providerReviewCount(num count);

  /// Experience stat label
  ///
  /// In fr, this message translates to:
  /// **'Expérience'**
  String get providerExperience;

  /// Works stat label
  ///
  /// In fr, this message translates to:
  /// **'Travaux'**
  String get providerWorks;

  /// Contacts stat label
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get providerContacts;

  /// Bio section title
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get providerBio;

  /// Services section title
  ///
  /// In fr, this message translates to:
  /// **'Services'**
  String get providerServices;

  /// Portfolio section title
  ///
  /// In fr, this message translates to:
  /// **'Portfolio'**
  String get providerPortfolio;

  /// Reviews section title
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get providerReviews;

  /// Call button
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get providerCallButton;

  /// WhatsApp button
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get providerWhatsAppButton;

  /// Add to favorites semantics
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get providerFavoriteAdd;

  /// Remove from favorites semantics
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get providerFavoriteRemove;

  /// Report provider action
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get providerReport;

  /// Share profile action
  ///
  /// In fr, this message translates to:
  /// **'Partager le profil'**
  String get providerShare;

  /// Pre-filled share message for provider profile
  ///
  /// In fr, this message translates to:
  /// **'Découvrez {name} sur Kazi'**
  String providerShareMessage(String name);

  /// Pre-filled WhatsApp message
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {name}, je vous ai trouvé sur Kazi pour « {listing} ». Êtes-vous disponible ?'**
  String providerWhatsAppMessage(String name, String listing);

  /// Price from label
  ///
  /// In fr, this message translates to:
  /// **'dès {price}'**
  String listingPriceFrom(String price);

  /// Price on quote
  ///
  /// In fr, this message translates to:
  /// **'Sur devis'**
  String get listingPriceQuote;

  /// Communes served section
  ///
  /// In fr, this message translates to:
  /// **'Zones desservies'**
  String get listingCommunesServed;

  /// Provider card label on listing detail
  ///
  /// In fr, this message translates to:
  /// **'Prestataire'**
  String get listingProviderCard;

  /// Reviews screen title
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get reviewsTitle;

  /// No reviews yet
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour l\'instant.'**
  String get reviewsEmpty;

  /// Write review button
  ///
  /// In fr, this message translates to:
  /// **'Laisser un avis'**
  String get reviewsWrite;

  /// Rating summary
  ///
  /// In fr, this message translates to:
  /// **'{rating} sur 5 · {count, plural, =1{1 avis} other{{count} avis}}'**
  String reviewsRatingSummary(String rating, num count);

  /// Publish review button
  ///
  /// In fr, this message translates to:
  /// **'Publier l\'avis'**
  String get reviewsPublish;

  /// Rate label in write review
  ///
  /// In fr, this message translates to:
  /// **'Votre note'**
  String get reviewsRateLabel;

  /// Review text label
  ///
  /// In fr, this message translates to:
  /// **'Votre avis'**
  String get reviewsTextLabel;

  /// Review text hint
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre expérience avec ce prestataire…'**
  String get reviewsTextHint;

  /// Report sheet title
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportTitle;

  /// Report reason label
  ///
  /// In fr, this message translates to:
  /// **'Raison'**
  String get reportReason;

  /// Report details label
  ///
  /// In fr, this message translates to:
  /// **'Détails (optionnel)'**
  String get reportDetails;

  /// Submit report button
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportSubmit;

  /// Report success message
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé. Merci.'**
  String get reportSuccess;

  /// Publish hub screen title
  ///
  /// In fr, this message translates to:
  /// **'Publier un service'**
  String get publishHubTitle;

  /// Guest CTA on publish hub
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour publier'**
  String get publishHubGuestCta;

  /// Become provider button
  ///
  /// In fr, this message translates to:
  /// **'Devenir prestataire'**
  String get publishHubBecomeProvider;

  /// Become provider subtitle
  ///
  /// In fr, this message translates to:
  /// **'Publiez vos services gratuitement et touchez des milliers de clients.'**
  String get publishHubBecomeProviderSubtitle;

  /// Pending status message (brief, auto-approve is instant in v1)
  ///
  /// In fr, this message translates to:
  /// **'Activation de votre profil…'**
  String get publishHubPending;

  /// Rejected status message
  ///
  /// In fr, this message translates to:
  /// **'Votre dossier a été refusé.'**
  String get publishHubRejected;

  /// New listing button
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle annonce'**
  String get publishHubNewListing;

  /// Approved status description on publish hub
  ///
  /// In fr, this message translates to:
  /// **'Votre profil est approuvé. Commencez à publier vos services.'**
  String get publishHubApproved;

  /// Go to provider dashboard button on publish hub
  ///
  /// In fr, this message translates to:
  /// **'Mon espace prestataire'**
  String get publishHubGoToDashboard;

  /// Edit and resubmit button shown on rejected state
  ///
  /// In fr, this message translates to:
  /// **'Modifier et resoumettre'**
  String get publishHubResubmit;

  /// Suspended account message on publish hub
  ///
  /// In fr, this message translates to:
  /// **'Votre compte a été suspendu. Contactez notre équipe d\'assistance pour plus d\'informations.'**
  String get publishHubSuspended;

  /// Contact support button shown on suspended state
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get publishHubSupportCta;

  /// Provider onboarding title
  ///
  /// In fr, this message translates to:
  /// **'Devenir prestataire'**
  String get onboardingTitle;

  /// Onboarding step 1 label
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get onboardingStep1;

  /// Onboarding step 2 label
  ///
  /// In fr, this message translates to:
  /// **'Services'**
  String get onboardingStep2;

  /// Onboarding step 3 label
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get onboardingStep3;

  /// Onboarding step 4 label
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get onboardingStep4;

  /// Onboarding step 5 label
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get onboardingStep5;

  /// Submit onboarding button
  ///
  /// In fr, this message translates to:
  /// **'Envoyer ma demande'**
  String get onboardingSubmit;

  /// Provider name label
  ///
  /// In fr, this message translates to:
  /// **'Nom complet / raison sociale'**
  String get onboardingNameLabel;

  /// Bio label
  ///
  /// In fr, this message translates to:
  /// **'Présentation'**
  String get onboardingBioLabel;

  /// Bio hint
  ///
  /// In fr, this message translates to:
  /// **'Décrivez vos compétences et votre expérience…'**
  String get onboardingBioHint;

  /// Categories label
  ///
  /// In fr, this message translates to:
  /// **'Catégories (max 3)'**
  String get onboardingCategoriesLabel;

  /// Communes label
  ///
  /// In fr, this message translates to:
  /// **'Communes desservies (max 10)'**
  String get onboardingCommunesLabel;

  /// WhatsApp number label
  ///
  /// In fr, this message translates to:
  /// **'Numéro WhatsApp'**
  String get onboardingWhatsAppLabel;

  /// Call number label
  ///
  /// In fr, this message translates to:
  /// **'Numéro d\'appel (optionnel)'**
  String get onboardingPhoneLabel;

  /// Profile photo picker label in onboarding step 1
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get onboardingAvatarLabel;

  /// Cover photo picker label in onboarding step 1
  ///
  /// In fr, this message translates to:
  /// **'Photo de couverture (optionnelle)'**
  String get onboardingCoverLabel;

  /// Error shown when image upload fails in onboarding
  ///
  /// In fr, this message translates to:
  /// **'Échec du téléchargement. Réessayez.'**
  String get onboardingUploadError;

  /// Public number consent checkbox
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte que ces numéros soient visibles par les clients.'**
  String get onboardingPublicConsent;

  /// Years of experience stepper label in onboarding step 1
  ///
  /// In fr, this message translates to:
  /// **'Années d\'expérience'**
  String get onboardingYearsLabel;

  /// Main commune picker label in onboarding step 2
  ///
  /// In fr, this message translates to:
  /// **'Commune principale'**
  String get onboardingBaseCommuneLabel;

  /// Placeholder for main commune picker when empty
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune principale'**
  String get onboardingBaseCommuneHint;

  /// Error shown when no category selected in step 2
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins une catégorie'**
  String get onboardingCategoryError;

  /// Error shown when no base commune selected in step 2
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune principale'**
  String get onboardingCommuneError;

  /// Title shown at top of review step in onboarding
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre candidature'**
  String get onboardingReviewTitle;

  /// Listing form title
  ///
  /// In fr, this message translates to:
  /// **'Publier un service'**
  String get listingFormTitle;

  /// Edit listing form title
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'annonce'**
  String get listingFormEditTitle;

  /// Photos label
  ///
  /// In fr, this message translates to:
  /// **'Photos (max {max})'**
  String listingFormPhotosLabel(int max);

  /// Add photo button
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get listingFormAddPhoto;

  /// Listing title label
  ///
  /// In fr, this message translates to:
  /// **'Titre du service'**
  String get listingFormTitleLabel;

  /// Listing title hint
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Plomberie rapide à domicile'**
  String get listingFormTitleHint;

  /// Category label
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get listingFormCategoryLabel;

  /// Description label
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get listingFormDescriptionLabel;

  /// Price label
  ///
  /// In fr, this message translates to:
  /// **'Prix de départ'**
  String get listingFormPriceLabel;

  /// Price on quote toggle
  ///
  /// In fr, this message translates to:
  /// **'Prix sur devis'**
  String get listingFormPriceQuoteToggle;

  /// Service area label
  ///
  /// In fr, this message translates to:
  /// **'Zone d\'intervention'**
  String get listingFormCommunesLabel;

  /// Publish listing button
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get listingFormPublish;

  /// Save draft button
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer le brouillon'**
  String get listingFormSaveDraft;

  /// Pick photo from gallery
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get listingFormPhotoPickGallery;

  /// Take photo with camera
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get listingFormPhotoPickCamera;

  /// Category picker hint
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une catégorie'**
  String get listingFormCategoryHint;

  /// Description field hint
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre service, vos atouts, vos tarifs…'**
  String get listingFormDescriptionHint;

  /// Fixed price type chip
  ///
  /// In fr, this message translates to:
  /// **'Fixe'**
  String get listingFormPriceTypeFixed;

  /// From price type chip
  ///
  /// In fr, this message translates to:
  /// **'À partir de'**
  String get listingFormPriceTypeFrom;

  /// Price amount field hint
  ///
  /// In fr, this message translates to:
  /// **'0'**
  String get listingFormAmountHint;

  /// Main commune picker label
  ///
  /// In fr, this message translates to:
  /// **'Commune principale'**
  String get listingFormBaseCommuneLabel;

  /// Main commune picker hint
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune principale'**
  String get listingFormBaseCommuneHint;

  /// Main commune validation error
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune principale'**
  String get listingFormBaseCommuneError;

  /// Communes picker hint
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez des zones supplémentaires (max 10)'**
  String get listingFormCommuneHint;

  /// Title validation error
  ///
  /// In fr, this message translates to:
  /// **'4 à 80 caractères requis'**
  String get listingFormTitleError;

  /// Category validation error
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une catégorie'**
  String get listingFormCategoryError;

  /// Commune validation error
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins une zone'**
  String get listingFormCommuneError;

  /// Listing published snackbar
  ///
  /// In fr, this message translates to:
  /// **'Annonce publiée !'**
  String get listingFormPublished;

  /// Draft saved snackbar
  ///
  /// In fr, this message translates to:
  /// **'Brouillon enregistré'**
  String get listingFormDraftSaved;

  /// Draft dialog title
  ///
  /// In fr, this message translates to:
  /// **'Garder le brouillon ?'**
  String get listingFormDraftDialogTitle;

  /// Draft dialog body
  ///
  /// In fr, this message translates to:
  /// **'Vous avez un brouillon non enregistré. Voulez-vous le garder ou le supprimer ?'**
  String get listingFormDraftDialogBody;

  /// Keep draft button
  ///
  /// In fr, this message translates to:
  /// **'Garder'**
  String get listingFormDraftKeep;

  /// Discard draft button
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get listingFormDraftDiscard;

  /// Photo upload error
  ///
  /// In fr, this message translates to:
  /// **'L\'envoi de la photo a échoué. Appuyez sur Réessayer.'**
  String get listingFormPhotoUploadError;

  /// Provider dashboard title
  ///
  /// In fr, this message translates to:
  /// **'Mon espace'**
  String get dashboardTitle;

  /// Dashboard pending status
  ///
  /// In fr, this message translates to:
  /// **'Dossier en cours d\'examen'**
  String get dashboardStatusPending;

  /// Dashboard approved status
  ///
  /// In fr, this message translates to:
  /// **'Profil approuvé'**
  String get dashboardStatusApproved;

  /// Dashboard rejected status
  ///
  /// In fr, this message translates to:
  /// **'Dossier refusé'**
  String get dashboardStatusRejected;

  /// My listings section
  ///
  /// In fr, this message translates to:
  /// **'Mes annonces'**
  String get dashboardMyListings;

  /// New listing button
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle annonce'**
  String get dashboardNewListing;

  /// Verification section title
  ///
  /// In fr, this message translates to:
  /// **'Vérification d\'identité'**
  String get dashboardVerification;

  /// Pause listing action
  ///
  /// In fr, this message translates to:
  /// **'Mettre en pause'**
  String get dashboardListingPause;

  /// Resume listing action
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get dashboardListingResume;

  /// Edit listing action
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get dashboardListingEdit;

  /// Delete listing action
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get dashboardListingDelete;

  /// Delete listing confirm title
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette annonce ?'**
  String get dashboardListingDeleteConfirm;

  /// Delete listing confirm body
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get dashboardListingDeleteBody;

  /// Listing publishing chip
  ///
  /// In fr, this message translates to:
  /// **'Publication en cours…'**
  String get dashboardListingPublishing;

  /// Dashboard suspended status
  ///
  /// In fr, this message translates to:
  /// **'Compte suspendu'**
  String get dashboardStatusSuspended;

  /// Draft listing status chip
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get dashboardListingStatusDraft;

  /// Active listing status chip
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get dashboardListingStatusActive;

  /// Paused listing status chip
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get dashboardListingStatusPaused;

  /// Empty listings message
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce pour l\'instant.'**
  String get dashboardListingsEmpty;

  /// Contacts this month stat label
  ///
  /// In fr, this message translates to:
  /// **'contacts ce mois'**
  String get dashboardStatContactsMonth;

  /// Total contacts stat label
  ///
  /// In fr, this message translates to:
  /// **'contacts au total'**
  String get dashboardStatContactsTotal;

  /// Average rating stat label
  ///
  /// In fr, this message translates to:
  /// **'note moyenne'**
  String get dashboardStatRating;

  /// Listing count stat label
  ///
  /// In fr, this message translates to:
  /// **'annonces'**
  String get dashboardStatListings;

  /// Verification screen title
  ///
  /// In fr, this message translates to:
  /// **'Vérification d\'identité'**
  String get verificationTitle;

  /// Verification explanation
  ///
  /// In fr, this message translates to:
  /// **'Votre identité sera vérifiée par notre équipe dans les 48 h. Les documents seront supprimés après vérification.'**
  String get verificationExplain;

  /// ID photo label
  ///
  /// In fr, this message translates to:
  /// **'Photo de la pièce d\'identité'**
  String get verificationIdPhoto;

  /// Selfie label
  ///
  /// In fr, this message translates to:
  /// **'Selfie avec la pièce'**
  String get verificationSelfie;

  /// Submit verification button
  ///
  /// In fr, this message translates to:
  /// **'Soumettre'**
  String get verificationSubmit;

  /// Verification pending status
  ///
  /// In fr, this message translates to:
  /// **'Vérification en attente'**
  String get verificationPending;

  /// Verification approved status
  ///
  /// In fr, this message translates to:
  /// **'Identité vérifiée'**
  String get verificationApproved;

  /// Messages screen title
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No messages yet
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour l\'instant.'**
  String get messagesEmpty;

  /// Chat coming soon banner
  ///
  /// In fr, this message translates to:
  /// **'Messagerie intégrée bientôt disponible'**
  String get messagesChatSoon;

  /// Last contact date
  ///
  /// In fr, this message translates to:
  /// **'Dernier contact {date}'**
  String messagesLastContact(String date);

  /// Sign in CTA on messages guest view
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour voir votre historique de contacts'**
  String get messagesSignInCta;

  /// Profile screen title
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get profileTitle;

  /// Provider space menu item
  ///
  /// In fr, this message translates to:
  /// **'Espace prestataire'**
  String get profileProviderSpace;

  /// Favorites menu item
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get profileFavorites;

  /// Language menu item
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// Help menu item
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get profileHelp;

  /// Terms menu item
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get profileTerms;

  /// Privacy menu item
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get profilePrivacy;

  /// Delete account menu item
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get profileDeleteAccount;

  /// Sign out menu item
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileSignOut;

  /// Sign in CTA on profile
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder à votre profil'**
  String get profileSignInCta;

  /// Sign in button
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get profileSignInButton;

  /// Edit name label
  ///
  /// In fr, this message translates to:
  /// **'Modifier le nom'**
  String get profileEditName;

  /// Edit photo label
  ///
  /// In fr, this message translates to:
  /// **'Modifier la photo'**
  String get profileEditPhoto;

  /// Favorites screen title
  ///
  /// In fr, this message translates to:
  /// **'Mes favoris'**
  String get favoritesTitle;

  /// No favorites yet
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore de favoris.'**
  String get favoritesEmpty;

  /// Explore action on empty favorites
  ///
  /// In fr, this message translates to:
  /// **'Explorer les prestataires'**
  String get favoritesEmptyAction;

  /// Settings screen title
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// Edit profile setting
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get settingsEditProfile;

  /// Notifications setting
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Language screen title
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageTitle;

  /// French language option
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFr;

  /// English language option
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEn;

  /// Delete account title
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccountTitle;

  /// Delete account warning
  ///
  /// In fr, this message translates to:
  /// **'Cette action supprimera définitivement votre compte et toutes vos données. Elle est irréversible.'**
  String get deleteAccountWarning;

  /// Delete account consequences
  ///
  /// In fr, this message translates to:
  /// **'Vos annonces, votre profil prestataire, vos favoris, vos contacts et vos photos seront supprimés. Les avis que vous avez laissés restent visibles, sans votre nom.'**
  String get deleteAccountConsequences;

  /// Delete confirmation input label
  ///
  /// In fr, this message translates to:
  /// **'Tapez SUPPRIMER pour confirmer'**
  String get deleteAccountConfirmLabel;

  /// Word to type to confirm deletion
  ///
  /// In fr, this message translates to:
  /// **'SUPPRIMER'**
  String get deleteAccountConfirmWord;

  /// Delete account confirm button
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccountButton;

  /// Terms screen title
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get legalTermsTitle;

  /// Privacy screen title
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get legalPrivacyTitle;

  /// Help screen title
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get helpTitle;

  /// Help WhatsApp button
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support WhatsApp'**
  String get helpWhatsApp;

  /// Update required title
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour requise'**
  String get updateRequiredTitle;

  /// Update required body
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle version de Kazi est disponible. Mettez l\'application à jour pour continuer.'**
  String get updateRequiredBody;

  /// Update button
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get updateRequiredButton;

  /// Maintenance title
  ///
  /// In fr, this message translates to:
  /// **'Maintenance en cours'**
  String get maintenanceTitle;

  /// Default maintenance body
  ///
  /// In fr, this message translates to:
  /// **'Kazi est temporairement indisponible. Revenez dans quelques minutes.'**
  String get maintenanceBody;

  /// No description provided for @profileFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get profileFirstNameLabel;

  /// No description provided for @profileFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Jean'**
  String get profileFirstNameHint;

  /// No description provided for @profileLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de famille'**
  String get profileLastNameLabel;

  /// No description provided for @profileLastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Mukendi'**
  String get profileLastNameHint;

  /// No description provided for @profileCommuneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre commune'**
  String get profileCommuneLabel;

  /// No description provided for @profileCommuneHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre commune'**
  String get profileCommuneHint;

  /// No description provided for @profileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Profil enregistré'**
  String get profileSaved;

  /// No description provided for @profileSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get profileSaveButton;

  /// No description provided for @profileSignOutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get profileSignOutConfirmBody;

  /// Save failed error
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'enregistrement. Veuillez réessayer.'**
  String get errorSaveFailed;

  /// Delete account failed error
  ///
  /// In fr, this message translates to:
  /// **'Échec de la suppression du compte. Veuillez réessayer.'**
  String get errorDeleteFailed;

  /// WhatsApp not installed snackbar
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp n\'est pas installé'**
  String get contactWhatsAppNotInstalled;

  /// Copy number snackbar action
  ///
  /// In fr, this message translates to:
  /// **'Copier le numéro'**
  String get contactCopyNumber;

  /// Number copied confirmation snackbar
  ///
  /// In fr, this message translates to:
  /// **'Numéro copié'**
  String get contactNumberCopied;

  /// Block provider action
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get providerBlock;

  /// Unblock provider action
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get providerUnblock;

  /// Block confirm dialog title
  ///
  /// In fr, this message translates to:
  /// **'Bloquer {name} ?'**
  String providerBlockTitle(String name);

  /// Block confirm dialog body
  ///
  /// In fr, this message translates to:
  /// **'Ce prestataire disparaîtra de vos résultats de recherche et de votre écran d\'accueil.'**
  String get providerBlockBody;

  /// Block confirm button
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get providerBlockConfirm;

  /// Provider blocked confirmation snackbar
  ///
  /// In fr, this message translates to:
  /// **'Bloqué(e)'**
  String get providerBlockedSnackbar;

  /// Provider unblocked confirmation snackbar
  ///
  /// In fr, this message translates to:
  /// **'Débloqué(e)'**
  String get providerUnblockedSnackbar;

  /// Listing quota label
  ///
  /// In fr, this message translates to:
  /// **'{used}/{max} annonces'**
  String listingLimitUsage(int used, int max);

  /// Listing limit dialog title
  ///
  /// In fr, this message translates to:
  /// **'Limite d\'annonces atteinte'**
  String get listingLimitReachedTitle;

  /// Listing limit explanation
  ///
  /// In fr, this message translates to:
  /// **'Vous avez atteint la limite de {max} annonces. Supprimez une annonce existante pour en créer une nouvelle.'**
  String listingLimitReachedBody(int max);

  /// Listing edit saved snackbar
  ///
  /// In fr, this message translates to:
  /// **'Annonce mise à jour.'**
  String get listingFormUpdated;

  /// Listing paused snackbar
  ///
  /// In fr, this message translates to:
  /// **'Annonce mise en pause.'**
  String get listingActionPaused;

  /// Listing resumed snackbar
  ///
  /// In fr, this message translates to:
  /// **'Annonce réactivée.'**
  String get listingActionResumed;

  /// Listing deleted snackbar
  ///
  /// In fr, this message translates to:
  /// **'Annonce supprimée.'**
  String get listingActionDeleted;

  /// Listing action failed snackbar
  ///
  /// In fr, this message translates to:
  /// **'L\'action a échoué. Veuillez réessayer.'**
  String get listingActionFailed;

  /// Listings load error
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les annonces.'**
  String get listingsLoadFailed;

  /// Listing hidden by moderation
  ///
  /// In fr, this message translates to:
  /// **'Masquée'**
  String get dashboardListingHidden;

  /// Chip: listing hidden because the limit was reached
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte'**
  String get dashboardListingOverLimit;

  /// Explanation for an over-limit listing
  ///
  /// In fr, this message translates to:
  /// **'Cette annonce est masquée : vous avez atteint la limite d\'annonces actives ou en pause. Supprimez une annonce, puis enregistrez celle-ci pour la republier.'**
  String get listingOverLimitNote;

  /// Dashboard app bar: open own public profile
  ///
  /// In fr, this message translates to:
  /// **'Voir mon profil public'**
  String get dashboardViewPublicProfile;

  /// Edit profile: add photo
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get profilePhotoAdd;

  /// Edit profile: change photo
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get profilePhotoChange;

  /// Edit profile: remove photo
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get profilePhotoRemove;

  /// Phone sign-in title
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro de téléphone'**
  String get authPhoneTitle;

  /// Phone sign-in subtitle
  ///
  /// In fr, this message translates to:
  /// **'Nous vous envoyons un code par SMS pour vous connecter.'**
  String get authPhoneSubtitle;

  /// Phone field label
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get authPhoneLabel;

  /// Phone field hint
  ///
  /// In fr, this message translates to:
  /// **'81 234 5678'**
  String get authPhoneHint;

  /// Send code button
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code'**
  String get authPhoneContinue;

  /// Invalid phone error
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone invalide.'**
  String get authPhoneInvalid;

  /// Dev-only link to email sign-in
  ///
  /// In fr, this message translates to:
  /// **'Connexion par e-mail (test)'**
  String get authPhoneUseEmail;

  /// OTP screen title
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code'**
  String get authOtpTitle;

  /// OTP field label
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get authOtpCodeLabel;

  /// OTP verify button
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get authOtpVerify;

  /// OTP resend button
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get authOtpResend;

  /// OTP change number
  ///
  /// In fr, this message translates to:
  /// **'Modifier le numéro'**
  String get authOtpChangeNumber;

  /// OTP wrong code
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Vérifiez et réessayez.'**
  String get authOtpWrong;

  /// OTP expired
  ///
  /// In fr, this message translates to:
  /// **'Ce code a expiré. Demandez-en un nouveau.'**
  String get authOtpExpired;

  /// Too many OTP attempts
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques minutes.'**
  String get authOtpTooMany;

  /// Network error on sign-in
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Vérifiez votre réseau.'**
  String get authPhoneNetwork;

  /// SMS quota exceeded
  ///
  /// In fr, this message translates to:
  /// **'Service SMS momentanément indisponible. Réessayez plus tard.'**
  String get authPhoneQuota;

  /// Resend countdown
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds} s'**
  String authOtpResendIn(int seconds);

  /// OTP subtitle
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code à 6 chiffres envoyé au {phone}.'**
  String authOtpSubtitle(String phone);

  /// Delete account: continue to OTP
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get deleteAccountContinue;

  /// Delete account OTP intro
  ///
  /// In fr, this message translates to:
  /// **'Par sécurité, confirmez avec le code envoyé au {phone}.'**
  String deleteAccountOtpIntro(String phone);

  /// Delete account retry
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get deleteAccountRetry;

  /// Delete account: reauth expired
  ///
  /// In fr, this message translates to:
  /// **'La confirmation a expiré. Demandez un nouveau code.'**
  String get deleteAccountReauthExpired;

  /// Delete account without phone
  ///
  /// In fr, this message translates to:
  /// **'Votre compte n\'a pas de numéro vérifié : suppression impossible depuis l\'application.'**
  String get deleteAccountNoPhone;

  /// Invalid provider phone number
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide. Exemple : +243 81 234 5678'**
  String get onboardingPhoneInvalid;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
