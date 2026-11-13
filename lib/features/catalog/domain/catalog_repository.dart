import '../../../core/models/category.dart';
import '../../../core/models/location.dart';

export '../../../core/models/category.dart';
export '../../../core/models/location.dart';

abstract interface class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<City>> getLocations();
}
