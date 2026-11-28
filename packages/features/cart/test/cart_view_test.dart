import 'package:cart_feature/cart_feature.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Money _usd(int minorUnits) => Money(minorUnits, currency: 'USD');

CartLine _pastor({int quantity = 2}) => CartLine(
  itemId: 'al-pastor',
  name: 'Al pastor taco',
  unitPrice: _usd(450),
  quantity: quantity,
);

CartLine _horchata({int quantity = 1}) => CartLine(
  itemId: 'horchata',
  name: 'Horchata',
  unitPrice: _usd(500),
  quantity: quantity,
);

CartState _loaded(List<CartLine> lines) => CartState(
  loaded: true,
  cart: Cart(restaurantId: 'taqueria-sol', lines: lines),
);

void main() {
  late List<(String, int)> quantityChanges;
  late int clearCount;

  setUp(() {
    quantityChanges = [];
    clearCount = 0;
  });

  Future<void> pumpView(WidgetTester tester, CartState state) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CartView(
            state: state,
            onQuantityChanged: (itemId, quantity) =>
                quantityChanges.add((itemId, quantity)),
            onClear: () => clearCount++,
          ),
        ),
      );

  /// The row of the line whose item is called [name].
  Finder row(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(Row)).first;

  testWidgets('shows a spinner before the cart has loaded', (tester) async {
    await pumpView(tester, const CartState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Your cart is empty'), findsNothing);
  });

  testWidgets('shows a message when the cart is empty', (tester) async {
    await pumpView(tester, const CartState(loaded: true));

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Clear cart'), findsNothing);
  });

  testWidgets('the app bar says Cart and has no badge', (tester) async {
    await pumpView(tester, _loaded([_pastor()]));

    final appBar = find.byType(AppBar);
    expect(
      find.descendant(of: appBar, matching: find.text('Cart')),
      findsOneWidget,
    );
    expect(find.byType(CartBadge), findsNothing);
    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('each line shows its name, unit price, quantity and line '
      'total', (tester) async {
    await pumpView(tester, _loaded([_pastor(), _horchata()]));

    final pastor = row('Al pastor taco');
    for (final text in [r'$4.50 each', '2', r'$9.00']) {
      expect(
        find.descendant(of: pastor, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }
    final horchata = row('Horchata');
    for (final text in [r'$5.00 each', '1', r'$5.00']) {
      expect(
        find.descendant(of: horchata, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }
  });

  testWidgets('shows the total and a Clear cart text button', (tester) async {
    await pumpView(tester, _loaded([_pastor(), _horchata()]));

    final totalRow = row('Total');
    expect(
      find.descendant(of: totalRow, matching: find.text(r'$14.00')),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Clear cart'), findsOneWidget);
  });

  testWidgets('+ and − change the quantity by one', (tester) async {
    await pumpView(tester, _loaded([_pastor()]));

    await tester.tap(find.bySemanticsLabel('Add one Al pastor taco'));
    await tester.tap(find.bySemanticsLabel('Remove one Al pastor taco'));

    expect(quantityChanges, [('al-pastor', 3), ('al-pastor', 1)]);
  });

  testWidgets('− at quantity 1 asks for 0, which removes the line', (
    tester,
  ) async {
    await pumpView(tester, _loaded([_horchata()]));

    await tester.tap(find.bySemanticsLabel('Remove one Horchata'));

    expect(quantityChanges, [('horchata', 0)]);
  });

  testWidgets('+ is disabled at 99', (tester) async {
    await pumpView(tester, _loaded([_pastor(quantity: 99)]));

    final add = find.widgetWithIcon(IconButton, Icons.add);
    expect(tester.widget<IconButton>(add).onPressed, isNull);
    await tester.tap(add, warnIfMissed: false);
    expect(quantityChanges, isEmpty);

    // − still works at 99.
    await tester.tap(find.bySemanticsLabel('Remove one Al pastor taco'));
    expect(quantityChanges, [('al-pastor', 98)]);
  });

  testWidgets('Clear cart calls onClear', (tester) async {
    await pumpView(tester, _loaded([_pastor()]));

    await tester.tap(find.text('Clear cart'));

    expect(clearCount, 1);
  });

  testWidgets('the stepper buttons name the item, and the quantity is a live '
      'region', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpView(tester, _loaded([_pastor(quantity: 99), _horchata()]));

    SemanticsNode node(String label) =>
        find.semantics.byLabel(label).evaluate().single;

    expect(
      node('Remove one Al pastor taco'),
      isSemantics(isButton: true, isEnabled: true),
    );
    expect(
      node('Remove one Horchata'),
      isSemantics(isButton: true, isEnabled: true),
    );
    expect(
      node('Add one Horchata'),
      isSemantics(isButton: true, isEnabled: true),
    );
    expect(
      node('Add one Al pastor taco'),
      isSemantics(isButton: true, isEnabled: false),
    );
    expect(node('Quantity 99'), isSemantics(isLiveRegion: true));
    expect(node('Quantity 1'), isSemantics(isLiveRegion: true));
    semantics.dispose();
  });
}
