import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('formats dollars with two decimals', () {
      expect(
        formatMoney(Money(450, currency: 'USD'), locale: 'en_US'),
        r'$4.50',
      );
    });

    test('formats euros with the euro sign and two decimals', () {
      final formatted = formatMoney(
        Money(1299, currency: 'EUR'),
        locale: 'en_US',
      );

      expect(formatted, contains('12.99'));
      expect(formatted, contains('€'));
    });

    test('formats yen with no decimals', () {
      expect(
        formatMoney(Money(1200, currency: 'JPY'), locale: 'en_US'),
        '¥1,200',
      );
    });

    test('formats zero with two decimals', () {
      expect(formatMoney(Money(0, currency: 'USD'), locale: 'en_US'), r'$0.00');
    });
  });
}
