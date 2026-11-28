import 'package:flutter/foundation.dart' hide Category;

import '../domain/catalog_repository.dart';

export '../domain/catalog_repository.dart' show Category, City, Commune;

class CatalogController extends ChangeNotifier {
  CatalogController(this._repo);

  final CatalogRepository _repo;

  List<Category> _categories = [];
  List<City> _cities = [];
  bool _isLoading = false;
  Object? _error;

  List<Category> get categories => _categories;
  List<City> get cities => _cities;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  /// Home shows only these (the 8 `featured` ones), in order; everything else
  /// is behind "Voir tout".
  List<Category> get featured =>
      _categories.where((c) => c.featured && c.active).toList();

  /// Categories a provider or listing can pick: active ones, in order.
  List<Category> get selectable => _categories.where((c) => c.active).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getLocations(),
      ]);
      _categories = results[0] as List<Category>;
      _cities = results[1] as List<City>;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  City? cityById(String id) {
    for (final c in _cities) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Returns a commune by id across all cities.
  Commune? communeById(String id) {
    for (final city in _cities) {
      for (final commune in city.communes) {
        if (commune.id == id) return commune;
      }
    }
    return null;
  }
}
