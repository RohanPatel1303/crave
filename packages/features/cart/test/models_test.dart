import 'package:cart_feature/cart_feature.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a string at runtime, so equality never passes only because two
/// constants are the same canonical instance.
String _runtimeString(String value) => String.fromCharCodes(value.codeUnits);

/// Builds an int at runtime, for the same reason as [_runtimeString].
int _runtimeInt(int value) => int.parse('$value');

Money _money(int minorUnits, {String currency = 'USD'}) =>
    Money(_runtimeInt(minorUnits), currency: _runtimeString(currency));

CartLine _line({
  String itemId = 'al-pastor',
  String name = 'Al pastor taco',
  int unitPriceMinorUnits = 450,
  String currency = 'USD',
  int quantity = 2,
}) => CartLine(
  itemId: _runtimeString(itemId),
  name: _runtimeString(name),
  unitPrice: _money(unitPriceMinorUnits, currency: currency),
  quantity: _runtimeInt(quantity),
);

Cart _cart({String restaurantId = 'taqueria-sol', List<CartLine>? lines}) =>
    Cart(
      restaurantId: _runtimeString(restaurantId),
      lines: lines ?? [_line(), _line(itemId: 'horchata', name: 'Horchata')],
    );

void main() {
  group('CartLine', () {
    test('lineTotal multiplies the unit price by the quantity', () {
      expect(
        _line(unitPriceMinorUnits: 500, quantity: 3).lineTotal,
        _money(1500),
      );
    });

    test('accepts quantities 1 and 99', () {
      expect(_line(quantity: 1).quantity, 1);
      expect(_line(quantity: 99).quantity, 99);
    });

    test('throws a RangeError for quantities outside 1 to 99', () {
      expect(() => _line(quantity: 0), throwsRangeError);
      expect(() => _line(quantity: 100), throwsRangeError);
    });

    test('compares runtime-built values and hashes equally', () {
      final first = _line();
      final second = _line();

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('differs when any field differs', () {
      final line = _line();

      expect(line, isNot(_line(itemId: 'carnitas')));
      expect(line, isNot(_line(name: 'Taco al pastor')));
      expect(line, isNot(_line(unitPriceMinorUnits: 500)));
      expect(line, isNot(_line(currency: 'CAD')));
      expect(line, isNot(_line(quantity: 3)));
    });

    test('toString names the item, price and quantity', () {
      expect(_line().toString(), contains('al-pastor'));
      expect(_line().toString(), contains('x2'));
    });
  });

  group('Cart', () {
    test('total adds every line total', () {
      final cart = _cart(
        lines: [
          _line(unitPriceMinorUnits: 500, quantity: 3),
          _line(itemId: 'horchata', unitPriceMinorUnits: 300, quantity: 1),
        ],
      );

      expect(cart.total, _money(1800));
    });

    test('total uses the lines currency', () {
      final cart = _cart(lines: [_line(currency: 'CAD')]);

      expect(cart.total.currency, 'CAD');
    });

    test('itemCount counts units, not lines', () {
      final cart = _cart(
        lines: [
          _line(quantity: 4),
          _line(itemId: 'horchata', quantity: 3),
        ],
      );

      expect(cart.itemCount, 7);
    });

    test('throws an ArgumentError for no lines', () {
      expect(() => _cart(lines: []), throwsArgumentError);
    });

    test('throws an ArgumentError for lines in different currencies', () {
      expect(
        () => _cart(
          lines: [
            _line(),
            _line(itemId: 'horchata', currency: 'CAD'),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('copies lines, so changing the given list does not change it', () {
      final lines = [_line()];
      final cart = _cart(lines: lines);

      lines.add(_line(itemId: 'horchata'));

      expect(cart.lines, hasLength(1));
    });

    test('lines cannot be modified', () {
      final cart = _cart();

      expect(() => cart.lines.add(_line()), throwsUnsupportedError);
    });

    test('compares runtime-built values and hashes equally', () {
      final first = _cart();
      final second = _cart();

      expect(identical(first, second), isFalse);
      expect(identical(first.lines, second.lines), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('differs when the restaurant, a line or the line order differs', () {
      final first = _line();
      final second = _line(itemId: 'horchata', name: 'Horchata');
      final cart = _cart(lines: [first, second]);

      expect(
        cart,
        isNot(_cart(restaurantId: 'pho-house', lines: [first, second])),
      );
      expect(cart, isNot(_cart(lines: [first])));
      expect(
        cart,
        isNot(
          _cart(
            lines: [
              first,
              _line(itemId: 'horchata', name: 'Horchata', quantity: 5),
            ],
          ),
        ),
      );
      expect(cart, isNot(_cart(lines: [second, first])));
    });

    test('toString names the restaurant', () {
      expect(_cart().toString(), contains('taqueria-sol'));
    });
  });
}
