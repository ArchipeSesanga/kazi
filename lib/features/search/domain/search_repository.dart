import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';
import 'search_query.dart';

export 'search_query.dart';

abstract interface class SearchRepository {
  Future<PageResult<Listing>> search(SearchQuery query, {Object? cursor});
}
