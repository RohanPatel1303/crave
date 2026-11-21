import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/menu_feature.dart';

String _runtimeString(String value) => String.fromCharCodes(value.codeUnits);

MenuItem _item({
  String id = 'al-pastor',
  String name = 'Al pastor taco',
  String description = 'Pork, pineapple, onion, cilantro',
  int minorUnits = 450,
  bool available = true,
}) => MenuItem(
  id: _runtimeString(id),
  name: _runtimeString(name),
  description: _runtimeString(description),
  price: Money(int.parse('$minorUnits'), currency: _runtimeString('USD')),
  available: available,
);

MenuCategory _category({
  String id = 'tacos',
  String name = 'Tacos',
  List<MenuItem>? items,
}) => MenuCategory(
  id: _runtimeString(id),
  name: _runtimeString(name),
  items: items ?? [_item()],
);

Menu _menu({
  String restaurantId = 'taqueria-sol',
  DateTime? fetchedAt,
  List<MenuCategory>? categories,
}) => Menu(
  restaurantId: _runtimeString(restaurantId),
  fetchedAt: fetchedAt ?? DateTime.parse('2026-11-19T14:00:00Z'),
  categories: categories ?? [_category()],
);

void main() {
  group('Restaurant equality', () {
    test('compares runtime-built values and hashes equally', () {
      final first = Restaurant(
        id: _runtimeString('taqueria-sol'),
        name: _runtimeString('Taqueria Sol'),
        cuisine: _runtimeString('Mexican'),
      );
      final second = Restaurant(
        id: _runtimeString('taqueria-sol'),
        name: _runtimeString('Taqueria Sol'),
        cuisine: _runtimeString('Mexican'),
      );

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(
        first,
        isNot(
          Restaurant(
            id: _runtimeString('other'),
            name: _runtimeString('Taqueria Sol'),
            cuisine: _runtimeString('Mexican'),
          ),
        ),
      );
    });
  });

  group('MenuItem equality', () {
    test('compares runtime-built values and Money values', () {
      final first = _item();
      final second = _item();

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_item(minorUnits: 451)));
      expect(first, isNot(_item(available: false)));
    });
  });

  group('MenuCategory equality', () {
    test('compares runtime-built values and nested item values', () {
      final first = _category();
      final second = _category();

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_category(items: [_item(minorUnits: 451)])));
    });

    test('copies and protects its items list', () {
      final items = <MenuItem>[_item()];
      final category = _category(items: items);
      items.clear();

      expect(category.items, hasLength(1));
      expect(() => category.items.add(_item()), throwsUnsupportedError);
    });
  });

  group('Menu equality', () {
    test('compares runtime-built values and nested category values', () {
      final first = _menu();
      final second = _menu();

      expect(identical(first, second), isFalse);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(_menu(restaurantId: 'another-restaurant')));
      expect(
        first,
        isNot(_menu(fetchedAt: DateTime.parse('2026-11-19T14:01:00Z'))),
      );
      expect(
        first,
        isNot(
          _menu(
            categories: [
              _category(items: [_item(minorUnits: 451)]),
            ],
          ),
        ),
      );
    });

    test('copies and protects its categories list', () {
      final categories = <MenuCategory>[_category()];
      final menu = _menu(categories: categories);
      categories.clear();

      expect(menu.categories, hasLength(1));
      expect(() => menu.categories.add(_category()), throwsUnsupportedError);
    });
  });
}
