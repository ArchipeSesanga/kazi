// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactRecord {

 String get clientUid; String get providerId; String get providerName; String? get providerPhotoUrl; String? get listingId; ContactChannel get channel;@TimestampConverter() DateTime? get firstAt;@TimestampConverter() DateTime? get lastAt;
/// Create a copy of ContactRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactRecordCopyWith<ContactRecord> get copyWith => _$ContactRecordCopyWithImpl<ContactRecord>(this as ContactRecord, _$identity);

  /// Serializes this ContactRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContactRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactRecord&&(identical(other.clientUid, _this.clientUid) || other.clientUid == _this.clientUid)&&(identical(other.providerId, _this.providerId) || other.providerId == _this.providerId)&&(identical(other.providerName, _this.providerName) || other.providerName == _this.providerName)&&(identical(other.providerPhotoUrl, _this.providerPhotoUrl) || other.providerPhotoUrl == _this.providerPhotoUrl)&&(identical(other.listingId, _this.listingId) || other.listingId == _this.listingId)&&(identical(other.channel, _this.channel) || other.channel == _this.channel)&&(identical(other.firstAt, _this.firstAt) || other.firstAt == _this.firstAt)&&(identical(other.lastAt, _this.lastAt) || other.lastAt == _this.lastAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContactRecord;
  return Object.hash(runtimeType,_this.clientUid,_this.providerId,_this.providerName,_this.providerPhotoUrl,_this.listingId,_this.channel,_this.firstAt,_this.lastAt);
}

@override
String toString() {
  final _this = this as ContactRecord;
  return 'ContactRecord(clientUid: ${_this.clientUid}, providerId: ${_this.providerId}, providerName: ${_this.providerName}, providerPhotoUrl: ${_this.providerPhotoUrl}, listingId: ${_this.listingId}, channel: ${_this.channel}, firstAt: ${_this.firstAt}, lastAt: ${_this.lastAt})';
}


}

/// @nodoc
abstract mixin class $ContactRecordCopyWith<$Res>  {
  factory $ContactRecordCopyWith(ContactRecord value, $Res Function(ContactRecord) _then) = _$ContactRecordCopyWithImpl;
@useResult
$Res call({
 String clientUid, String providerId, String providerName, String? providerPhotoUrl, String? listingId, ContactChannel channel,@TimestampConverter() DateTime? firstAt,@TimestampConverter() DateTime? lastAt
});




}
/// @nodoc
class _$ContactRecordCopyWithImpl<$Res>
    implements $ContactRecordCopyWith<$Res> {
  _$ContactRecordCopyWithImpl(this._self, this._then);

  final ContactRecord _self;
  final $Res Function(ContactRecord) _then;

/// Create a copy of ContactRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientUid = null,Object? providerId = null,Object? providerName = null,Object? providerPhotoUrl = freezed,Object? listingId = freezed,Object? channel = null,Object? firstAt = freezed,Object? lastAt = freezed,}) {
  return _then(ContactRecord(
clientUid: null == clientUid ? _self.clientUid : clientUid // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,providerPhotoUrl: freezed == providerPhotoUrl ? _self.providerPhotoUrl : providerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ContactChannel,firstAt: freezed == firstAt ? _self.firstAt : firstAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactRecord].
extension ContactRecordPatterns on ContactRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactRecord value)  $default,){
final _that = this;
switch (_that) {
case _ContactRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ContactRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientUid,  String providerId,  String providerName,  String? providerPhotoUrl,  String? listingId,  ContactChannel channel, @TimestampConverter()  DateTime? firstAt, @TimestampConverter()  DateTime? lastAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactRecord() when $default != null:
return $default(_that.clientUid,_that.providerId,_that.providerName,_that.providerPhotoUrl,_that.listingId,_that.channel,_that.firstAt,_that.lastAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientUid,  String providerId,  String providerName,  String? providerPhotoUrl,  String? listingId,  ContactChannel channel, @TimestampConverter()  DateTime? firstAt, @TimestampConverter()  DateTime? lastAt)  $default,) {final _that = this;
switch (_that) {
case _ContactRecord():
return $default(_that.clientUid,_that.providerId,_that.providerName,_that.providerPhotoUrl,_that.listingId,_that.channel,_that.firstAt,_that.lastAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientUid,  String providerId,  String providerName,  String? providerPhotoUrl,  String? listingId,  ContactChannel channel, @TimestampConverter()  DateTime? firstAt, @TimestampConverter()  DateTime? lastAt)?  $default,) {final _that = this;
switch (_that) {
case _ContactRecord() when $default != null:
return $default(_that.clientUid,_that.providerId,_that.providerName,_that.providerPhotoUrl,_that.listingId,_that.channel,_that.firstAt,_that.lastAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactRecord implements ContactRecord {
  const _ContactRecord({required this.clientUid, required this.providerId, required this.providerName, this.providerPhotoUrl, this.listingId, required this.channel, @TimestampConverter() this.firstAt, @TimestampConverter() this.lastAt});
  factory _ContactRecord.fromJson(Map<String, dynamic> json) => _$ContactRecordFromJson(json);

@override final  String clientUid;
@override final  String providerId;
@override final  String providerName;
@override final  String? providerPhotoUrl;
@override final  String? listingId;
@override final  ContactChannel channel;
@override@TimestampConverter() final  DateTime? firstAt;
@override@TimestampConverter() final  DateTime? lastAt;

/// Create a copy of ContactRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactRecordCopyWith<_ContactRecord> get copyWith => __$ContactRecordCopyWithImpl<_ContactRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactRecord&&(identical(other.clientUid, clientUid) || other.clientUid == clientUid)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.providerPhotoUrl, providerPhotoUrl) || other.providerPhotoUrl == providerPhotoUrl)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.channel, channel) || other.channel == channel)&&(identical(other.firstAt, firstAt) || other.firstAt == firstAt)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,clientUid,providerId,providerName,providerPhotoUrl,listingId,channel,firstAt,lastAt);
}

@override
String toString() {
    return 'ContactRecord(clientUid: $clientUid, providerId: $providerId, providerName: $providerName, providerPhotoUrl: $providerPhotoUrl, listingId: $listingId, channel: $channel, firstAt: $firstAt, lastAt: $lastAt)';
}


}

/// @nodoc
abstract mixin class _$ContactRecordCopyWith<$Res> implements $ContactRecordCopyWith<$Res> {
  factory _$ContactRecordCopyWith(_ContactRecord value, $Res Function(_ContactRecord) _then) = __$ContactRecordCopyWithImpl;
@override @useResult
$Res call({
 String clientUid, String providerId, String providerName, String? providerPhotoUrl, String? listingId, ContactChannel channel,@TimestampConverter() DateTime? firstAt,@TimestampConverter() DateTime? lastAt
});




}
/// @nodoc
class __$ContactRecordCopyWithImpl<$Res>
    implements _$ContactRecordCopyWith<$Res> {
  __$ContactRecordCopyWithImpl(this._self, this._then);

  final _ContactRecord _self;
  final $Res Function(_ContactRecord) _then;

/// Create a copy of ContactRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientUid = null,Object? providerId = null,Object? providerName = null,Object? providerPhotoUrl = freezed,Object? listingId = freezed,Object? channel = null,Object? firstAt = freezed,Object? lastAt = freezed,}) {
  return _then(_ContactRecord(
clientUid: null == clientUid ? _self.clientUid : clientUid // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,providerPhotoUrl: freezed == providerPhotoUrl ? _self.providerPhotoUrl : providerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as String?,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as ContactChannel,firstAt: freezed == firstAt ? _self.firstAt : firstAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
