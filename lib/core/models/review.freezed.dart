// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Review {

 String get authorUid; String get authorName; String? get authorPhotoUrl; int get rating; String get text; String? get providerReply;@TimestampConverter() DateTime? get providerReplyAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);

  /// Serializes this Review to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Review;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.authorUid, _this.authorUid) || other.authorUid == _this.authorUid)&&(identical(other.authorName, _this.authorName) || other.authorName == _this.authorName)&&(identical(other.authorPhotoUrl, _this.authorPhotoUrl) || other.authorPhotoUrl == _this.authorPhotoUrl)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.providerReply, _this.providerReply) || other.providerReply == _this.providerReply)&&(identical(other.providerReplyAt, _this.providerReplyAt) || other.providerReplyAt == _this.providerReplyAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Review;
  return Object.hash(runtimeType,_this.authorUid,_this.authorName,_this.authorPhotoUrl,_this.rating,_this.text,_this.providerReply,_this.providerReplyAt,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Review;
  return 'Review(authorUid: ${_this.authorUid}, authorName: ${_this.authorName}, authorPhotoUrl: ${_this.authorPhotoUrl}, rating: ${_this.rating}, text: ${_this.text}, providerReply: ${_this.providerReply}, providerReplyAt: ${_this.providerReplyAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String authorUid, String authorName, String? authorPhotoUrl, int rating, String text, String? providerReply,@TimestampConverter() DateTime? providerReplyAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authorUid = null,Object? authorName = null,Object? authorPhotoUrl = freezed,Object? rating = null,Object? text = null,Object? providerReply = freezed,Object? providerReplyAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Review(
authorUid: null == authorUid ? _self.authorUid : authorUid // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorPhotoUrl: freezed == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,providerReply: freezed == providerReply ? _self.providerReply : providerReply // ignore: cast_nullable_to_non_nullable
as String?,providerReplyAt: freezed == providerReplyAt ? _self.providerReplyAt : providerReplyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String authorUid,  String authorName,  String? authorPhotoUrl,  int rating,  String text,  String? providerReply, @TimestampConverter()  DateTime? providerReplyAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.rating,_that.text,_that.providerReply,_that.providerReplyAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String authorUid,  String authorName,  String? authorPhotoUrl,  int rating,  String text,  String? providerReply, @TimestampConverter()  DateTime? providerReplyAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.rating,_that.text,_that.providerReply,_that.providerReplyAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String authorUid,  String authorName,  String? authorPhotoUrl,  int rating,  String text,  String? providerReply, @TimestampConverter()  DateTime? providerReplyAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.authorUid,_that.authorName,_that.authorPhotoUrl,_that.rating,_that.text,_that.providerReply,_that.providerReplyAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Review implements Review {
  const _Review({required this.authorUid, required this.authorName, this.authorPhotoUrl, required this.rating, this.text = '', this.providerReply, @TimestampConverter() this.providerReplyAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt});
  factory _Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

@override final  String authorUid;
@override final  String authorName;
@override final  String? authorPhotoUrl;
@override final  int rating;
@override@JsonKey() final  String text;
@override final  String? providerReply;
@override@TimestampConverter() final  DateTime? providerReplyAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.authorUid, authorUid) || other.authorUid == authorUid)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorPhotoUrl, authorPhotoUrl) || other.authorPhotoUrl == authorPhotoUrl)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.text, text) || other.text == text)&&(identical(other.providerReply, providerReply) || other.providerReply == providerReply)&&(identical(other.providerReplyAt, providerReplyAt) || other.providerReplyAt == providerReplyAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,authorUid,authorName,authorPhotoUrl,rating,text,providerReply,providerReplyAt,createdAt,updatedAt);
}

@override
String toString() {
    return 'Review(authorUid: $authorUid, authorName: $authorName, authorPhotoUrl: $authorPhotoUrl, rating: $rating, text: $text, providerReply: $providerReply, providerReplyAt: $providerReplyAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String authorUid, String authorName, String? authorPhotoUrl, int rating, String text, String? providerReply,@TimestampConverter() DateTime? providerReplyAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authorUid = null,Object? authorName = null,Object? authorPhotoUrl = freezed,Object? rating = null,Object? text = null,Object? providerReply = freezed,Object? providerReplyAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Review(
authorUid: null == authorUid ? _self.authorUid : authorUid // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorPhotoUrl: freezed == authorPhotoUrl ? _self.authorPhotoUrl : authorPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,providerReply: freezed == providerReply ? _self.providerReply : providerReply // ignore: cast_nullable_to_non_nullable
as String?,providerReplyAt: freezed == providerReplyAt ? _self.providerReplyAt : providerReplyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
