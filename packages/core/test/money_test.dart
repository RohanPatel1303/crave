import 'package:core/src/money.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('equal amounts in the same currency are equal and '
        'share a hashCode', () {
      final a = Money(1299, currency: 'USD');
      final b = Money(1299, currency: 'USD');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
    test('the same amount in different currencies is not equal', () {
      final a = Money(1299, currency: 'USD');
      final b = Money(1299, currency: 'INR');

      expect(a, isNot(equals(b)));
    });
    test('addition gives the right minor units', () {
      final a = Money(1299, currency: 'USD');
      final b = Money(201, currency: 'USD');

      expect(a + b, equals(Money(1500, currency: 'USD')));
    });

    test('subtraction gives the right minor units', () {
      final a = Money(1299, currency: 'USD');
      final b = Money(200, currency: 'USD');

      expect(a - b, equals(Money(1099, currency: 'USD')));
    });

    test('multiplication gives the right minor units', () {
      final amount = Money(1299, currency: 'USD');

      expect(amount * 3, equals(Money(3897, currency: 'USD')));
    });

    test('sum of an empty list is zero in the given currency', () {
      expect(
        Money.sum(const [], currency: 'USD'),
        equals(Money(0, currency: 'USD')),
      );
    });

    test('sum of ten 10-cent amounts is exactly 100 minor units', () {
      final amounts = List.generate(10, (_) => Money(10, currency: 'USD'));

      expect(
        Money.sum(amounts, currency: 'USD'),
        equals(Money(100, currency: 'USD')),
      );
    });

    test('adding different currencies throws ArgumentError', () {
      final usd = Money(100, currency: 'USD');
      final inr = Money(100, currency: 'INR');

      expect(() => usd + inr, throwsArgumentError);
    });

    test('subtracting different currencies throws ArgumentError', () {
      final usd = Money(100, currency: 'USD');
      final inr = Money(100, currency: 'INR');

      expect(() => usd - inr, throwsArgumentError);
    });

    test('comparing different currencies throws ArgumentError', () {
      final usd = Money(100, currency: 'USD');
      final inr = Money(100, currency: 'INR');

      expect(() => usd.compareTo(inr), throwsArgumentError);
    });

    test('currency must be three uppercase letters', () {
      for (final currency in ['usd', 'US', 'USDD', 'U1D', 'USD\n', 'USÉ']) {
        expect(() => Money(100, currency: currency), throwsArgumentError);
      }
    });

    test('compareTo orders amounts', () {
      final smaller = Money(100, currency: 'USD');
      final larger = Money(200, currency: 'USD');

      expect(smaller.compareTo(larger), lessThan(0));
      expect(larger.compareTo(smaller), greaterThan(0));
      expect(smaller.compareTo(Money(100, currency: 'USD')), 0);
    });
  });
}
