// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingPhoto {

 String get id; String get path; String get url;
/// Create a copy of ListingPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingPhotoCopyWith<ListingPhoto> get copyWith => _$ListingPhotoCopyWithImpl<ListingPhoto>(this as ListingPhoto, _$identity);

  /// Serializes this ListingPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingPhoto;
  return Object.hash(runtimeType,_this.id,_this.path,_this.url);
}

@override
String toString() {
  final _this = this as ListingPhoto;
  return 'ListingPhoto(id: ${_this.id}, path: ${_this.path}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $ListingPhotoCopyWith<$Res>  {
  factory $ListingPhotoCopyWith(ListingPhoto value, $Res Function(ListingPhoto) _then) = _$ListingPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String path, String url
});




}
/// @nodoc
class _$ListingPhotoCopyWithImpl<$Res>
    implements $ListingPhotoCopyWith<$Res> {
  _$ListingPhotoCopyWithImpl(this._self, this._then);

  final ListingPhoto _self;
  final $Res Function(ListingPhoto) _then;

/// Create a copy of ListingPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? url = null,}) {
  return _then(ListingPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingPhoto].
extension ListingPhotoPatterns on ListingPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ListingPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ListingPhoto() when $default != null:
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
case _ListingPhoto() when $default != null:
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
case _ListingPhoto():
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
case _ListingPhoto() when $default != null:
return $default(_that.id,_that.path,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingPhoto implements ListingPhoto {
  const _ListingPhoto({required this.id, required this.path, required this.url});
  factory _ListingPhoto.fromJson(Map<String, dynamic> json) => _$ListingPhotoFromJson(json);

@override final  String id;
@override final  String path;
@override final  String url;

/// Create a copy of ListingPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingPhotoCopyWith<_ListingPhoto> get copyWith => __$ListingPhotoCopyWithImpl<_ListingPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,path,url);
}

@override
String toString() {
    return 'ListingPhoto(id: $id, path: $path, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ListingPhotoCopyWith<$Res> implements $ListingPhotoCopyWith<$Res> {
  factory _$ListingPhotoCopyWith(_ListingPhoto value, $Res Function(_ListingPhoto) _then) = __$ListingPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String url
});




}
/// @nodoc
class __$ListingPhotoCopyWithImpl<$Res>
    implements _$ListingPhotoCopyWith<$Res> {
  __$ListingPhotoCopyWithImpl(this._self, this._then);

  final _ListingPhoto _self;
  final $Res Function(_ListingPhoto) _then;

/// Create a copy of ListingPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? url = null,}) {
  return _then(_ListingPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Listing {

 String get id; String get providerId; String get title; String get description; String get categoryId; PriceType get priceType; double? get priceAmount; Currency get currency; List<ListingPhoto> get photos; String get city; List<String> get communes; ListingStatus get status; bool get visible; Moderation get moderation; String? get moderationReason; String? get providerStatus; String? get providerName; String? get providerPhotoUrl; bool get providerVerified; double get ratingAvg; int get ratingCount; LocalizedText? get categoryName; List<String> get searchKeywords; int get contactCount;@TimestampConverter() DateTime? get publishedAt;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Listing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.providerId, _this.providerId) || other.providerId == _this.providerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.priceType, _this.priceType) || other.priceType == _this.priceType)&&(identical(other.priceAmount, _this.priceAmount) || other.priceAmount == _this.priceAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.city, _this.city) || other.city == _this.city)&&const DeepCollectionEquality().equals(other.communes, _this.communes)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.visible, _this.visible) || other.visible == _this.visible)&&(identical(other.moderation, _this.moderation) || other.moderation == _this.moderation)&&(identical(other.moderationReason, _this.moderationReason) || other.moderationReason == _this.moderationReason)&&(identical(other.providerStatus, _this.providerStatus) || other.providerStatus == _this.providerStatus)&&(identical(other.providerName, _this.providerName) || other.providerName == _this.providerName)&&(identical(other.providerPhotoUrl, _this.providerPhotoUrl) || other.providerPhotoUrl == _this.providerPhotoUrl)&&(identical(other.providerVerified, _this.providerVerified) || other.providerVerified == _this.providerVerified)&&(identical(other.ratingAvg, _this.ratingAvg) || other.ratingAvg == _this.ratingAvg)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&const DeepCollectionEquality().equals(other.searchKeywords, _this.searchKeywords)&&(identical(other.contactCount, _this.contactCount) || other.contactCount == _this.contactCount)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Listing;
  return Object.hashAll([runtimeType,_this.id,_this.providerId,_this.title,_this.description,_this.categoryId,_this.priceType,_this.priceAmount,_this.currency,const DeepCollectionEquality().hash(_this.photos),_this.city,const DeepCollectionEquality().hash(_this.communes),_this.status,_this.visible,_this.moderation,_this.moderationReason,_this.providerStatus,_this.providerName,_this.providerPhotoUrl,_this.providerVerified,_this.ratingAvg,_this.ratingCount,_this.categoryName,const DeepCollectionEquality().hash(_this.searchKeywords),_this.contactCount,_this.publishedAt,_this.createdAt,_this.updatedAt]);
}

