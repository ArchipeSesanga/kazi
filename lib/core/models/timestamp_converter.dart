import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts Firestore [Timestamp] ↔ [DateTime] for @freezed / @JsonSerializable models.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}

/// Non-nullable variant for required timestamps.
class TimestampConverterNonNull implements JsonConverter<DateTime, Object?> {
  const TimestampConverterNonNull();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return DateTime(0);
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}
