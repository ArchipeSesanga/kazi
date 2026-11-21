// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get uid; String get displayName; String? get photoUrl;/// E.164 phone number: the account identity (matches the Auth token).
 String get phone; String? get email; String get locale; String get city; String? get commune; String? get termsVersion;@TimestampConverter() DateTime? get termsAcceptedAt; bool get isProvider; UserStatus get status;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppUser;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.commune, _this.commune) || other.commune == _this.commune)&&(identical(other.termsVersion, _this.termsVersion) || other.termsVersion == _this.termsVersion)&&(identical(other.termsAcceptedAt, _this.termsAcceptedAt) || other.termsAcceptedAt == _this.termsAcceptedAt)&&(identical(other.isProvider, _this.isProvider) || other.isProvider == _this.isProvider)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppUser;
  return Object.hash(runtimeType,_this.uid,_this.displayName,_this.photoUrl,_this.phone,_this.email,_this.locale,_this.city,_this.commune,_this.termsVersion,_this.termsAcceptedAt,_this.isProvider,_this.status,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as AppUser;
  return 'AppUser(uid: ${_this.uid}, displayName: ${_this.displayName}, photoUrl: ${_this.photoUrl}, phone: ${_this.phone}, email: ${_this.email}, locale: ${_this.locale}, city: ${_this.city}, commune: ${_this.commune}, termsVersion: ${_this.termsVersion}, termsAcceptedAt: ${_this.termsAcceptedAt}, isProvider: ${_this.isProvider}, status: ${_this.status}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, String? photoUrl, String phone, String? email, String locale, String city, String? commune, String? termsVersion,@TimestampConverter() DateTime? termsAcceptedAt, bool isProvider, UserStatus status,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? photoUrl = freezed,Object? phone = null,Object? email = freezed,Object? locale = null,Object? city = null,Object? commune = freezed,Object? termsVersion = freezed,Object? termsAcceptedAt = freezed,Object? isProvider = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,commune: freezed == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String?,termsVersion: freezed == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String?,termsAcceptedAt: freezed == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isProvider: null == isProvider ? _self.isProvider : isProvider // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  String? photoUrl,  String phone,  String? email,  String locale,  String city,  String? commune,  String? termsVersion, @TimestampConverter()  DateTime? termsAcceptedAt,  bool isProvider,  UserStatus status, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.displayName,_that.photoUrl,_that.phone,_that.email,_that.locale,_that.city,_that.commune,_that.termsVersion,_that.termsAcceptedAt,_that.isProvider,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  String? photoUrl,  String phone,  String? email,  String locale,  String city,  String? commune,  String? termsVersion, @TimestampConverter()  DateTime? termsAcceptedAt,  bool isProvider,  UserStatus status, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.displayName,_that.photoUrl,_that.phone,_that.email,_that.locale,_that.city,_that.commune,_that.termsVersion,_that.termsAcceptedAt,_that.isProvider,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  String? photoUrl,  String phone,  String? email,  String locale,  String city,  String? commune,  String? termsVersion, @TimestampConverter()  DateTime? termsAcceptedAt,  bool isProvider,  UserStatus status, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.displayName,_that.photoUrl,_that.phone,_that.email,_that.locale,_that.city,_that.commune,_that.termsVersion,_that.termsAcceptedAt,_that.isProvider,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.uid, required this.displayName, this.photoUrl, this.phone = '', this.email, this.locale = 'fr', this.city = 'kinshasa', this.commune, this.termsVersion, @TimestampConverter() this.termsAcceptedAt, this.isProvider = false, this.status = UserStatus.active, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String uid;
@override final  String displayName;
@override final  String? photoUrl;
/// E.164 phone number: the account identity (matches the Auth token).
@override@JsonKey() final  String phone;
@override final  String? email;
@override@JsonKey() final  String locale;
@override@JsonKey() final  String city;
@override final  String? commune;
@override final  String? termsVersion;
@override@TimestampConverter() final  DateTime? termsAcceptedAt;
@override@JsonKey() final  bool isProvider;
@override@JsonKey() final  UserStatus status;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.city, city) || other.city == city)&&(identical(other.commune, commune) || other.commune == commune)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion)&&(identical(other.termsAcceptedAt, termsAcceptedAt) || other.termsAcceptedAt == termsAcceptedAt)&&(identical(other.isProvider, isProvider) || other.isProvider == isProvider)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uid,displayName,photoUrl,phone,email,locale,city,commune,termsVersion,termsAcceptedAt,isProvider,status,createdAt,updatedAt);
}

@override
String toString() {
    return 'AppUser(uid: $uid, displayName: $displayName, photoUrl: $photoUrl, phone: $phone, email: $email, locale: $locale, city: $city, commune: $commune, termsVersion: $termsVersion, termsAcceptedAt: $termsAcceptedAt, isProvider: $isProvider, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, String? photoUrl, String phone, String? email, String locale, String city, String? commune, String? termsVersion,@TimestampConverter() DateTime? termsAcceptedAt, bool isProvider, UserStatus status,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? photoUrl = freezed,Object? phone = null,Object? email = freezed,Object? locale = null,Object? city = null,Object? commune = freezed,Object? termsVersion = freezed,Object? termsAcceptedAt = freezed,Object? isProvider = null,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,commune: freezed == commune ? _self.commune : commune // ignore: cast_nullable_to_non_nullable
as String?,termsVersion: freezed == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String?,termsAcceptedAt: freezed == termsAcceptedAt ? _self.termsAcceptedAt : termsAcceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isProvider: null == isProvider ? _self.isProvider : isProvider // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
