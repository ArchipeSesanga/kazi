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
  String get buttonRetry => 'Réessayer';

  @override
  String get offlineBanner =>
      'Hors connexion — affichage des données enregistrées';
}
