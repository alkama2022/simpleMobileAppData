import 'package:flutter_test/flutter_test.dart';

// The validation regex extracted from BuyDataScreen._phoneValid.
// Any change to the screen's regex must also update this test.
final _phoneRegex = RegExp(r'^0[789][01]\d{8}$');

bool isValidPhone(String phone) => _phoneRegex.hasMatch(phone);

void main() {
  group('Nigerian phone validation regex', () {
    // ── Valid numbers ────────────────────────────────────────────────
    group('valid numbers', () {
      test('MTN 0801', () => expect(isValidPhone('08012345678'), true));
      test('MTN 0802', () => expect(isValidPhone('08023456789'), true));
      test('Airtel 0701', () => expect(isValidPhone('07012345678'), true));
      test('Glo 0901', () => expect(isValidPhone('09012345678'), true));
      test('9mobile 0901', () => expect(isValidPhone('09012345678'), true));
      test('0810', () => expect(isValidPhone('08101234567'), true));
      test('0811', () => expect(isValidPhone('08111234567'), true));
      test('0700', () => expect(isValidPhone('07001234567'), true));
      test('0701', () => expect(isValidPhone('07011234567'), true));
      test('0900', () => expect(isValidPhone('09001234567'), true));
      test('0901', () => expect(isValidPhone('09011234567'), true));
    });

    // ── Invalid — wrong prefix ───────────────────────────────────────
    group('invalid — wrong prefix', () {
      test('starts with 1', () => expect(isValidPhone('11012345678'), false));
      test('starts with 06', () => expect(isValidPhone('06012345678'), false));
      test('starts with 05', () => expect(isValidPhone('05012345678'), false));
    });

    // ── Invalid — wrong length ───────────────────────────────────────
    group('invalid — wrong length', () {
      test('10 digits', () => expect(isValidPhone('0801234567'), false));
      test('12 digits', () => expect(isValidPhone('080123456789'), false));
      test('empty string', () => expect(isValidPhone(''), false));
      test('6 digits', () => expect(isValidPhone('080123'), false));
    });

    // ── Invalid — non-digit characters ──────────────────────────────
    group('invalid — non-digits', () {
      test('spaces', () => expect(isValidPhone('0801 234 5678'), false));
      test('plus prefix', () => expect(isValidPhone('+2348012345678'), false));
      test('dashes', () => expect(isValidPhone('080-123-45678'), false));
      test('letters', () => expect(isValidPhone('0801ABCDEFG'), false));
    });

    // ── Invalid — correct length but wrong third digit ───────────────
    group('invalid — wrong third digit', () {
      // Third digit must be 0 or 1 (the [01] in regex)
      test('082x not valid', () => expect(isValidPhone('08212345678'), false));
      test('083x not valid', () => expect(isValidPhone('08312345678'), false));
    });

    // ── Edge cases ──────────────────────────────────────────────────
    group('edge cases', () {
      test('all zeros (invalid)', () {
        expect(isValidPhone('00000000000'), false);
      });
      test('whitespace only', () {
        expect(isValidPhone('           '), false);
      });
    });
  });
}
