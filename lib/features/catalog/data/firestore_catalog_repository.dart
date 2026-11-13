import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/catalog_repository.dart';

const _kCategoriesKey = 'catalog_categories_v1';
const _kLocationsKey  = 'catalog_locations_v1';

class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository(this._db, this._prefs);

  final FirebaseFirestore _db;
  final SharedPreferences _prefs;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final snap = await _db
          .collection('categories')
          .orderBy('order')
          .get();
      final categories = snap.docs
          .map((d) => Category.fromJson({...d.data(), 'id': d.id}))
          .where((c) => c.active)
          .toList();
      await _prefs.setString(
        _kCategoriesKey,
        jsonEncode(categories.map((c) => c.toJson()).toList()),
      );
      return categories;
    } on FirebaseException {
      return _categoriesFromCache();
    }
  }

  @override
  Future<List<City>> getLocations() async {
    try {
      final snap = await _db.collection('config').doc('locations').get();
      if (!snap.exists) return [];
      final raw = snap.data()!;
      final cities = (raw['cities'] as List<dynamic>)
          .map((e) => City.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((c) => c.active)
          .toList();
      await _prefs.setString(
        _kLocationsKey,
        jsonEncode(cities.map((c) => c.toJson()).toList()),
      );
      return cities;
    } on FirebaseException {
      return _locationsFromCache();
    }
  }

  List<Category> _categoriesFromCache() {
    final raw = _prefs.getString(_kCategoriesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<City> _locationsFromCache() {
    final raw = _prefs.getString(_kLocationsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => City.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
