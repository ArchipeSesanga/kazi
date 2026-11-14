// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kazi';

  @override
  String get buttonRetry => 'Réessayer';

  @override
  String get buttonContinue => 'Continuer';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonConfirm => 'Confirmer';

  @override
  String get buttonSave => 'Enregistrer';

  @override
  String get buttonClose => 'Fermer';

  @override
  String get buttonSeeAll => 'Voir tout';

  @override
  String get buttonShare => 'Partager';

  @override
  String get buttonSignOut => 'Se déconnecter';

  @override
  String get errorNetwork =>
      'Impossible de se connecter. Vérifiez votre connexion.';

  @override
  String get errorPermissionDenied => 'Accès refusé.';

  @override
  String get errorNotFound => 'Introuvable.';

  @override
  String get errorInvalidInput =>
      'Données incorrectes. Vérifiez les informations saisies.';

  @override
  String get errorRateLimited => 'Trop de tentatives. Veuillez patienter.';

  @override
  String get errorOtpInvalid => 'Code incorrect. Vérifiez et réessayez.';

  @override
  String get errorOtpExpired => 'Code expiré. Demandez un nouveau code.';

  @override
  String get errorTooManyRequests => 'Trop de demandes. Réessayez plus tard.';

  @override
  String get errorQuotaExceeded => 'Quota atteint. Réessayez plus tard.';

  @override
  String get errorUnauthenticated => 'Vous devez être connecté pour continuer.';

  @override
  String get errorUnknown => 'Une erreur inattendue s\'est produite.';

  @override
  String get offlineBanner =>
      'Hors connexion — affichage des données enregistrées';

  @override
  String get navHome => 'Accueil';

  @override
  String get navExplore => 'Explorer';

  @override
  String get navPublish => 'Publier';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Moi';

  @override
  String get welcomeTitle => 'Bienvenue sur Kazi';

  @override
  String get welcomeSubtitle =>
      'Trouvez les meilleurs prestataires près de vous';

  @override
  String get welcomeSlide1Title => 'Trouvez un prestataire';

  @override
  String get welcomeSlide1Body =>
      'Plombiers, électriciens, coiffeuses… Trouvez le bon professionnel en quelques secondes.';

  @override
  String get welcomeSlide2Title => 'Contactez via WhatsApp';

  @override
  String get welcomeSlide2Body =>
      'Un tap et vous êtes en contact direct. Pas d\'intermédiaire.';

  @override
  String get welcomeSlide3Title => 'Proposez vos services';

  @override
  String get welcomeSlide3Body =>
      'Publiez vos annonces gratuitement et touchez des milliers de clients à Kinshasa.';

  @override
  String get welcomeStart => 'Commencer';

  @override
  String get welcomeLanguageTitle => 'Choisissez votre langue';

  @override
  String get welcomeSkip => 'Passer';

  @override
  String get authPhoneTitle => 'Entrez votre numéro';

  @override
  String get authPhoneSubtitle =>
      'Nous vous enverrons un code de confirmation.';

  @override
  String get authPhoneLabel => 'Numéro de téléphone';

  @override
  String get authPhoneHint => '081 234 5678';

  @override
  String get authPhoneSend => 'Recevoir le code';

  @override
  String get authPhoneTermsPrefix => 'En continuant, vous acceptez nos ';

  @override
  String get authPhoneTermsLink => 'Conditions d\'utilisation';

  @override
  String get authPhoneTermsAnd => ' et notre ';

  @override
  String get authPhonePrivacyLink => 'Politique de confidentialité';

  @override
  String get authPhoneTermsError =>
      'Veuillez accepter les conditions pour continuer.';

  @override
  String get authPhoneInvalid => 'Numéro invalide. Vérifiez et réessayez.';

  @override
  String get authOtpTitle => 'Entrez le code';

  @override
  String authOtpSubtitle(String phone) {
    return 'Code envoyé au $phone';
  }

  @override
  String authOtpResendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get authOtpResend => 'Renvoyer le code';

  @override
  String get authOtpChangeNumber => 'Changer de numéro';

  @override
  String get authProfileTitle => 'Créez votre profil';

  @override
  String get authProfileNameLabel => 'Votre nom';

  @override
  String get authProfileNameHint => 'Ex. : Jean Mukendi';

  @override
  String get authProfileCommuneLabel => 'Votre commune';

  @override
  String get authProfileCommuneHint => 'Choisissez votre commune';

  @override
  String get authProfilePhotoAdd => 'Ajouter une photo';

  @override
  String get authProfileSave => 'Enregistrer mon profil';

  @override
  String get homeSearchHint => 'Rechercher un service…';

  @override
  String get homePopularProviders => 'Prestataires populaires';

  @override
  String get homeRecentListings => 'Ajoutés récemment';

  @override
  String get homeLocationLabel => 'Kinshasa';

  @override
  String get homeEmptyProviders => 'Aucun prestataire pour l\'instant.';

  @override
  String get homeCommunePickerTitle => 'Choisissez votre commune';

  @override
  String get homePromoTitle => 'Proposez vos services';

  @override
  String get homePromoSubtitle =>
      'Publiez vos annonces gratuitement et touchez des milliers de clients.';

  @override
  String get homePromoCta => 'Commencer';

  @override
  String get homeEmptyRecent => 'Aucune annonce récente pour l\'instant.';

  @override
  String get exploreTitle => 'Explorer';

  @override
  String get exploreSearchHint => 'Que cherchez-vous ?';

  @override
  String get exploreCategories => 'Catégories';

  @override
  String get exploreRecentSearches => 'Recherches récentes';

  @override
  String get exploreClearRecent => 'Effacer';

  @override
  String get searchResultsTitle => 'Résultats';

  @override
  String searchResultCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get searchFilterNearMe => 'Près de moi';

  @override
  String get searchFilterVerified => 'Vérifiés';

  @override
  String get searchFilterTopRated => 'Note 4+';

  @override
  String get searchFilterPrice => 'Prix';

  @override
  String get searchEmpty => 'Aucun prestataire trouvé.';

  @override
  String get searchEmptyAction => 'Voir toutes les communes';

  @override
  String get searchSortTitle => 'Trier par';

  @override
  String get searchSortRelevance => 'Pertinence';

  @override
  String get searchSortRating => 'Meilleure note';

  @override
  String get searchSortRecent => 'Plus récent';

  @override
  String get searchSortPrice => 'Prix croissant';

  @override
  String get filterTitle => 'Filtres';

  @override
  String get filterCommune => 'Commune';

  @override
  String get filterCommuneAll => 'Toutes les communes';

  @override
  String get filterVerified => 'Prestataires vérifiés uniquement';

  @override
  String get filterMinRating => 'Note minimale';

  @override
  String get filterMinRatingAny => 'Toutes';

  @override
  String get filterPriceType => 'Type de prix';

  @override
  String get filterApply => 'Appliquer';

  @override
  String get filterReset => 'Réinitialiser';

  @override
  String get providerVerified => 'Vérifié';

  @override
  String get providerVerifiedSemantic => 'Prestataire vérifié';

  @override
  String providerRating(String rating) {
    return '$rating sur 5';
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
      other: '$countString avis',
      one: '1 avis',
      zero: 'Aucun avis',
    );
    return '$_temp0';
  }

  @override
  String get providerExperience => 'Expérience';

  @override
  String get providerWorks => 'Travaux';

  @override
  String get providerContacts => 'Contacts';

  @override
  String get providerBio => 'À propos';

  @override
  String get providerServices => 'Services';

  @override
  String get providerPortfolio => 'Portfolio';

  @override
  String get providerReviews => 'Avis';

  @override
  String get providerCallButton => 'Appeler';

  @override
  String get providerWhatsAppButton => 'WhatsApp';

  @override
  String get providerFavoriteAdd => 'Ajouter aux favoris';

  @override
  String get providerFavoriteRemove => 'Retirer des favoris';

  @override
  String get providerReport => 'Signaler';

  @override
  String get providerShare => 'Partager le profil';

  @override
  String providerShareMessage(String name) {
    return 'Découvrez $name sur Kazi';
  }

  @override
  String providerWhatsAppMessage(String name, String listing) {
    return 'Bonjour $name, je vous ai trouvé sur Kazi pour « $listing ». Êtes-vous disponible ?';
  }

  @override
  String listingPriceFrom(String price) {
    return 'dès $price';
  }

  @override
  String get listingPriceQuote => 'Sur devis';

  @override
  String get listingCommunesServed => 'Zones desservies';

  @override
  String get listingProviderCard => 'Prestataire';

  @override
  String get reviewsTitle => 'Avis';

  @override
  String get reviewsEmpty => 'Aucun avis pour l\'instant.';

  @override
  String get reviewsWrite => 'Laisser un avis';

  @override
  String reviewsRatingSummary(String rating, num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString avis',
      one: '1 avis',
    );
    return '$rating sur 5 · $_temp0';
  }

  @override
  String get reviewsPublish => 'Publier l\'avis';

  @override
  String get reviewsRateLabel => 'Votre note';

  @override
  String get reviewsTextLabel => 'Votre avis';

  @override
  String get reviewsTextHint =>
      'Décrivez votre expérience avec ce prestataire…';

  @override
  String get reportTitle => 'Signaler';

  @override
  String get reportReason => 'Raison';

  @override
  String get reportDetails => 'Détails (optionnel)';

  @override
  String get reportSubmit => 'Signaler';

  @override
  String get reportSuccess => 'Signalement envoyé. Merci.';

  @override
  String get publishHubTitle => 'Publier un service';

  @override
  String get publishHubGuestCta => 'Connectez-vous pour publier';

  @override
  String get publishHubBecomeProvider => 'Devenir prestataire';

  @override
  String get publishHubBecomeProviderSubtitle =>
      'Publiez vos services gratuitement et touchez des milliers de clients.';

  @override
  String get publishHubPending => 'Votre dossier est en cours d\'examen.';

  @override
  String get publishHubRejected => 'Votre dossier a été refusé.';

  @override
  String get publishHubNewListing => 'Nouvelle annonce';

  @override
  String get publishHubApproved =>
      'Votre profil est approuvé. Commencez à publier vos services.';

  @override
  String get publishHubGoToDashboard => 'Mon espace prestataire';

  @override
  String get publishHubResubmit => 'Modifier et resoumettre';

  @override
  String get publishHubSuspended =>
      'Votre compte a été suspendu. Contactez notre équipe d\'assistance pour plus d\'informations.';

  @override
  String get publishHubSupportCta => 'Contacter le support';

  @override
  String get onboardingTitle => 'Devenir prestataire';

  @override
  String get onboardingStep1 => 'Identité';

  @override
  String get onboardingStep2 => 'Services';

  @override
  String get onboardingStep3 => 'Zone';

  @override
  String get onboardingStep4 => 'Contact';

  @override
  String get onboardingStep5 => 'Récapitulatif';

  @override
  String get onboardingSubmit => 'Envoyer ma demande';

  @override
  String get onboardingNameLabel => 'Nom complet / raison sociale';

  @override
  String get onboardingBioLabel => 'Présentation';

  @override
  String get onboardingBioHint =>
      'Décrivez vos compétences et votre expérience…';

  @override
  String get onboardingCategoriesLabel => 'Catégories (max 3)';

  @override
  String get onboardingCommunesLabel => 'Communes desservies (max 10)';

  @override
  String get onboardingWhatsAppLabel => 'Numéro WhatsApp';

  @override
  String get onboardingPhoneLabel => 'Numéro d\'appel (optionnel)';

  @override
  String get onboardingAvatarLabel => 'Photo de profil';

  @override
  String get onboardingCoverLabel => 'Photo de couverture (optionnelle)';

  @override
  String get onboardingUploadError => 'Échec du téléchargement. Réessayez.';

  @override
  String get onboardingPublicConsent =>
      'J\'accepte que ces numéros soient visibles par les clients.';

  @override
  String get onboardingYearsLabel => 'Années d\'expérience';

  @override
  String get onboardingBaseCommuneLabel => 'Commune principale';

  @override
  String get onboardingBaseCommuneHint => 'Choisissez votre commune principale';

  @override
  String get onboardingCategoryError => 'Sélectionnez au moins une catégorie';

  @override
  String get onboardingCommuneError => 'Choisissez votre commune principale';

  @override
  String get onboardingReviewTitle => 'Vérifiez votre candidature';

  @override
  String get listingFormTitle => 'Publier un service';

  @override
  String get listingFormEditTitle => 'Modifier l\'annonce';

  @override
  String listingFormPhotosLabel(int max) {
    return 'Photos (max $max)';
  }

  @override
  String get listingFormAddPhoto => 'Ajouter';

  @override
  String get listingFormTitleLabel => 'Titre du service';

  @override
  String get listingFormTitleHint => 'Ex. : Plomberie rapide à domicile';

  @override
  String get listingFormCategoryLabel => 'Catégorie';

  @override
  String get listingFormDescriptionLabel => 'Description';

  @override
  String get listingFormPriceLabel => 'Prix de départ';

  @override
  String get listingFormPriceQuoteToggle => 'Prix sur devis';

  @override
  String get listingFormCommunesLabel => 'Zone d\'intervention';

  @override
  String get listingFormPublish => 'Publier';

  @override
  String get listingFormSaveDraft => 'Enregistrer le brouillon';

  @override
  String get dashboardTitle => 'Mon espace';

  @override
  String get dashboardStatusPending => 'Dossier en cours d\'examen';

  @override
  String get dashboardStatusApproved => 'Profil approuvé';

  @override
  String get dashboardStatusRejected => 'Dossier refusé';

  @override
  String get dashboardMyListings => 'Mes annonces';

  @override
  String get dashboardNewListing => 'Nouvelle annonce';

  @override
  String get dashboardVerification => 'Vérification d\'identité';

  @override
  String get dashboardListingPause => 'Mettre en pause';

  @override
  String get dashboardListingResume => 'Reprendre';

  @override
  String get dashboardListingEdit => 'Modifier';

  @override
  String get dashboardListingDelete => 'Supprimer';

  @override
  String get dashboardListingDeleteConfirm => 'Supprimer cette annonce ?';

  @override
  String get dashboardListingDeleteBody => 'Cette action est irréversible.';

  @override
  String get dashboardListingPublishing => 'Publication en cours…';

  @override
  String get verificationTitle => 'Vérification d\'identité';

  @override
  String get verificationExplain =>
      'Votre identité sera vérifiée par notre équipe dans les 48 h. Les documents seront supprimés après vérification.';

  @override
  String get verificationIdPhoto => 'Photo de la pièce d\'identité';

  @override
  String get verificationSelfie => 'Selfie avec la pièce';

  @override
  String get verificationSubmit => 'Soumettre';

  @override
  String get verificationPending => 'Vérification en attente';

  @override
  String get verificationApproved => 'Identité vérifiée';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'Aucun contact pour l\'instant.';

  @override
  String get messagesChatSoon => 'Messagerie intégrée bientôt disponible';

  @override
  String messagesLastContact(String date) {
    return 'Dernier contact $date';
  }

  @override
  String get messagesSignInCta =>
      'Connectez-vous pour voir votre historique de contacts';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get profileProviderSpace => 'Espace prestataire';

  @override
  String get profileFavorites => 'Mes favoris';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileTerms => 'Conditions d\'utilisation';

  @override
  String get profilePrivacy => 'Politique de confidentialité';

  @override
  String get profileDeleteAccount => 'Supprimer mon compte';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileSignInCta => 'Connectez-vous pour accéder à votre profil';

  @override
  String get profileSignInButton => 'Se connecter';

  @override
  String get profileEditName => 'Modifier le nom';

  @override
  String get profileEditPhoto => 'Modifier la photo';

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get favoritesEmpty => 'Vous n\'avez pas encore de favoris.';

  @override
  String get favoritesEmptyAction => 'Explorer les prestataires';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsEditProfile => 'Modifier mon profil';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageFr => 'Français';

  @override
  String get languageEn => 'English';

  @override
  String get deleteAccountTitle => 'Supprimer mon compte';

  @override
  String get deleteAccountWarning =>
      'Cette action supprimera définitivement votre compte et toutes vos données. Elle est irréversible.';

  @override
  String get deleteAccountConsequences =>
      'Vos annonces et votre profil prestataire seront supprimés.';

  @override
  String get deleteAccountConfirmLabel => 'Tapez SUPPRIMER pour confirmer';

  @override
  String get deleteAccountConfirmWord => 'SUPPRIMER';

  @override
  String get deleteAccountButton => 'Supprimer mon compte';

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get helpTitle => 'Aide';

  @override
  String get helpWhatsApp => 'Contacter le support WhatsApp';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String get updateRequiredBody =>
      'Une nouvelle version de Kazi est disponible. Mettez l\'application à jour pour continuer.';

  @override
  String get updateRequiredButton => 'Mettre à jour';

  @override
  String get maintenanceTitle => 'Maintenance en cours';

  @override
  String get maintenanceBody =>
      'Kazi est temporairement indisponible. Revenez dans quelques minutes.';

  @override
  String get profileFirstNameLabel => 'Prénom';

  @override
  String get profileFirstNameHint => 'Ex. : Jean';

  @override
  String get profileLastNameLabel => 'Nom de famille';

  @override
  String get profileLastNameHint => 'Ex. : Mukendi';

  @override
  String get profileCommuneLabel => 'Votre commune';

  @override
  String get profileCommuneHint => 'Choisissez votre commune';

  @override
  String get profileSaved => 'Profil enregistré';

  @override
  String get profileSaveButton => 'Enregistrer';

  @override
  String get profileSignOutConfirmBody =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get errorSaveFailed =>
      'Échec de l\'enregistrement. Veuillez réessayer.';

  @override
  String get errorDeleteFailed =>
      'Échec de la suppression du compte. Veuillez réessayer.';

  @override
  String get contactWhatsAppNotInstalled => 'WhatsApp n\'est pas installé';

  @override
  String get contactCopyNumber => 'Copier le numéro';

  @override
  String get contactNumberCopied => 'Numéro copié';

  @override
  String get providerBlock => 'Bloquer';

  @override
  String get providerUnblock => 'Débloquer';

  @override
  String providerBlockTitle(String name) {
    return 'Bloquer $name ?';
  }

  @override
  String get providerBlockBody =>
      'Ce prestataire disparaîtra de vos résultats de recherche et de votre écran d\'accueil.';

  @override
  String get providerBlockConfirm => 'Bloquer';

  @override
  String get providerBlockedSnackbar => 'Bloqué(e)';

  @override
  String get providerUnblockedSnackbar => 'Débloqué(e)';
}
