// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationRequest {

 String get uid; VerificationStatus get status; String? get idDocumentPath; String? get selfiePath;@TimestampConverter() DateTime? get submittedAt;@TimestampConverter() DateTime? get decidedAt; String? get decidedBy; String? get reason;
/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationRequestCopyWith<VerificationRequest> get copyWith => _$VerificationRequestCopyWithImpl<VerificationRequest>(this as VerificationRequest, _$identity);

  /// Serializes this VerificationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VerificationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationRequest&&(identical(other.uid, _this.uid) || other.uid == _this.uid)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.idDocumentPath, _this.idDocumentPath) || other.idDocumentPath == _this.idDocumentPath)&&(identical(other.selfiePath, _this.selfiePath) || other.selfiePath == _this.selfiePath)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&(identical(other.decidedAt, _this.decidedAt) || other.decidedAt == _this.decidedAt)&&(identical(other.decidedBy, _this.decidedBy) || other.decidedBy == _this.decidedBy)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VerificationRequest;
  return Object.hash(runtimeType,_this.uid,_this.status,_this.idDocumentPath,_this.selfiePath,_this.submittedAt,_this.decidedAt,_this.decidedBy,_this.reason);
}

@override
String toString() {
  final _this = this as VerificationRequest;
  return 'VerificationRequest(uid: ${_this.uid}, status: ${_this.status}, idDocumentPath: ${_this.idDocumentPath}, selfiePath: ${_this.selfiePath}, submittedAt: ${_this.submittedAt}, decidedAt: ${_this.decidedAt}, decidedBy: ${_this.decidedBy}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $VerificationRequestCopyWith<$Res>  {
  factory $VerificationRequestCopyWith(VerificationRequest value, $Res Function(VerificationRequest) _then) = _$VerificationRequestCopyWithImpl;
@useResult
$Res call({
 String uid, VerificationStatus status, String? idDocumentPath, String? selfiePath,@TimestampConverter() DateTime? submittedAt,@TimestampConverter() DateTime? decidedAt, String? decidedBy, String? reason
});




}
/// @nodoc
class _$VerificationRequestCopyWithImpl<$Res>
    implements $VerificationRequestCopyWith<$Res> {
  _$VerificationRequestCopyWithImpl(this._self, this._then);

  final VerificationRequest _self;
  final $Res Function(VerificationRequest) _then;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? status = null,Object? idDocumentPath = freezed,Object? selfiePath = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,Object? decidedBy = freezed,Object? reason = freezed,}) {
  return _then(VerificationRequest(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,idDocumentPath: freezed == idDocumentPath ? _self.idDocumentPath : idDocumentPath // ignore: cast_nullable_to_non_nullable
as String?,selfiePath: freezed == selfiePath ? _self.selfiePath : selfiePath // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationRequest].
extension VerificationRequestPatterns on VerificationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationRequest value)  $default,){
final _that = this;
switch (_that) {
case _VerificationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  VerificationStatus status,  String? idDocumentPath,  String? selfiePath, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime? decidedAt,  String? decidedBy,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationRequest() when $default != null:
return $default(_that.uid,_that.status,_that.idDocumentPath,_that.selfiePath,_that.submittedAt,_that.decidedAt,_that.decidedBy,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  VerificationStatus status,  String? idDocumentPath,  String? selfiePath, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime? decidedAt,  String? decidedBy,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _VerificationRequest():
return $default(_that.uid,_that.status,_that.idDocumentPath,_that.selfiePath,_that.submittedAt,_that.decidedAt,_that.decidedBy,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  VerificationStatus status,  String? idDocumentPath,  String? selfiePath, @TimestampConverter()  DateTime? submittedAt, @TimestampConverter()  DateTime? decidedAt,  String? decidedBy,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _VerificationRequest() when $default != null:
return $default(_that.uid,_that.status,_that.idDocumentPath,_that.selfiePath,_that.submittedAt,_that.decidedAt,_that.decidedBy,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationRequest implements VerificationRequest {
  const _VerificationRequest({required this.uid, this.status = VerificationStatus.pending, this.idDocumentPath, this.selfiePath, @TimestampConverter() this.submittedAt, @TimestampConverter() this.decidedAt, this.decidedBy, this.reason});
  factory _VerificationRequest.fromJson(Map<String, dynamic> json) => _$VerificationRequestFromJson(json);

@override final  String uid;
@override@JsonKey() final  VerificationStatus status;
@override final  String? idDocumentPath;
@override final  String? selfiePath;
@override@TimestampConverter() final  DateTime? submittedAt;
@override@TimestampConverter() final  DateTime? decidedAt;
@override final  String? decidedBy;
@override final  String? reason;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationRequestCopyWith<_VerificationRequest> get copyWith => __$VerificationRequestCopyWithImpl<_VerificationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationRequest&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.status, status) || other.status == status)&&(identical(other.idDocumentPath, idDocumentPath) || other.idDocumentPath == idDocumentPath)&&(identical(other.selfiePath, selfiePath) || other.selfiePath == selfiePath)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.decidedBy, decidedBy) || other.decidedBy == decidedBy)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,uid,status,idDocumentPath,selfiePath,submittedAt,decidedAt,decidedBy,reason);
}

@override
String toString() {
    return 'VerificationRequest(uid: $uid, status: $status, idDocumentPath: $idDocumentPath, selfiePath: $selfiePath, submittedAt: $submittedAt, decidedAt: $decidedAt, decidedBy: $decidedBy, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$VerificationRequestCopyWith<$Res> implements $VerificationRequestCopyWith<$Res> {
  factory _$VerificationRequestCopyWith(_VerificationRequest value, $Res Function(_VerificationRequest) _then) = __$VerificationRequestCopyWithImpl;
@override @useResult
$Res call({
 String uid, VerificationStatus status, String? idDocumentPath, String? selfiePath,@TimestampConverter() DateTime? submittedAt,@TimestampConverter() DateTime? decidedAt, String? decidedBy, String? reason
});




}
/// @nodoc
class __$VerificationRequestCopyWithImpl<$Res>
    implements _$VerificationRequestCopyWith<$Res> {
  __$VerificationRequestCopyWithImpl(this._self, this._then);

  final _VerificationRequest _self;
  final $Res Function(_VerificationRequest) _then;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? status = null,Object? idDocumentPath = freezed,Object? selfiePath = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,Object? decidedBy = freezed,Object? reason = freezed,}) {
  return _then(_VerificationRequest(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,idDocumentPath: freezed == idDocumentPath ? _self.idDocumentPath : idDocumentPath // ignore: cast_nullable_to_non_nullable
as String?,selfiePath: freezed == selfiePath ? _self.selfiePath : selfiePath // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedBy: freezed == decidedBy ? _self.decidedBy : decidedBy // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
