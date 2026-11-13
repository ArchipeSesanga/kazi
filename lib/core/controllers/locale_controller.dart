import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(SharedPreferences prefs) : _prefs = prefs {
    final code = prefs.getString(_key);
    if (code != null) _locale = Locale(code);
  }

  static const _key = 'app_locale';
  static const supported = [Locale('fr'), Locale('en')];

  final SharedPreferences _prefs;
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
