import '../errors/app_exception.dart';

// TODO(KZ-010): convert to @freezed once build_runner is configured.
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.isLoadingFirst = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.cursor,
  });

  final List<T> items;
  final bool isLoadingFirst;
  final bool isLoadingMore;
  final bool hasMore;
  final AppException? error;

  // Last DocumentSnapshot — kept opaque to the UI layer.
  final Object? cursor;

  PagedState<T> copyWith({
    List<T>? items,
    bool? isLoadingFirst,
    bool? isLoadingMore,
    bool? hasMore,
    AppException? error,
    Object? cursor,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return PagedState<T>(
      items: items ?? this.items,
      isLoadingFirst: isLoadingFirst ?? this.isLoadingFirst,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
    );
  }
}

class PageResult<T> {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.cursor,
  });

  final List<T> items;
  final bool hasMore;

  // Last DocumentSnapshot; opaque outside the data layer.
  final Object? cursor;
}
