import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu_feature/menu_feature.dart';

const _sol = Restaurant(id: 'sol', name: 'Taqueria Sol', cuisine: 'Mexican');
const _pho = Restaurant(id: 'pho', name: 'Pho Corner', cuisine: 'Vietnamese');

void main() {
  late int refreshCount;
  late List<Restaurant> selected;

  setUp(() {
    refreshCount = 0;
    selected = [];
  });

  Future<void> pumpView(
    WidgetTester tester,
    SyncedState<List<Restaurant>> state,
  ) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: RestaurantListView(
        state: state,
        onRefresh: () async => refreshCount++,
        onSelect: selected.add,
      ),
    ),
  );

  testWidgets('shows a spinner before the database emits', (tester) async {
    await pumpView(tester, const SyncedState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a spinner while a refresh runs with no data', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SyncedState(data: [], loaded: true, refreshing: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('with no data and a failure, shows the message and a Retry '
      'button that refreshes', (tester) async {
    await pumpView(
      tester,
      const SyncedState(
        data: [],
        loaded: true,
        refreshFailure: NetworkFailure(),
      ),
    );

    expect(find.text('You appear to be offline.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Retry'));
    expect(refreshCount, 1);
  });

  testWidgets('shows each restaurant with its name and cuisine', (
    tester,
  ) async {
    await pumpView(tester, const SyncedState(data: [_sol, _pho], loaded: true));

    expect(find.text('Taqueria Sol'), findsOneWidget);
    expect(find.text('Mexican'), findsOneWidget);
    expect(find.text('Pho Corner'), findsOneWidget);
    expect(find.text('Vietnamese'), findsOneWidget);
    expect(find.textContaining("Couldn't update"), findsNothing);
  });

  testWidgets('tapping a row selects that restaurant', (tester) async {
    await pumpView(tester, const SyncedState(data: [_sol, _pho], loaded: true));

    await tester.tap(find.text('Pho Corner'));

    expect(selected, [_pho]);
  });

  testWidgets('with data and a failure, shows a notice above the list', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SyncedState(
        data: [_sol],
        loaded: true,
        refreshFailure: NetworkFailure(),
      ),
    );

    expect(find.text("Couldn't update the list"), findsOneWidget);
    expect(find.text('Taqueria Sol'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Retry'), findsNothing);
    expect(
      tester.getTopLeft(find.text("Couldn't update the list")).dy,
      lessThan(tester.getTopLeft(find.text('Taqueria Sol')).dy),
    );
  });

  testWidgets('pulling down refreshes', (tester) async {
    await pumpView(tester, const SyncedState(data: [_sol], loaded: true));

    await tester.fling(find.text('Taqueria Sol'), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
  });

  testWidgets('with no restaurants and no failure, says there are none', (
    tester,
  ) async {
    await pumpView(tester, const SyncedState(data: [], loaded: true));

    expect(find.textContaining('No restaurants'), findsOneWidget);
  });
}
