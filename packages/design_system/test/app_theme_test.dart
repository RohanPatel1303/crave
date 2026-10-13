import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light theme provides BrandColors.light', (tester) async {
    late BrandColors colors;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            colors = context.brandColors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors, same(BrandColors.light));
  });

  testWidgets('dark theme provides BrandColors.dark and dark brightness', (
    tester,
  ) async {
    late BrandColors colors;
    late Brightness brightness;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            colors = context.brandColors;
            brightness = Theme.of(context).colorScheme.brightness;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors, same(BrandColors.dark));
    expect(brightness, Brightness.dark);
  });

  testWidgets('FilledButton meets the 48-by-48 minimum size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: FilledButton(onPressed: () {}, child: const Text('Go')),
          ),
        ),
      ),
    );

    final buttonSize = tester.getSize(find.byType(FilledButton));

    expect(buttonSize.width, greaterThanOrEqualTo(48));
    expect(buttonSize.height, greaterThanOrEqualTo(48));
  });

  testWidgets('missing BrandColors reports how to fix the theme', (
    tester,
  ) async {
    late BuildContext context;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (buildContext) {
            context = buildContext;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      () => context.brandColors,
      throwsA(
        isA<FlutterError>().having(
          (error) => error.message,
          'message',
          contains('Use AppTheme.light or AppTheme.dark'),
        ),
      ),
    );
  });
}
