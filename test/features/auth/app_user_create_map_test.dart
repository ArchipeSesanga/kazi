import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/app_user.dart';

void main() {
  test('create map carries the E.164 phone and the optional email', () {
    const user = AppUser(
      uid: 'u1',
      displayName: 'Alice Mbuyi',
      phone: '+243810000001',
      email: 'alice@example.com',
    );
    final map = user.toCreateMap();
    expect(map['phone'], '+243810000001');
    expect(map['email'], 'alice@example.com');
    expect(map.containsKey('uid'), isFalse);
  });

  test('email is omitted when absent', () {
    const user = AppUser(
      uid: 'u1',
      displayName: 'Alice Mbuyi',
      phone: '+243810000001',
    );
    expect(user.toCreateMap().containsKey('email'), isFalse);
  });
}
