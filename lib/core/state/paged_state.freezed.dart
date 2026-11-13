// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paged_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PagedState<T> {

 List<T> get items; bool get isLoadingFirst; bool get isLoadingMore; bool get hasMore; AppException? get error; Object? get cursor;
/// Create a copy of PagedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedStateCopyWith<T, PagedState<T>> get copyWith => _$PagedStateCopyWithImpl<T, PagedState<T>>(this as PagedState<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PagedState<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedState<T>&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.isLoadingFirst, _this.isLoadingFirst) || other.isLoadingFirst == _this.isLoadingFirst)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.cursor, _this.cursor));
}


@override
int get hashCode {
  final _this = this as PagedState<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.isLoadingFirst,_this.isLoadingMore,_this.hasMore,_this.error,const DeepCollectionEquality().hash(_this.cursor));
}

@override
String toString() {
  final _this = this as PagedState<T>;
  return 'PagedState<$T>(items: ${_this.items}, isLoadingFirst: ${_this.isLoadingFirst}, isLoadingMore: ${_this.isLoadingMore}, hasMore: ${_this.hasMore}, error: ${_this.error}, cursor: ${_this.cursor})';
}


}

/// @nodoc
abstract mixin class $PagedStateCopyWith<T,$Res>  {
  factory $PagedStateCopyWith(PagedState<T> value, $Res Function(PagedState<T>) _then) = _$PagedStateCopyWithImpl;
@useResult
$Res call({
 List<T> items, bool isLoadingFirst, bool isLoadingMore, bool hasMore, AppException? error, Object? cursor
});




}
/// @nodoc
class _$PagedStateCopyWithImpl<T,$Res>
    implements $PagedStateCopyWith<T, $Res> {
  _$PagedStateCopyWithImpl(this._self, this._then);

  final PagedState<T> _self;
  final $Res Function(PagedState<T>) _then;

/// Create a copy of PagedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? isLoadingFirst = null,Object? isLoadingMore = null,Object? hasMore = null,Object? error = freezed,Object? cursor = freezed,}) {
  return _then(PagedState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,isLoadingFirst: null == isLoadingFirst ? _self.isLoadingFirst : isLoadingFirst // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException?,cursor: freezed == cursor ? _self.cursor : cursor ,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedState].
extension PagedStatePatterns<T> on PagedState<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedState<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedState<T> value)  $default,){
final _that = this;
switch (_that) {
case _PagedState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedState<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PagedState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  bool isLoadingFirst,  bool isLoadingMore,  bool hasMore,  AppException? error,  Object? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedState() when $default != null:
return $default(_that.items,_that.isLoadingFirst,_that.isLoadingMore,_that.hasMore,_that.error,_that.cursor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  bool isLoadingFirst,  bool isLoadingMore,  bool hasMore,  AppException? error,  Object? cursor)  $default,) {final _that = this;
switch (_that) {
case _PagedState():
return $default(_that.items,_that.isLoadingFirst,_that.isLoadingMore,_that.hasMore,_that.error,_that.cursor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  bool isLoadingFirst,  bool isLoadingMore,  bool hasMore,  AppException? error,  Object? cursor)?  $default,) {final _that = this;
switch (_that) {
case _PagedState() when $default != null:
return $default(_that.items,_that.isLoadingFirst,_that.isLoadingMore,_that.hasMore,_that.error,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _PagedState<T> implements PagedState<T> {
  const _PagedState({ List<T> items = const [], this.isLoadingFirst = false, this.isLoadingMore = false, this.hasMore = true, this.error, this.cursor}): _items = items;
  

 final  List<T> _items;
@override@JsonKey() List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool isLoadingFirst;
@override@JsonKey() final  bool isLoadingMore;
@override@JsonKey() final  bool hasMore;
@override final  AppException? error;
@override final  Object? cursor;

/// Create a copy of PagedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedStateCopyWith<T, _PagedState<T>> get copyWith => __$PagedStateCopyWithImpl<T, _PagedState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedState<T>&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.isLoadingFirst, isLoadingFirst) || other.isLoadingFirst == isLoadingFirst)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.cursor, cursor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),isLoadingFirst,isLoadingMore,hasMore,error,const DeepCollectionEquality().hash(cursor));
}

@override
String toString() {
    return 'PagedState<$T>(items: $items, isLoadingFirst: $isLoadingFirst, isLoadingMore: $isLoadingMore, hasMore: $hasMore, error: $error, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$PagedStateCopyWith<T,$Res> implements $PagedStateCopyWith<T, $Res> {
  factory _$PagedStateCopyWith(_PagedState<T> value, $Res Function(_PagedState<T>) _then) = __$PagedStateCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, bool isLoadingFirst, bool isLoadingMore, bool hasMore, AppException? error, Object? cursor
});




}
/// @nodoc
class __$PagedStateCopyWithImpl<T,$Res>
    implements _$PagedStateCopyWith<T, $Res> {
  __$PagedStateCopyWithImpl(this._self, this._then);

  final _PagedState<T> _self;
  final $Res Function(_PagedState<T>) _then;

/// Create a copy of PagedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? isLoadingFirst = null,Object? isLoadingMore = null,Object? hasMore = null,Object? error = freezed,Object? cursor = freezed,}) {
  return _then(_PagedState<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,isLoadingFirst: null == isLoadingFirst ? _self.isLoadingFirst : isLoadingFirst // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppException?,cursor: freezed == cursor ? _self.cursor : cursor ,
  ));
}


}

// dart format on
