import 'package:core/core.dart';
import 'package:customer_app/app.dart';
import 'package:customer_app/app/di.dart';
import 'package:customer_app/app/router.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    getIt.registerSingleton<AppConfig>(
      AppConfig.parse(
        flavor: Flavor.staging,
        apiBaseUrl: 'https://api.example.com',
      ),
    );
  });

  tearDown(resetDependencies);

  testWidgets('shows the home page and a non-production flavor banner', (
    tester,
  ) async {
    await tester.pumpWidget(const CraveApp());

    expect(find.text('What are you craving?'), findsOneWidget);
    expect(
      find.text('Discover something delicious, made just for you.'),
      findsOneWidget,
    );
    expect(find.text('Start an order'), findsOneWidget);
    expect(
      tester.widget<Banner>(find.byType(Banner)).message,
      Flavor.staging.name,
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme, AppTheme.light);
    expect(materialApp.darkTheme, AppTheme.dark);
  });

  testWidgets('does not show a flavor banner in production', (tester) async {
    await resetDependencies();
    getIt.registerSingleton<AppConfig>(
      AppConfig.parse(
        flavor: Flavor.prod,
        apiBaseUrl: 'https://api.example.com',
      ),
    );

    await tester.pumpWidget(const CraveApp());

    expect(find.byType(Banner), findsNothing);
  });

  testWidgets('shows a not-found page for an unknown location', (tester) async {
    await tester.pumpWidget(
      CraveApp(router: createRouter(initialLocation: '/missing')),
    );

    expect(find.text('Page not found'), findsOneWidget);
  });

  test('defines the home route', () {
    expect(Routes.home, '/');
  });
}
