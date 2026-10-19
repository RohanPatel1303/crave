import 'package:core/core.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/di.dart';
import 'package:customer_app/app/router.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> registerConfigWithFlavor(Flavor flavor) async {
    await resetDependencies();
    getIt.registerSingleton<AppConfig>(
      AppConfig.parse(flavor: flavor, apiBaseUrl: 'https://api.example.com'),
    );
  }

  setUp(() => registerConfigWithFlavor(Flavor.staging));

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
    await registerConfigWithFlavor(Flavor.prod);

    await tester.pumpWidget(const CraveApp());

    expect(find.byType(Banner), findsNothing);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, 'Crave');
  });

  testWidgets('shows a not-found page for an unknown location', (tester) async {
    await tester.pumpWidget(
      CraveApp(router: createRouter(initialLocation: '/missing')),
    );

    expect(find.text('Page not found'), findsOneWidget);
  });
}