@override
String toString() {
  final _this = this as Listing;
  return 'Listing(id: ${_this.id}, providerId: ${_this.providerId}, title: ${_this.title}, description: ${_this.description}, categoryId: ${_this.categoryId}, priceType: ${_this.priceType}, priceAmount: ${_this.priceAmount}, currency: ${_this.currency}, photos: ${_this.photos}, city: ${_this.city}, communes: ${_this.communes}, status: ${_this.status}, visible: ${_this.visible}, moderation: ${_this.moderation}, moderationReason: ${_this.moderationReason}, providerStatus: ${_this.providerStatus}, providerName: ${_this.providerName}, providerPhotoUrl: ${_this.providerPhotoUrl}, providerVerified: ${_this.providerVerified}, ratingAvg: ${_this.ratingAvg}, ratingCount: ${_this.ratingCount}, categoryName: ${_this.categoryName}, searchKeywords: ${_this.searchKeywords}, contactCount: ${_this.contactCount}, publishedAt: ${_this.publishedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String providerId, String title, String description, String categoryId, PriceType priceType, double? priceAmount, Currency currency, List<ListingPhoto> photos, String city, List<String> communes, ListingStatus status, bool visible, Moderation moderation, String? moderationReason, String? providerStatus, String? providerName, String? providerPhotoUrl, bool providerVerified, double ratingAvg, int ratingCount, LocalizedText? categoryName, List<String> searchKeywords, int contactCount,@TimestampConverter() DateTime? publishedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$LocalizedTextCopyWith<$Res>? get categoryName;

}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? providerId = null,Object? title = null,Object? description = null,Object? categoryId = null,Object? priceType = null,Object? priceAmount = freezed,Object? currency = null,Object? photos = null,Object? city = null,Object? communes = null,Object? status = null,Object? visible = null,Object? moderation = null,Object? moderationReason = freezed,Object? providerStatus = freezed,Object? providerName = freezed,Object? providerPhotoUrl = freezed,Object? providerVerified = null,Object? ratingAvg = null,Object? ratingCount = null,Object? categoryName = freezed,Object? searchKeywords = null,Object? contactCount = null,Object? publishedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,priceType: null == priceType ? _self.priceType : priceType // ignore: cast_nullable_to_non_nullable
as PriceType,priceAmount: freezed == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as double?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<ListingPhoto>,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,communes: null == communes ? _self.communes : communes // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,moderation: null == moderation ? _self.moderation : moderation // ignore: cast_nullable_to_non_nullable
as Moderation,moderationReason: freezed == moderationReason ? _self.moderationReason : moderationReason // ignore: cast_nullable_to_non_nullable
as String?,providerStatus: freezed == providerStatus ? _self.providerStatus : providerStatus // ignore: cast_nullable_to_non_nullable
as String?,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,providerPhotoUrl: freezed == providerPhotoUrl ? _self.providerPhotoUrl : providerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,providerVerified: null == providerVerified ? _self.providerVerified : providerVerified // ignore: cast_nullable_to_non_nullable
as bool,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as LocalizedText?,searchKeywords: null == searchKeywords ? _self.searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,contactCount: null == contactCount ? _self.contactCount : contactCount // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res>? get categoryName {
    if (_self.categoryName == null) {
    return null;
  }

  return $LocalizedTextCopyWith<$Res>(_self.categoryName!, (value) {
    return _then(_self.copyWith(categoryName: value));
  });
}
}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String providerId,  String title,  String description,  String categoryId,  PriceType priceType,  double? priceAmount,  Currency currency,  List<ListingPhoto> photos,  String city,  List<String> communes,  ListingStatus status,  bool visible,  Moderation moderation,  String? moderationReason,  String? providerStatus,  String? providerName,  String? providerPhotoUrl,  bool providerVerified,  double ratingAvg,  int ratingCount,  LocalizedText? categoryName,  List<String> searchKeywords,  int contactCount, @TimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.providerId,_that.title,_that.description,_that.categoryId,_that.priceType,_that.priceAmount,_that.currency,_that.photos,_that.city,_that.communes,_that.status,_that.visible,_that.moderation,_that.moderationReason,_that.providerStatus,_that.providerName,_that.providerPhotoUrl,_that.providerVerified,_that.ratingAvg,_that.ratingCount,_that.categoryName,_that.searchKeywords,_that.contactCount,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String providerId,  String title,  String description,  String categoryId,  PriceType priceType,  double? priceAmount,  Currency currency,  List<ListingPhoto> photos,  String city,  List<String> communes,  ListingStatus status,  bool visible,  Moderation moderation,  String? moderationReason,  String? providerStatus,  String? providerName,  String? providerPhotoUrl,  bool providerVerified,  double ratingAvg,  int ratingCount,  LocalizedText? categoryName,  List<String> searchKeywords,  int contactCount, @TimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.providerId,_that.title,_that.description,_that.categoryId,_that.priceType,_that.priceAmount,_that.currency,_that.photos,_that.city,_that.communes,_that.status,_that.visible,_that.moderation,_that.moderationReason,_that.providerStatus,_that.providerName,_that.providerPhotoUrl,_that.providerVerified,_that.ratingAvg,_that.ratingCount,_that.categoryName,_that.searchKeywords,_that.contactCount,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String providerId,  String title,  String description,  String categoryId,  PriceType priceType,  double? priceAmount,  Currency currency,  List<ListingPhoto> photos,  String city,  List<String> communes,  ListingStatus status,  bool visible,  Moderation moderation,  String? moderationReason,  String? providerStatus,  String? providerName,  String? providerPhotoUrl,  bool providerVerified,  double ratingAvg,  int ratingCount,  LocalizedText? categoryName,  List<String> searchKeywords,  int contactCount, @TimestampConverter()  DateTime? publishedAt, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.providerId,_that.title,_that.description,_that.categoryId,_that.priceType,_that.priceAmount,_that.currency,_that.photos,_that.city,_that.communes,_that.status,_that.visible,_that.moderation,_that.moderationReason,_that.providerStatus,_that.providerName,_that.providerPhotoUrl,_that.providerVerified,_that.ratingAvg,_that.ratingCount,_that.categoryName,_that.searchKeywords,_that.contactCount,_that.publishedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing implements Listing {
  const _Listing({required this.id, required this.providerId, required this.title, this.description = '', required this.categoryId, required this.priceType, this.priceAmount, this.currency = Currency.usd,  List<ListingPhoto> photos = const [], required this.city,  List<String> communes = const [], this.status = ListingStatus.draft, this.visible = false, this.moderation = Moderation.ok, this.moderationReason, this.providerStatus, this.providerName, this.providerPhotoUrl, this.providerVerified = false, this.ratingAvg = 0.0, this.ratingCount = 0, this.categoryName,  List<String> searchKeywords = const [], this.contactCount = 0, @TimestampConverter() this.publishedAt, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _photos = photos,_communes = communes,_searchKeywords = searchKeywords;
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String providerId;
@override final  String title;
@override@JsonKey() final  String description;
@override final  String categoryId;
@override final  PriceType priceType;
@override final  double? priceAmount;
@override@JsonKey() final  Currency currency;
 final  List<ListingPhoto> _photos;
@override@JsonKey() List<ListingPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  String city;
 final  List<String> _communes;
@override@JsonKey() List<String> get communes {
  if (_communes is EqualUnmodifiableListView) return _communes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_communes);
}

@override@JsonKey() final  ListingStatus status;
@override@JsonKey() final  bool visible;
@override@JsonKey() final  Moderation moderation;
@override final  String? moderationReason;
@override final  String? providerStatus;
@override final  String? providerName;
@override final  String? providerPhotoUrl;
@override@JsonKey() final  bool providerVerified;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override final  LocalizedText? categoryName;
 final  List<String> _searchKeywords;
@override@JsonKey() List<String> get searchKeywords {
  if (_searchKeywords is EqualUnmodifiableListView) return _searchKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchKeywords);
}

@override@JsonKey() final  int contactCount;
@override@TimestampConverter() final  DateTime? publishedAt;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.priceType, priceType) || other.priceType == priceType)&&(identical(other.priceAmount, priceAmount) || other.priceAmount == priceAmount)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.communes, _communes)&&(identical(other.status, status) || other.status == status)&&(identical(other.visible, visible) || other.visible == visible)&&(identical(other.moderation, moderation) || other.moderation == moderation)&&(identical(other.moderationReason, moderationReason) || other.moderationReason == moderationReason)&&(identical(other.providerStatus, providerStatus) || other.providerStatus == providerStatus)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.providerPhotoUrl, providerPhotoUrl) || other.providerPhotoUrl == providerPhotoUrl)&&(identical(other.providerVerified, providerVerified) || other.providerVerified == providerVerified)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&const DeepCollectionEquality().equals(other.searchKeywords, _searchKeywords)&&(identical(other.contactCount, contactCount) || other.contactCount == contactCount)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,providerId,title,description,categoryId,priceType,priceAmount,currency,const DeepCollectionEquality().hash(_photos),city,const DeepCollectionEquality().hash(_communes),status,visible,moderation,moderationReason,providerStatus,providerName,providerPhotoUrl,providerVerified,ratingAvg,ratingCount,categoryName,const DeepCollectionEquality().hash(_searchKeywords),contactCount,publishedAt,createdAt,updatedAt]);
}

