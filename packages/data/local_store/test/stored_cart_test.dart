import 'package:local_store/local_store.dart';
import 'package:test/test.dart';

void main() {
  group('StoredCartLine', () {
    StoredCartLine line({int quantity = 2}) => StoredCartLine(
      restaurantId: 'r1',
      itemId: 'curry',
      name: 'Green curry',
      unitPriceMinorUnits: 1250,
      currency: 'USD',
      quantity: quantity,
    );

    test('lines with the same fields are equal and share a hash code', () {
      expect(line(), line());
      expect(line().hashCode, line().hashCode);
    });

    test('lines with different quantities are not equal', () {
      expect(line(), isNot(line(quantity: 3)));
    });

    test('toString names the item and quantity', () {
      expect(
        line().toString(),
        'StoredCartLine(r1, curry, Green curry, 1250 USD, x2)',
      );
    });
  });

  group('NewCartLine', () {
    NewCartLine line({int price = 1250}) => NewCartLine(
      restaurantId: 'r1',
      itemId: 'curry',
      name: 'Green curry',
      unitPriceMinorUnits: price,
      currency: 'USD',
    );

    test('lines with the same fields are equal and share a hash code', () {
      expect(line(), line());
      expect(line().hashCode, line().hashCode);
    });

    test('lines with different prices are not equal', () {
      expect(line(), isNot(line(price: 999)));
    });

    test('toString names the item and price', () {
      expect(
        line().toString(),
        'NewCartLine(r1, curry, Green curry, 1250 USD)',
      );
    });
  });
}
