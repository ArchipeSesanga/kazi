import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingController(this._prefs)
    : _isComplete = _prefs.getBool(_completionKey) ?? false;

  static const _completionKey = 'onboarding_complete';

  final SharedPreferences _prefs;
  bool _isComplete;

  bool get isComplete => _isComplete;

  Future<void> complete() async {
    if (_isComplete) return;
    await _prefs.setBool(_completionKey, true);
    _isComplete = true;
    notifyListeners();
  }
}
