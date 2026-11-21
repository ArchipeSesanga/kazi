import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/phone.dart';

void main() {
  group('PhoneUtils.normalise', () {
    test('accepts national and international DRC formats', () {
      for (final input in [
        '0812345678',
        '812345678',
        '081 234 5678',
        '+243812345678',
        '+243 81 234 5678',
        '00243812345678',
      ]) {
        expect(PhoneUtils.normalise(input), '+243812345678', reason: input);
      }
    });

    test('rejects numbers the real numbering plan does not allow', () {
      // The number from the bug report: right prefix, one digit too many.
      expect(PhoneUtils.normalise('+2431212211212'), isNull);
      for (final input in ['', '12', 'abc', '+243', '+24381234', '0812345678901']) {
        expect(PhoneUtils.normalise(input), isNull, reason: input);
      }
    });
  });
}
