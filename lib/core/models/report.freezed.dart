// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Report {

 String get reporterUid; ReportTargetType get targetType; String get targetKey; ReportReason get reason; String get details; ReportStatus get status; Map<String, dynamic>? get resolution;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Report;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.reporterUid, _this.reporterUid) || other.reporterUid == _this.reporterUid)&&(identical(other.targetType, _this.targetType) || other.targetType == _this.targetType)&&(identical(other.targetKey, _this.targetKey) || other.targetKey == _this.targetKey)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.details, _this.details) || other.details == _this.details)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.resolution, _this.resolution)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Report;
  return Object.hash(runtimeType,_this.reporterUid,_this.targetType,_this.targetKey,_this.reason,_this.details,_this.status,const DeepCollectionEquality().hash(_this.resolution),_this.createdAt);
}

@override
String toString() {
  final _this = this as Report;
  return 'Report(reporterUid: ${_this.reporterUid}, targetType: ${_this.targetType}, targetKey: ${_this.targetKey}, reason: ${_this.reason}, details: ${_this.details}, status: ${_this.status}, resolution: ${_this.resolution}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String reporterUid, ReportTargetType targetType, String targetKey, ReportReason reason, String details, ReportStatus status, Map<String, dynamic>? resolution,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reporterUid = null,Object? targetType = null,Object? targetKey = null,Object? reason = null,Object? details = null,Object? status = null,Object? resolution = freezed,Object? createdAt = freezed,}) {
  return _then(Report(
reporterUid: null == reporterUid ? _self.reporterUid : reporterUid // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as ReportTargetType,targetKey: null == targetKey ? _self.targetKey : targetKey // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reporterUid,  ReportTargetType targetType,  String targetKey,  ReportReason reason,  String details,  ReportStatus status,  Map<String, dynamic>? resolution, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.reporterUid,_that.targetType,_that.targetKey,_that.reason,_that.details,_that.status,_that.resolution,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reporterUid,  ReportTargetType targetType,  String targetKey,  ReportReason reason,  String details,  ReportStatus status,  Map<String, dynamic>? resolution, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.reporterUid,_that.targetType,_that.targetKey,_that.reason,_that.details,_that.status,_that.resolution,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reporterUid,  ReportTargetType targetType,  String targetKey,  ReportReason reason,  String details,  ReportStatus status,  Map<String, dynamic>? resolution, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.reporterUid,_that.targetType,_that.targetKey,_that.reason,_that.details,_that.status,_that.resolution,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.reporterUid, required this.targetType, required this.targetKey, required this.reason, this.details = '', this.status = ReportStatus.open,  Map<String, dynamic>? resolution, @TimestampConverter() this.createdAt}): _resolution = resolution;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String reporterUid;
@override final  ReportTargetType targetType;
@override final  String targetKey;
@override final  ReportReason reason;
@override@JsonKey() final  String details;
@override@JsonKey() final  ReportStatus status;
 final  Map<String, dynamic>? _resolution;
@override Map<String, dynamic>? get resolution {
  final value = _resolution;
  if (value == null) return null;
  if (_resolution is EqualUnmodifiableMapView) return _resolution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.reporterUid, reporterUid) || other.reporterUid == reporterUid)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetKey, targetKey) || other.targetKey == targetKey)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.details, details) || other.details == details)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.resolution, _resolution)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reporterUid,targetType,targetKey,reason,details,status,const DeepCollectionEquality().hash(_resolution),createdAt);
}

@override
String toString() {
    return 'Report(reporterUid: $reporterUid, targetType: $targetType, targetKey: $targetKey, reason: $reason, details: $details, status: $status, resolution: $resolution, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String reporterUid, ReportTargetType targetType, String targetKey, ReportReason reason, String details, ReportStatus status, Map<String, dynamic>? resolution,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reporterUid = null,Object? targetType = null,Object? targetKey = null,Object? reason = null,Object? details = null,Object? status = null,Object? resolution = freezed,Object? createdAt = freezed,}) {
  return _then(_Report(
reporterUid: null == reporterUid ? _self.reporterUid : reporterUid // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as ReportTargetType,targetKey: null == targetKey ? _self.targetKey : targetKey // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReportReason,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,resolution: freezed == resolution ? _self._resolution : resolution // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
