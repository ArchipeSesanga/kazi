import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// E.164 phone number utilities. Default country is CD (DRC).
abstract final class PhoneUtils {
  /// Returns true if [e164] is a valid E.164 number.
  static bool isValidE164(String e164) {
    try {
      return PhoneNumber.fromRaw(e164).validate();
    } catch (_) {
      return false;
    }
  }

  /// Parses a national [input] for [country] and returns the E.164 string.
  /// Returns null if the input cannot be parsed or is invalid.
  static String? toE164(String input, {IsoCode country = IsoCode.CD}) {
    try {
      final number = PhoneNumber.fromIsoCode(country, input);
      if (!number.validate()) return null;
      return number.international;
    } catch (_) {
      return null;
    }
  }

  /// Normalises what a user typed (`0812345678`, `812345678`,
  /// `+243 81 234 5678`, `00243812345678`) to E.164 and checks it against the
  /// real numbering plan. Returns null when it is not a valid number.
  static String? normalise(String input, {IsoCode country = IsoCode.CD}) {
    final compact = input.replaceAll(RegExp(r'[\s.\-()]'), '');
    if (compact.isEmpty) return null;
    if (compact.startsWith('+')) return isValidE164(compact) ? compact : null;
    if (compact.startsWith('00')) {
      final e164 = '+${compact.substring(2)}';
      return isValidE164(e164) ? e164 : null;
    }
    return toE164(compact, country: country);
  }

  /// Returns the international representation (`+countryCodeNsn`) of [e164].
  static String formatDisplay(String e164) {
    try {
      return PhoneNumber.fromRaw(e164).international;
    } catch (_) {
      return e164;
    }
  }
}
