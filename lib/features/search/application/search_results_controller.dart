import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/models/listing.dart';
import '../../../core/state/paged_state.dart';
import '../domain/search_repository.dart';

export '../domain/search_repository.dart' show SearchQuery, SearchSort;

class SearchResultsController extends ChangeNotifier {
  SearchResultsController(this._repo, SearchQuery initialQuery)
      : _query = initialQuery;

  final SearchRepository _repo;

  SearchQuery _query;
  PagedState<Listing> _state = const PagedState(isLoadingFirst: true);
  Timer? _debounce;

  SearchQuery get query => _query;
  PagedState<Listing> get state => _state;

  void init() => _fetch();

  void updateKeyword(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final kw = raw.trim().isEmpty ? null : raw.trim();
      _applyNewQuery(SearchQuery(
        keyword: kw,
        categoryId: _query.categoryId,
        commune: _query.commune,
        city: _query.city,
        verifiedOnly: _query.verifiedOnly,
        minRating: _query.minRating,
        sort: _query.sort,
      ));
    });
  }

  void toggleVerified() {
    _applyNewQuery(SearchQuery(
      keyword: _query.keyword,
      categoryId: _query.categoryId,
      commune: _query.commune,
      city: _query.city,
      verifiedOnly: !_query.verifiedOnly,
      minRating: _query.minRating,
      sort: _query.sort,
    ));
  }

  void toggleTopRated() {
    final newRating = _query.minRating == 4.0 ? null : 4.0;
    _applyNewQuery(SearchQuery(
      keyword: _query.keyword,
      categoryId: _query.categoryId,
      commune: _query.commune,
      city: _query.city,
      verifiedOnly: _query.verifiedOnly,
      minRating: newRating,
      sort: _query.sort,
    ));
  }

  void applyFiltersFromSheet(SearchQuery newQuery) => _applyNewQuery(newQuery);

  Future<void> loadMore() async {
    if (_state.isLoadingFirst || _state.isLoadingMore || !_state.hasMore) return;
    _state = _state.copyWith(isLoadingMore: true, error: null);
    notifyListeners();
    try {
      final result = await _repo.search(_query, cursor: _state.cursor);
      _state = _state.copyWith(
        items: [..._state.items, ...result.items],
        hasMore: result.hasMore,
        cursor: result.cursor,
        isLoadingMore: false,
      );
    } catch (e, s) {
      _state = _state.copyWith(
        isLoadingMore: false,
        error: mapException(e, s),
      );
    }
    notifyListeners();
  }

  Future<void> refresh() => _fetch();

  void _applyNewQuery(SearchQuery q) {
    _debounce?.cancel();
    _query = q;
    _fetch();
  }

  Future<void> _fetch() async {
    _state = const PagedState(isLoadingFirst: true);
    notifyListeners();
    try {
      final result = await _repo.search(_query);
      _state = PagedState(
        items: result.items,
        hasMore: result.hasMore,
        cursor: result.cursor,
      );
    } catch (e, s) {
      _state = PagedState(
        hasMore: false,
        error: mapException(e, s),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
