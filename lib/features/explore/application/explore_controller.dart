import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreController extends ChangeNotifier {
  ExploreController(this._prefs) {
    _searches = List.of(_prefs.getStringList(_kKey) ?? []);
  }

  static const _kKey = 'explore_recent_searches_v1';
  static const _kMax = 10;

  final SharedPreferences _prefs;
  late List<String> _searches;

  List<String> get searches => List.unmodifiable(_searches);

  Future<void> addSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _searches.remove(q);
    _searches.insert(0, q);
    if (_searches.length > _kMax) _searches.removeRange(_kMax, _searches.length);
    await _prefs.setStringList(_kKey, _searches);
    notifyListeners();
  }

  Future<void> removeSearch(String query) async {
    _searches.remove(query);
    await _prefs.setStringList(_kKey, _searches);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _searches = [];
    await _prefs.remove(_kKey);
    notifyListeners();
  }
}
