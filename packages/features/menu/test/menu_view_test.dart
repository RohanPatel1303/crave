import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/menu_feature.dart';

final _menu = Menu(
  restaurantId: 'sol',
  // A local time, so the notice shows it as written.
  fetchedAt: DateTime(2026, 11, 21, 15, 5),
  categories: [
    MenuCategory(
      id: 'tacos',
      name: 'Tacos',
      items: [
        MenuItem(
          id: 'al-pastor',
          name: 'Al pastor taco',
          description: 'Pork, pineapple, onion, cilantro',
          price: Money(450, currency: 'USD'),
          available: true,
        ),
      ],
    ),
    MenuCategory(
      id: 'sides',
      name: 'Sides',
      items: [
        MenuItem(
          id: 'elote',
          name: 'Elote',
          description: 'Grilled corn, cotija, lime',
          price: Money(1299, currency: 'USD'),
          available: false,
        ),
      ],
    ),
  ],
);

void main() {
  late int refreshCount;

  setUp(() => refreshCount = 0);

  Future<void> pumpView(WidgetTester tester, SyncedState<Menu> state) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MenuView(
            title: 'Taqueria Sol',
            state: state,
            onRefresh: () async => refreshCount++,
          ),
        ),
      );

  testWidgets('shows the title', (tester) async {
    await pumpView(tester, SyncedState(data: _menu, loaded: true));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Taqueria Sol'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a spinner before the database emits', (tester) async {
    await pumpView(tester, const SyncedState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a spinner while a refresh runs with no menu', (
    tester,
  ) async {
    await pumpView(tester, const SyncedState(loaded: true, refreshing: true));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('with no menu and a failure, shows the message and a Retry '
      'button that refreshes', (tester) async {
    await pumpView(
      tester,
      const SyncedState(
        loaded: true,
        refreshFailure: ServerFailure(statusCode: 503),
      ),
    );

    expect(find.text('The server is currently unavailable.'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    expect(refreshCount, 1);
  });

  testWidgets('shows each category header followed by its items', (
    tester,
  ) async {
    await pumpView(tester, SyncedState(data: _menu, loaded: true));

    expect(find.text('Tacos'), findsOneWidget);
    expect(find.text('Al pastor taco'), findsOneWidget);
    expect(find.text('Pork, pineapple, onion, cilantro'), findsOneWidget);
    expect(find.text('Sides'), findsOneWidget);
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Tacos'), lessThan(top('Al pastor taco')));
    expect(top('Al pastor taco'), lessThan(top('Sides')));
    expect(top('Sides'), lessThan(top('Elote')));
    expect(find.textContaining("Couldn't update"), findsNothing);
  });

  testWidgets('formats prices', (tester) async {
    await pumpView(tester, SyncedState(data: _menu, loaded: true));

    expect(find.text(r'$4.50'), findsOneWidget);
    expect(find.text(r'$12.99'), findsOneWidget);
  });

  testWidgets('draws an unavailable item as sold out, in the disabled '
      'colour, and says so to screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpView(tester, SyncedState(data: _menu, loaded: true));

    expect(find.text('Sold out'), findsOneWidget);

    final disabled = Theme.of(tester.element(find.text('Elote'))).disabledColor;
    Color? colorOf(String text) =>
        tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;
    expect(colorOf('Elote'), disabled);
    expect(colorOf('Al pastor taco'), isNot(disabled));

    expect(tester.getSemantics(find.text('Elote')).label, contains('Sold out'));
    expect(
      tester.getSemantics(find.text('Al pastor taco')).label,
      isNot(contains('Sold out')),
    );
    semantics.dispose();
  });

  testWidgets('with a menu and a failure, shows a notice with the saved '
      'date above the menu', (tester) async {
    await pumpView(
      tester,
      SyncedState(
        data: _menu,
        loaded: true,
        refreshFailure: const NetworkFailure(),
      ),
    );

    final notice = find.textContaining(
      "Couldn't update. Showing the menu saved on Nov 21, 2026",
    );
    expect(notice, findsOneWidget);
    expect(find.textContaining('3:05'), findsOneWidget);
    expect(find.text('Al pastor taco'), findsOneWidget);
    expect(
      tester.getTopLeft(notice).dy,
      lessThan(tester.getTopLeft(find.text('Tacos')).dy),
    );
  });
}
