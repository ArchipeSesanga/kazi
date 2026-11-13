enum SearchSort { relevance, recent }

class SearchQuery {
  const SearchQuery({
    this.keyword,
    this.categoryId,
    this.commune,
    this.city = 'kinshasa',
    this.verifiedOnly = false,
    this.minRating,
    this.sort = SearchSort.relevance,
  });

  final String? keyword;
  final String? categoryId;
  final String? commune;
  final String city;
  final bool verifiedOnly;
  final double? minRating;
  final SearchSort sort;

  SearchQuery copyWith({
    String? keyword,
    String? categoryId,
    String? commune,
    String? city,
    bool? verifiedOnly,
    double? minRating,
    SearchSort? sort,
  }) =>
      SearchQuery(
        keyword: keyword ?? this.keyword,
        categoryId: categoryId ?? this.categoryId,
        commune: commune ?? this.commune,
        city: city ?? this.city,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        minRating: minRating ?? this.minRating,
        sort: sort ?? this.sort,
      );

  static SearchQuery fromUri(Uri uri) => SearchQuery(
        keyword: uri.queryParameters['q'],
        categoryId: uri.queryParameters['cat'],
        commune: uri.queryParameters['commune'],
        city: uri.queryParameters['city'] ?? 'kinshasa',
        verifiedOnly: uri.queryParameters['verified'] == 'true',
        minRating: double.tryParse(uri.queryParameters['rating'] ?? ''),
        sort: uri.queryParameters['sort'] == 'recent'
            ? SearchSort.recent
            : SearchSort.relevance,
      );
}
