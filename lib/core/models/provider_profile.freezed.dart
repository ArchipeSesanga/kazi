// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderHeadline {

 String? get categoryId; double? get fromAmount; String? get fromCurrency; String? get fromPriceType;
/// Create a copy of ProviderHeadline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderHeadlineCopyWith<ProviderHeadline> get copyWith => _$ProviderHeadlineCopyWithImpl<ProviderHeadline>(this as ProviderHeadline, _$identity);

  /// Serializes this ProviderHeadline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderHeadline;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderHeadline&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.fromAmount, _this.fromAmount) || other.fromAmount == _this.fromAmount)&&(identical(other.fromCurrency, _this.fromCurrency) || other.fromCurrency == _this.fromCurrency)&&(identical(other.fromPriceType, _this.fromPriceType) || other.fromPriceType == _this.fromPriceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderHeadline;
  return Object.hash(runtimeType,_this.categoryId,_this.fromAmount,_this.fromCurrency,_this.fromPriceType);
}

@override
String toString() {
  final _this = this as ProviderHeadline;
  return 'ProviderHeadline(categoryId: ${_this.categoryId}, fromAmount: ${_this.fromAmount}, fromCurrency: ${_this.fromCurrency}, fromPriceType: ${_this.fromPriceType})';
}


}

/// @nodoc
abstract mixin class $ProviderHeadlineCopyWith<$Res>  {
  factory $ProviderHeadlineCopyWith(ProviderHeadline value, $Res Function(ProviderHeadline) _then) = _$ProviderHeadlineCopyWithImpl;
@useResult
$Res call({
 String? categoryId, double? fromAmount, String? fromCurrency, String? fromPriceType
});




}
/// @nodoc
class _$ProviderHeadlineCopyWithImpl<$Res>
    implements $ProviderHeadlineCopyWith<$Res> {
  _$ProviderHeadlineCopyWithImpl(this._self, this._then);

  final ProviderHeadline _self;
  final $Res Function(ProviderHeadline) _then;

/// Create a copy of ProviderHeadline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? fromAmount = freezed,Object? fromCurrency = freezed,Object? fromPriceType = freezed,}) {
  return _then(ProviderHeadline(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,fromAmount: freezed == fromAmount ? _self.fromAmount : fromAmount // ignore: cast_nullable_to_non_nullable
as double?,fromCurrency: freezed == fromCurrency ? _self.fromCurrency : fromCurrency // ignore: cast_nullable_to_non_nullable
as String?,fromPriceType: freezed == fromPriceType ? _self.fromPriceType : fromPriceType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderHeadline].
extension ProviderHeadlinePatterns on ProviderHeadline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderHeadline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderHeadline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderHeadline value)  $default,){
final _that = this;
switch (_that) {
case _ProviderHeadline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderHeadline value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderHeadline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  double? fromAmount,  String? fromCurrency,  String? fromPriceType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderHeadline() when $default != null:
return $default(_that.categoryId,_that.fromAmount,_that.fromCurrency,_that.fromPriceType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  double? fromAmount,  String? fromCurrency,  String? fromPriceType)  $default,) {final _that = this;
switch (_that) {
case _ProviderHeadline():
return $default(_that.categoryId,_that.fromAmount,_that.fromCurrency,_that.fromPriceType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  double? fromAmount,  String? fromCurrency,  String? fromPriceType)?  $default,) {final _that = this;
switch (_that) {
case _ProviderHeadline() when $default != null:
return $default(_that.categoryId,_that.fromAmount,_that.fromCurrency,_that.fromPriceType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderHeadline implements ProviderHeadline {
  const _ProviderHeadline({this.categoryId, this.fromAmount, this.fromCurrency, this.fromPriceType});
  factory _ProviderHeadline.fromJson(Map<String, dynamic> json) => _$ProviderHeadlineFromJson(json);

@override final  String? categoryId;
@override final  double? fromAmount;
@override final  String? fromCurrency;
@override final  String? fromPriceType;

/// Create a copy of ProviderHeadline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderHeadlineCopyWith<_ProviderHeadline> get copyWith => __$ProviderHeadlineCopyWithImpl<_ProviderHeadline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderHeadlineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderHeadline&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.fromAmount, fromAmount) || other.fromAmount == fromAmount)&&(identical(other.fromCurrency, fromCurrency) || other.fromCurrency == fromCurrency)&&(identical(other.fromPriceType, fromPriceType) || other.fromPriceType == fromPriceType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,fromAmount,fromCurrency,fromPriceType);
}

@override
String toString() {
    return 'ProviderHeadline(categoryId: $categoryId, fromAmount: $fromAmount, fromCurrency: $fromCurrency, fromPriceType: $fromPriceType)';
}


}

/// @nodoc
abstract mixin class _$ProviderHeadlineCopyWith<$Res> implements $ProviderHeadlineCopyWith<$Res> {
  factory _$ProviderHeadlineCopyWith(_ProviderHeadline value, $Res Function(_ProviderHeadline) _then) = __$ProviderHeadlineCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, double? fromAmount, String? fromCurrency, String? fromPriceType
});




}
/// @nodoc
class __$ProviderHeadlineCopyWithImpl<$Res>
    implements _$ProviderHeadlineCopyWith<$Res> {
  __$ProviderHeadlineCopyWithImpl(this._self, this._then);

  final _ProviderHeadline _self;
  final $Res Function(_ProviderHeadline) _then;

/// Create a copy of ProviderHeadline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? fromAmount = freezed,Object? fromCurrency = freezed,Object? fromPriceType = freezed,}) {
  return _then(_ProviderHeadline(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,fromAmount: freezed == fromAmount ? _self.fromAmount : fromAmount // ignore: cast_nullable_to_non_nullable
as double?,fromCurrency: freezed == fromCurrency ? _self.fromCurrency : fromCurrency // ignore: cast_nullable_to_non_nullable
as String?,fromPriceType: freezed == fromPriceType ? _self.fromPriceType : fromPriceType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProviderStats {

 int get contactsTotal; Map<String, int> get contactsByMonth;
/// Create a copy of ProviderStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderStatsCopyWith<ProviderStats> get copyWith => _$ProviderStatsCopyWithImpl<ProviderStats>(this as ProviderStats, _$identity);

  /// Serializes this ProviderStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderStats&&(identical(other.contactsTotal, _this.contactsTotal) || other.contactsTotal == _this.contactsTotal)&&const DeepCollectionEquality().equals(other.contactsByMonth, _this.contactsByMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderStats;
  return Object.hash(runtimeType,_this.contactsTotal,const DeepCollectionEquality().hash(_this.contactsByMonth));
}

@override
String toString() {
  final _this = this as ProviderStats;
  return 'ProviderStats(contactsTotal: ${_this.contactsTotal}, contactsByMonth: ${_this.contactsByMonth})';
}


}

/// @nodoc
abstract mixin class $ProviderStatsCopyWith<$Res>  {
  factory $ProviderStatsCopyWith(ProviderStats value, $Res Function(ProviderStats) _then) = _$ProviderStatsCopyWithImpl;
@useResult
$Res call({
 int contactsTotal, Map<String, int> contactsByMonth
});




}
/// @nodoc
class _$ProviderStatsCopyWithImpl<$Res>
    implements $ProviderStatsCopyWith<$Res> {
  _$ProviderStatsCopyWithImpl(this._self, this._then);

  final ProviderStats _self;
  final $Res Function(ProviderStats) _then;

/// Create a copy of ProviderStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactsTotal = null,Object? contactsByMonth = null,}) {
  return _then(ProviderStats(
contactsTotal: null == contactsTotal ? _self.contactsTotal : contactsTotal // ignore: cast_nullable_to_non_nullable
as int,contactsByMonth: null == contactsByMonth ? _self.contactsByMonth : contactsByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderStats].
extension ProviderStatsPatterns on ProviderStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderStats value)  $default,){
final _that = this;
switch (_that) {
case _ProviderStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderStats value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int contactsTotal,  Map<String, int> contactsByMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderStats() when $default != null:
return $default(_that.contactsTotal,_that.contactsByMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int contactsTotal,  Map<String, int> contactsByMonth)  $default,) {final _that = this;
switch (_that) {
case _ProviderStats():
return $default(_that.contactsTotal,_that.contactsByMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int contactsTotal,  Map<String, int> contactsByMonth)?  $default,) {final _that = this;
switch (_that) {
case _ProviderStats() when $default != null:
return $default(_that.contactsTotal,_that.contactsByMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderStats implements ProviderStats {
  const _ProviderStats({this.contactsTotal = 0,  Map<String, int> contactsByMonth = const {}}): _contactsByMonth = contactsByMonth;
  factory _ProviderStats.fromJson(Map<String, dynamic> json) => _$ProviderStatsFromJson(json);

@override@JsonKey() final  int contactsTotal;
 final  Map<String, int> _contactsByMonth;
@override@JsonKey() Map<String, int> get contactsByMonth {
  if (_contactsByMonth is EqualUnmodifiableMapView) return _contactsByMonth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contactsByMonth);
}


/// Create a copy of ProviderStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderStatsCopyWith<_ProviderStats> get copyWith => __$ProviderStatsCopyWithImpl<_ProviderStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderStats&&(identical(other.contactsTotal, contactsTotal) || other.contactsTotal == contactsTotal)&&const DeepCollectionEquality().equals(other.contactsByMonth, _contactsByMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,contactsTotal,const DeepCollectionEquality().hash(_contactsByMonth));
}

@override
String toString() {
    return 'ProviderStats(contactsTotal: $contactsTotal, contactsByMonth: $contactsByMonth)';
}


}

/// @nodoc
abstract mixin class _$ProviderStatsCopyWith<$Res> implements $ProviderStatsCopyWith<$Res> {
  factory _$ProviderStatsCopyWith(_ProviderStats value, $Res Function(_ProviderStats) _then) = __$ProviderStatsCopyWithImpl;
@override @useResult
$Res call({
 int contactsTotal, Map<String, int> contactsByMonth
});




}
/// @nodoc
class __$ProviderStatsCopyWithImpl<$Res>
    implements _$ProviderStatsCopyWith<$Res> {
  __$ProviderStatsCopyWithImpl(this._self, this._then);

  final _ProviderStats _self;
  final $Res Function(_ProviderStats) _then;

/// Create a copy of ProviderStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactsTotal = null,Object? contactsByMonth = null,}) {
  return _then(_ProviderStats(
contactsTotal: null == contactsTotal ? _self.contactsTotal : contactsTotal // ignore: cast_nullable_to_non_nullable
as int,contactsByMonth: null == contactsByMonth ? _self._contactsByMonth : contactsByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$PortfolioPhoto {

 String get id; String get path; String get url;
/// Create a copy of PortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortfolioPhotoCopyWith<PortfolioPhoto> get copyWith => _$PortfolioPhotoCopyWithImpl<PortfolioPhoto>(this as PortfolioPhoto, _$identity);

  /// Serializes this PortfolioPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PortfolioPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PortfolioPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PortfolioPhoto;
  return Object.hash(runtimeType,_this.id,_this.path,_this.url);
}

@override
String toString() {
  final _this = this as PortfolioPhoto;
  return 'PortfolioPhoto(id: ${_this.id}, path: ${_this.path}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $PortfolioPhotoCopyWith<$Res>  {
  factory $PortfolioPhotoCopyWith(PortfolioPhoto value, $Res Function(PortfolioPhoto) _then) = _$PortfolioPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String path, String url
});




}
/// @nodoc
class _$PortfolioPhotoCopyWithImpl<$Res>
    implements $PortfolioPhotoCopyWith<$Res> {
  _$PortfolioPhotoCopyWithImpl(this._self, this._then);

  final PortfolioPhoto _self;
  final $Res Function(PortfolioPhoto) _then;

/// Create a copy of PortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? url = null,}) {
  return _then(PortfolioPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PortfolioPhoto].
extension PortfolioPhotoPatterns on PortfolioPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PortfolioPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PortfolioPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PortfolioPhoto value)  $default,){
final _that = this;
switch (_that) {
case _PortfolioPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PortfolioPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _PortfolioPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String path,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PortfolioPhoto() when $default != null:
return $default(_that.id,_that.path,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String path,  String url)  $default,) {final _that = this;
switch (_that) {
case _PortfolioPhoto():
return $default(_that.id,_that.path,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String path,  String url)?  $default,) {final _that = this;
switch (_that) {
case _PortfolioPhoto() when $default != null:
return $default(_that.id,_that.path,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PortfolioPhoto implements PortfolioPhoto {
  const _PortfolioPhoto({required this.id, required this.path, required this.url});
  factory _PortfolioPhoto.fromJson(Map<String, dynamic> json) => _$PortfolioPhotoFromJson(json);

@override final  String id;
@override final  String path;
@override final  String url;

/// Create a copy of PortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortfolioPhotoCopyWith<_PortfolioPhoto> get copyWith => __$PortfolioPhotoCopyWithImpl<_PortfolioPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PortfolioPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PortfolioPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,path,url);
}

@override
String toString() {
    return 'PortfolioPhoto(id: $id, path: $path, url: $url)';
}


}

/// @nodoc
abstract mixin class _$PortfolioPhotoCopyWith<$Res> implements $PortfolioPhotoCopyWith<$Res> {
  factory _$PortfolioPhotoCopyWith(_PortfolioPhoto value, $Res Function(_PortfolioPhoto) _then) = __$PortfolioPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String url
});




}
/// @nodoc
class __$PortfolioPhotoCopyWithImpl<$Res>
    implements _$PortfolioPhotoCopyWith<$Res> {
  __$PortfolioPhotoCopyWithImpl(this._self, this._then);

  final _PortfolioPhoto _self;
  final $Res Function(_PortfolioPhoto) _then;

/// Create a copy of PortfolioPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? url = null,}) {
  return _then(_PortfolioPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProviderProfile {

 String get uid; String get displayName; String get bio; String? get photoUrl; String? get coverUrl; List<String> get categoryIds; String get city; String get baseCommune; List<String> get communes; String get whatsappNumber; String? get callNumber; int get yearsExperience; List<PortfolioPhoto> get portfolio; ProviderStatus get status; String? get statusReason; bool get verified; double get ratingAvg; int get ratingCount; int get ratingSum; int get listingCount; ProviderHeadline? get headline; ProviderStats? get stats; List<String> get searchKeywords;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get approvedAt;
/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderProfileCopyWith<ProviderProfile> get copyWith => _$ProviderProfileCopyWithImpl<ProviderProfile>(this as ProviderProfile, _$identity);

  /// Serializes this ProviderProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProviderProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderProfile&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.coverUrl, _this.coverUrl) || other.coverUrl == _this.coverUrl)&&const DeepCollectionEquality().equals(other.categoryIds, _this.categoryIds)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.baseCommune, _this.baseCommune) || other.baseCommune == _this.baseCommune)&&const DeepCollectionEquality().equals(other.communes, _this.communes)&&(identical(other.whatsappNumber, _this.whatsappNumber) || other.whatsappNumber == _this.whatsappNumber)&&(identical(other.callNumber, _this.callNumber) || other.callNumber == _this.callNumber)&&(identical(other.yearsExperience, _this.yearsExperience) || other.yearsExperience == _this.yearsExperience)&&const DeepCollectionEquality().equals(other.portfolio, _this.portfolio)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusReason, _this.statusReason) || other.statusReason == _this.statusReason)&&(identical(other.verified, _this.verified) || other.verified == _this.verified)&&(identical(other.ratingAvg, _this.ratingAvg) || other.ratingAvg == _this.ratingAvg)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.ratingSum, _this.ratingSum) || other.ratingSum == _this.ratingSum)&&(identical(other.listingCount, _this.listingCount) || other.listingCount == _this.listingCount)&&(identical(other.headline, _this.headline) || other.headline == _this.headline)&&(identical(other.stats, _this.stats) || other.stats == _this.stats)&&const DeepCollectionEquality().equals(other.searchKeywords, _this.searchKeywords)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.approvedAt, _this.approvedAt) || other.approvedAt == _this.approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderProfile;
  return Object.hashAll([runtimeType,_this.uid,_this.displayName,_this.bio,_this.photoUrl,_this.coverUrl,const DeepCollectionEquality().hash(_this.categoryIds),_this.city,_this.baseCommune,const DeepCollectionEquality().hash(_this.communes),_this.whatsappNumber,_this.callNumber,_this.yearsExperience,const DeepCollectionEquality().hash(_this.portfolio),_this.status,_this.statusReason,_this.verified,_this.ratingAvg,_this.ratingCount,_this.ratingSum,_this.listingCount,_this.headline,_this.stats,const DeepCollectionEquality().hash(_this.searchKeywords),_this.createdAt,_this.updatedAt,_this.approvedAt]);
}

@override
String toString() {
  final _this = this as ProviderProfile;
  return 'ProviderProfile(uid: ${_this.uid}, displayName: ${_this.displayName}, bio: ${_this.bio}, photoUrl: ${_this.photoUrl}, coverUrl: ${_this.coverUrl}, categoryIds: ${_this.categoryIds}, city: ${_this.city}, baseCommune: ${_this.baseCommune}, communes: ${_this.communes}, whatsappNumber: ${_this.whatsappNumber}, callNumber: ${_this.callNumber}, yearsExperience: ${_this.yearsExperience}, portfolio: ${_this.portfolio}, status: ${_this.status}, statusReason: ${_this.statusReason}, verified: ${_this.verified}, ratingAvg: ${_this.ratingAvg}, ratingCount: ${_this.ratingCount}, ratingSum: ${_this.ratingSum}, listingCount: ${_this.listingCount}, headline: ${_this.headline}, stats: ${_this.stats}, searchKeywords: ${_this.searchKeywords}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, approvedAt: ${_this.approvedAt})';
}


}

/// @nodoc
abstract mixin class $ProviderProfileCopyWith<$Res>  {
  factory $ProviderProfileCopyWith(ProviderProfile value, $Res Function(ProviderProfile) _then) = _$ProviderProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, String bio, String? photoUrl, String? coverUrl, List<String> categoryIds, String city, String baseCommune, List<String> communes, String whatsappNumber, String? callNumber, int yearsExperience, List<PortfolioPhoto> portfolio, ProviderStatus status, String? statusReason, bool verified, double ratingAvg, int ratingCount, int ratingSum, int listingCount, ProviderHeadline? headline, ProviderStats? stats, List<String> searchKeywords,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? approvedAt
});


$ProviderHeadlineCopyWith<$Res>? get headline;$ProviderStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class _$ProviderProfileCopyWithImpl<$Res>
    implements $ProviderProfileCopyWith<$Res> {
  _$ProviderProfileCopyWithImpl(this._self, this._then);

  final ProviderProfile _self;
  final $Res Function(ProviderProfile) _then;

/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? bio = null,Object? photoUrl = freezed,Object? coverUrl = freezed,Object? categoryIds = null,Object? city = null,Object? baseCommune = null,Object? communes = null,Object? whatsappNumber = null,Object? callNumber = freezed,Object? yearsExperience = null,Object? portfolio = null,Object? status = null,Object? statusReason = freezed,Object? verified = null,Object? ratingAvg = null,Object? ratingCount = null,Object? ratingSum = null,Object? listingCount = null,Object? headline = freezed,Object? stats = freezed,Object? searchKeywords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? approvedAt = freezed,}) {
  return _then(ProviderProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,baseCommune: null == baseCommune ? _self.baseCommune : baseCommune // ignore: cast_nullable_to_non_nullable
as String,communes: null == communes ? _self.communes : communes // ignore: cast_nullable_to_non_nullable
as List<String>,whatsappNumber: null == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String,callNumber: freezed == callNumber ? _self.callNumber : callNumber // ignore: cast_nullable_to_non_nullable
as String?,yearsExperience: null == yearsExperience ? _self.yearsExperience : yearsExperience // ignore: cast_nullable_to_non_nullable
as int,portfolio: null == portfolio ? _self.portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as List<PortfolioPhoto>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProviderStatus,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,ratingSum: null == ratingSum ? _self.ratingSum : ratingSum // ignore: cast_nullable_to_non_nullable
as int,listingCount: null == listingCount ? _self.listingCount : listingCount // ignore: cast_nullable_to_non_nullable
as int,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as ProviderHeadline?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ProviderStats?,searchKeywords: null == searchKeywords ? _self.searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderHeadlineCopyWith<$Res>? get headline {
    if (_self.headline == null) {
    return null;
  }

  return $ProviderHeadlineCopyWith<$Res>(_self.headline!, (value) {
    return _then(_self.copyWith(headline: value));
  });
}/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $ProviderStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProviderProfile].
extension ProviderProfilePatterns on ProviderProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderProfile value)  $default,){
final _that = this;
switch (_that) {
case _ProviderProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  String bio,  String? photoUrl,  String? coverUrl,  List<String> categoryIds,  String city,  String baseCommune,  List<String> communes,  String whatsappNumber,  String? callNumber,  int yearsExperience,  List<PortfolioPhoto> portfolio,  ProviderStatus status,  String? statusReason,  bool verified,  double ratingAvg,  int ratingCount,  int ratingSum,  int listingCount,  ProviderHeadline? headline,  ProviderStats? stats,  List<String> searchKeywords, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? approvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderProfile() when $default != null:
return $default(_that.uid,_that.displayName,_that.bio,_that.photoUrl,_that.coverUrl,_that.categoryIds,_that.city,_that.baseCommune,_that.communes,_that.whatsappNumber,_that.callNumber,_that.yearsExperience,_that.portfolio,_that.status,_that.statusReason,_that.verified,_that.ratingAvg,_that.ratingCount,_that.ratingSum,_that.listingCount,_that.headline,_that.stats,_that.searchKeywords,_that.createdAt,_that.updatedAt,_that.approvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  String bio,  String? photoUrl,  String? coverUrl,  List<String> categoryIds,  String city,  String baseCommune,  List<String> communes,  String whatsappNumber,  String? callNumber,  int yearsExperience,  List<PortfolioPhoto> portfolio,  ProviderStatus status,  String? statusReason,  bool verified,  double ratingAvg,  int ratingCount,  int ratingSum,  int listingCount,  ProviderHeadline? headline,  ProviderStats? stats,  List<String> searchKeywords, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? approvedAt)  $default,) {final _that = this;
switch (_that) {
case _ProviderProfile():
return $default(_that.uid,_that.displayName,_that.bio,_that.photoUrl,_that.coverUrl,_that.categoryIds,_that.city,_that.baseCommune,_that.communes,_that.whatsappNumber,_that.callNumber,_that.yearsExperience,_that.portfolio,_that.status,_that.statusReason,_that.verified,_that.ratingAvg,_that.ratingCount,_that.ratingSum,_that.listingCount,_that.headline,_that.stats,_that.searchKeywords,_that.createdAt,_that.updatedAt,_that.approvedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  String bio,  String? photoUrl,  String? coverUrl,  List<String> categoryIds,  String city,  String baseCommune,  List<String> communes,  String whatsappNumber,  String? callNumber,  int yearsExperience,  List<PortfolioPhoto> portfolio,  ProviderStatus status,  String? statusReason,  bool verified,  double ratingAvg,  int ratingCount,  int ratingSum,  int listingCount,  ProviderHeadline? headline,  ProviderStats? stats,  List<String> searchKeywords, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? approvedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProviderProfile() when $default != null:
return $default(_that.uid,_that.displayName,_that.bio,_that.photoUrl,_that.coverUrl,_that.categoryIds,_that.city,_that.baseCommune,_that.communes,_that.whatsappNumber,_that.callNumber,_that.yearsExperience,_that.portfolio,_that.status,_that.statusReason,_that.verified,_that.ratingAvg,_that.ratingCount,_that.ratingSum,_that.listingCount,_that.headline,_that.stats,_that.searchKeywords,_that.createdAt,_that.updatedAt,_that.approvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderProfile implements ProviderProfile {
  const _ProviderProfile({required this.uid, required this.displayName, this.bio = '', this.photoUrl, this.coverUrl,  List<String> categoryIds = const [], this.city = 'kinshasa', required this.baseCommune,  List<String> communes = const [], required this.whatsappNumber, this.callNumber, this.yearsExperience = 0,  List<PortfolioPhoto> portfolio = const [], this.status = ProviderStatus.pending, this.statusReason, this.verified = false, this.ratingAvg = 0.0, this.ratingCount = 0, this.ratingSum = 0, this.listingCount = 0, this.headline, this.stats,  List<String> searchKeywords = const [], @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.approvedAt}): _categoryIds = categoryIds,_communes = communes,_portfolio = portfolio,_searchKeywords = searchKeywords;
  factory _ProviderProfile.fromJson(Map<String, dynamic> json) => _$ProviderProfileFromJson(json);

@override final  String uid;
@override final  String displayName;
@override@JsonKey() final  String bio;
@override final  String? photoUrl;
@override final  String? coverUrl;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override@JsonKey() final  String city;
@override final  String baseCommune;
 final  List<String> _communes;
@override@JsonKey() List<String> get communes {
  if (_communes is EqualUnmodifiableListView) return _communes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_communes);
}

@override final  String whatsappNumber;
@override final  String? callNumber;
@override@JsonKey() final  int yearsExperience;
 final  List<PortfolioPhoto> _portfolio;
@override@JsonKey() List<PortfolioPhoto> get portfolio {
  if (_portfolio is EqualUnmodifiableListView) return _portfolio;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_portfolio);
}

@override@JsonKey() final  ProviderStatus status;
@override final  String? statusReason;
@override@JsonKey() final  bool verified;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override@JsonKey() final  int ratingSum;
@override@JsonKey() final  int listingCount;
@override final  ProviderHeadline? headline;
@override final  ProviderStats? stats;
 final  List<String> _searchKeywords;
@override@JsonKey() List<String> get searchKeywords {
  if (_searchKeywords is EqualUnmodifiableListView) return _searchKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchKeywords);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? approvedAt;

/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderProfileCopyWith<_ProviderProfile> get copyWith => __$ProviderProfileCopyWithImpl<_ProviderProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&const DeepCollectionEquality().equals(other.categoryIds, _categoryIds)&&(identical(other.city, city) || other.city == city)&&(identical(other.baseCommune, baseCommune) || other.baseCommune == baseCommune)&&const DeepCollectionEquality().equals(other.communes, _communes)&&(identical(other.whatsappNumber, whatsappNumber) || other.whatsappNumber == whatsappNumber)&&(identical(other.callNumber, callNumber) || other.callNumber == callNumber)&&(identical(other.yearsExperience, yearsExperience) || other.yearsExperience == yearsExperience)&&const DeepCollectionEquality().equals(other.portfolio, _portfolio)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusReason, statusReason) || other.statusReason == statusReason)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.ratingSum, ratingSum) || other.ratingSum == ratingSum)&&(identical(other.listingCount, listingCount) || other.listingCount == listingCount)&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.searchKeywords, _searchKeywords)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,uid,displayName,bio,photoUrl,coverUrl,const DeepCollectionEquality().hash(_categoryIds),city,baseCommune,const DeepCollectionEquality().hash(_communes),whatsappNumber,callNumber,yearsExperience,const DeepCollectionEquality().hash(_portfolio),status,statusReason,verified,ratingAvg,ratingCount,ratingSum,listingCount,headline,stats,const DeepCollectionEquality().hash(_searchKeywords),createdAt,updatedAt,approvedAt]);
}

@override
String toString() {
    return 'ProviderProfile(uid: $uid, displayName: $displayName, bio: $bio, photoUrl: $photoUrl, coverUrl: $coverUrl, categoryIds: $categoryIds, city: $city, baseCommune: $baseCommune, communes: $communes, whatsappNumber: $whatsappNumber, callNumber: $callNumber, yearsExperience: $yearsExperience, portfolio: $portfolio, status: $status, statusReason: $statusReason, verified: $verified, ratingAvg: $ratingAvg, ratingCount: $ratingCount, ratingSum: $ratingSum, listingCount: $listingCount, headline: $headline, stats: $stats, searchKeywords: $searchKeywords, createdAt: $createdAt, updatedAt: $updatedAt, approvedAt: $approvedAt)';
}


}

/// @nodoc
abstract mixin class _$ProviderProfileCopyWith<$Res> implements $ProviderProfileCopyWith<$Res> {
  factory _$ProviderProfileCopyWith(_ProviderProfile value, $Res Function(_ProviderProfile) _then) = __$ProviderProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, String bio, String? photoUrl, String? coverUrl, List<String> categoryIds, String city, String baseCommune, List<String> communes, String whatsappNumber, String? callNumber, int yearsExperience, List<PortfolioPhoto> portfolio, ProviderStatus status, String? statusReason, bool verified, double ratingAvg, int ratingCount, int ratingSum, int listingCount, ProviderHeadline? headline, ProviderStats? stats, List<String> searchKeywords,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? approvedAt
});


@override $ProviderHeadlineCopyWith<$Res>? get headline;@override $ProviderStatsCopyWith<$Res>? get stats;

}
/// @nodoc
class __$ProviderProfileCopyWithImpl<$Res>
    implements _$ProviderProfileCopyWith<$Res> {
  __$ProviderProfileCopyWithImpl(this._self, this._then);

  final _ProviderProfile _self;
  final $Res Function(_ProviderProfile) _then;

/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? bio = null,Object? photoUrl = freezed,Object? coverUrl = freezed,Object? categoryIds = null,Object? city = null,Object? baseCommune = null,Object? communes = null,Object? whatsappNumber = null,Object? callNumber = freezed,Object? yearsExperience = null,Object? portfolio = null,Object? status = null,Object? statusReason = freezed,Object? verified = null,Object? ratingAvg = null,Object? ratingCount = null,Object? ratingSum = null,Object? listingCount = null,Object? headline = freezed,Object? stats = freezed,Object? searchKeywords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? approvedAt = freezed,}) {
  return _then(_ProviderProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,baseCommune: null == baseCommune ? _self.baseCommune : baseCommune // ignore: cast_nullable_to_non_nullable
as String,communes: null == communes ? _self._communes : communes // ignore: cast_nullable_to_non_nullable
as List<String>,whatsappNumber: null == whatsappNumber ? _self.whatsappNumber : whatsappNumber // ignore: cast_nullable_to_non_nullable
as String,callNumber: freezed == callNumber ? _self.callNumber : callNumber // ignore: cast_nullable_to_non_nullable
as String?,yearsExperience: null == yearsExperience ? _self.yearsExperience : yearsExperience // ignore: cast_nullable_to_non_nullable
as int,portfolio: null == portfolio ? _self._portfolio : portfolio // ignore: cast_nullable_to_non_nullable
as List<PortfolioPhoto>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProviderStatus,statusReason: freezed == statusReason ? _self.statusReason : statusReason // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,ratingSum: null == ratingSum ? _self.ratingSum : ratingSum // ignore: cast_nullable_to_non_nullable
as int,listingCount: null == listingCount ? _self.listingCount : listingCount // ignore: cast_nullable_to_non_nullable
as int,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as ProviderHeadline?,stats: freezed == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as ProviderStats?,searchKeywords: null == searchKeywords ? _self._searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderHeadlineCopyWith<$Res>? get headline {
    if (_self.headline == null) {
    return null;
  }

  return $ProviderHeadlineCopyWith<$Res>(_self.headline!, (value) {
    return _then(_self.copyWith(headline: value));
  });
}/// Create a copy of ProviderProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderStatsCopyWith<$Res>? get stats {
    if (_self.stats == null) {
    return null;
  }

  return $ProviderStatsCopyWith<$Res>(_self.stats!, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
