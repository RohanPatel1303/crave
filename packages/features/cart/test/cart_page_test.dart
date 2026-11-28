import 'package:cart_feature/cart_feature.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';

void main() {
  testWidgets('the page shows the bloc state and sends the view callbacks to '
      'the bloc', (tester) async {
    // The database runs real async work, so the test drives it in runAsync.
    final db = inMemoryCraveDatabase();
    final repository = CartRepository(cartDao: CartDao(db));
    final bloc = CartBloc(repository: repository);

    Future<void> settle() async {
      await tester.runAsync(pumpEventQueue);
      await tester.pump();
    }

    await tester.runAsync(
      () => repository.add(
        restaurantId: 'taqueria-sol',
        itemId: 'al-pastor',
        name: 'Al pastor taco',
        unitPrice: Money(450, currency: 'USD'),
      ),
    );
    bloc.add(const CartStarted());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(value: bloc, child: const CartPage()),
      ),
    );
    await settle();
    expect(find.text('Al pastor taco'), findsOneWidget);
    expect(find.text(r'$4.50 each'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add one Al pastor taco'));
    await settle();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Clear cart'));
    await settle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await bloc.close();
      await db.close();
    });
  });
}