@override
String toString() {
    return 'Listing(id: $id, providerId: $providerId, title: $title, description: $description, categoryId: $categoryId, priceType: $priceType, priceAmount: $priceAmount, currency: $currency, photos: $photos, city: $city, communes: $communes, status: $status, visible: $visible, moderation: $moderation, moderationReason: $moderationReason, providerStatus: $providerStatus, providerName: $providerName, providerPhotoUrl: $providerPhotoUrl, providerVerified: $providerVerified, ratingAvg: $ratingAvg, ratingCount: $ratingCount, categoryName: $categoryName, searchKeywords: $searchKeywords, contactCount: $contactCount, publishedAt: $publishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String providerId, String title, String description, String categoryId, PriceType priceType, double? priceAmount, Currency currency, List<ListingPhoto> photos, String city, List<String> communes, ListingStatus status, bool visible, Moderation moderation, String? moderationReason, String? providerStatus, String? providerName, String? providerPhotoUrl, bool providerVerified, double ratingAvg, int ratingCount, LocalizedText? categoryName, List<String> searchKeywords, int contactCount,@TimestampConverter() DateTime? publishedAt,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


@override $LocalizedTextCopyWith<$Res>? get categoryName;

}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? providerId = null,Object? title = null,Object? description = null,Object? categoryId = null,Object? priceType = null,Object? priceAmount = freezed,Object? currency = null,Object? photos = null,Object? city = null,Object? communes = null,Object? status = null,Object? visible = null,Object? moderation = null,Object? moderationReason = freezed,Object? providerStatus = freezed,Object? providerName = freezed,Object? providerPhotoUrl = freezed,Object? providerVerified = null,Object? ratingAvg = null,Object? ratingCount = null,Object? categoryName = freezed,Object? searchKeywords = null,Object? contactCount = null,Object? publishedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,priceType: null == priceType ? _self.priceType : priceType // ignore: cast_nullable_to_non_nullable
as PriceType,priceAmount: freezed == priceAmount ? _self.priceAmount : priceAmount // ignore: cast_nullable_to_non_nullable
as double?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<ListingPhoto>,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,communes: null == communes ? _self._communes : communes // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as bool,moderation: null == moderation ? _self.moderation : moderation // ignore: cast_nullable_to_non_nullable
as Moderation,moderationReason: freezed == moderationReason ? _self.moderationReason : moderationReason // ignore: cast_nullable_to_non_nullable
as String?,providerStatus: freezed == providerStatus ? _self.providerStatus : providerStatus // ignore: cast_nullable_to_non_nullable
as String?,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,providerPhotoUrl: freezed == providerPhotoUrl ? _self.providerPhotoUrl : providerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,providerVerified: null == providerVerified ? _self.providerVerified : providerVerified // ignore: cast_nullable_to_non_nullable
as bool,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as LocalizedText?,searchKeywords: null == searchKeywords ? _self._searchKeywords : searchKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,contactCount: null == contactCount ? _self.contactCount : contactCount // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalizedTextCopyWith<$Res>? get categoryName {
    if (_self.categoryName == null) {
    return null;
  }

  return $LocalizedTextCopyWith<$Res>(_self.categoryName!, (value) {
    return _then(_self.copyWith(categoryName: value));
  });
}
}

// dart format on
