import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/validation/signup_validators.dart';

void main() {
  test('name rejects missing and whitespace-only values', () {
    for (final value in [null, '', '   ']) {
      expect(validateName(value), isNotNull);
    }
    expect(validateName('Demo Student'), isNull);
  });
  test('email rejects incomplete addresses and accepts a demo address', () {
    for (final value in [null, '', 'student', 'a@', '@example.com', 'a b@example.com']) {
      expect(validateEmail(value), isNotNull);
    }
    expect(validateEmail('demo@example.com'), isNull);
  });
  test('password uses the assignment six-character boundary', () {
    expect(validatePassword(null), isNotNull);
    expect(validatePassword(''), isNotNull);
    expect(validatePassword('12345'), isNotNull);
    expect(validatePassword('123456'), isNull);
  });
}
