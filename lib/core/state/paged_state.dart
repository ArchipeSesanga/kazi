import 'package:freezed_annotation/freezed_annotation.dart';

import '../errors/app_exception.dart';

part 'paged_state.freezed.dart';

@freezed
abstract class PagedState<T> with _$PagedState<T> {
  const factory PagedState({
    @Default([]) List<T> items,
    @Default(false) bool isLoadingFirst,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    AppException? error,
    Object? cursor,
  }) = _PagedState<T>;
}

/// Returned by repositories; cursor is opaque outside the data layer.
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.cursor,
  });

  final List<T> items;
  final bool hasMore;
  final Object? cursor;
}
