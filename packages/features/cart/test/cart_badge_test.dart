import 'package:cart_feature/cart_feature.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int pressCount;

  setUp(() => pressCount = 0);

  Future<void> pumpBadge(WidgetTester tester, int itemCount) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: AppBar(
              actions: [
                CartBadge(itemCount: itemCount, onPressed: () => pressCount++),
              ],
            ),
          ),
        ),
      );

  testWidgets('shows a cart icon with the count', (tester) async {
    await pumpBadge(tester, 3);

    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('hides the count at 0', (tester) async {
    await pumpBadge(tester, 0);

    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('tapping calls onPressed', (tester) async {
    await pumpBadge(tester, 3);

    await tester.tap(find.byType(CartBadge));

    expect(pressCount, 1);
  });

  testWidgets('a screen reader reads it as a button with the count', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    for (final (count, label) in [
      (3, 'Cart, 3 items'),
      (1, 'Cart, 1 item'),
      (0, 'Cart, 0 items'),
    ]) {
      await pumpBadge(tester, count);
      expect(
        find.semantics.byLabel(label).evaluate().single,
        isSemantics(isButton: true, isEnabled: true),
        reason: label,
      );
    }
    semantics.dispose();
  });
}
