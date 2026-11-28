// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Category {

 String get id; LocalizedText get names; String get iconKey; int get order; bool get featured; bool get active;/// Search synonyms per language (`fr`, `en`, `ln`, `sw`). Used by the
/// server to build `searchKeywords`; the app only carries them.
 Map<String, List<String>> get synonyms; int get listingCount;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Category;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.names, _this.names) || other.names == _this.names)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.featured, _this.featured) || other.featured == _this.featured)&&(identical(other.active, _this.active) || other.active == _this.active)&&const DeepCollectionEquality().equals(other.synonyms, _this.synonyms)&&(identical(other.listingCount, _this.listingCount) || other.listingCount == _this.listingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Category;
  return Object.hash(runtimeType,_this.id,_this.names,_this.iconKey,_this.order,_this.featured,_this.active,const DeepCollectionEquality().hash(_this.synonyms),_this.listingCount);
}

@override
String toString() {
  final _this = this as Category;
  return 'Category(id: ${_this.id}, names: ${_this.names}, iconKey: ${_this.iconKey}, order: ${_this.order}, featured: ${_this.featured}, active: ${_this.active}, synonyms: ${_this.synonyms}, listingCount: ${_this.listingCount})';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, LocalizedText names, String iconKey, int order, bool featured, bool active, Map<String, List<String>> synonyms, int listingCount
});


$LocalizedTextCopyWith<$Res> get names;

}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? names = null,Object? iconKey = null,Object? order = null,Object? featured = null,Object? active = null,Object? synonyms = null,Object? listingCount = null,}) {
  return _then(Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as LocalizedText,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,synonyms: null == synonyms ? _self.synonyms : synonyms // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,listingCount: null == listingCount ? _self.listingCount : listingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get names {
  
  return $LocalizedTextCopyWith<$Res>(_self.names, (value) {
    return _then(_self.copyWith(names: value));
  });
}
}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalizedText names,  String iconKey,  int order,  bool featured,  bool active,  Map<String, List<String>> synonyms,  int listingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.names,_that.iconKey,_that.order,_that.featured,_that.active,_that.synonyms,_that.listingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalizedText names,  String iconKey,  int order,  bool featured,  bool active,  Map<String, List<String>> synonyms,  int listingCount)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.names,_that.iconKey,_that.order,_that.featured,_that.active,_that.synonyms,_that.listingCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalizedText names,  String iconKey,  int order,  bool featured,  bool active,  Map<String, List<String>> synonyms,  int listingCount)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.names,_that.iconKey,_that.order,_that.featured,_that.active,_that.synonyms,_that.listingCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Category extends Category {
  const _Category({required this.id, required this.names, this.iconKey = '', this.order = 0, this.featured = false, this.active = true,  Map<String, List<String>> synonyms = const {}, this.listingCount = 0}): _synonyms = synonyms,super._();
  factory _Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

@override final  String id;
@override final  LocalizedText names;
@override@JsonKey() final  String iconKey;
@override@JsonKey() final  int order;
@override@JsonKey() final  bool featured;
@override@JsonKey() final  bool active;
/// Search synonyms per language (`fr`, `en`, `ln`, `sw`). Used by the
/// server to build `searchKeywords`; the app only carries them.
 final  Map<String, List<String>> _synonyms;
/// Search synonyms per language (`fr`, `en`, `ln`, `sw`). Used by the
/// server to build `searchKeywords`; the app only carries them.
@override@JsonKey() Map<String, List<String>> get synonyms {
  if (_synonyms is EqualUnmodifiableMapView) return _synonyms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_synonyms);
}

@override@JsonKey() final  int listingCount;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.names, names) || other.names == names)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.order, order) || other.order == order)&&(identical(other.featured, featured) || other.featured == featured)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other.synonyms, _synonyms)&&(identical(other.listingCount, listingCount) || other.listingCount == listingCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,names,iconKey,order,featured,active,const DeepCollectionEquality().hash(_synonyms),listingCount);
}

@override
String toString() {
    return 'Category(id: $id, names: $names, iconKey: $iconKey, order: $order, featured: $featured, active: $active, synonyms: $synonyms, listingCount: $listingCount)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalizedText names, String iconKey, int order, bool featured, bool active, Map<String, List<String>> synonyms, int listingCount
});


@override $LocalizedTextCopyWith<$Res> get names;

}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? names = null,Object? iconKey = null,Object? order = null,Object? featured = null,Object? active = null,Object? synonyms = null,Object? listingCount = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as LocalizedText,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as bool,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,synonyms: null == synonyms ? _self._synonyms : synonyms // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,listingCount: null == listingCount ? _self.listingCount : listingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res> get names {
  
  return $LocalizedTextCopyWith<$Res>(_self.names, (value) {
    return _then(_self.copyWith(names: value));
  });
}
}

// dart format on
