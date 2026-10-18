import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double? width}) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  testWidgets('calls onPressed exactly once per tap', (tester) async {
    var pressedCount = 0;
    await tester.pumpWidget(
      _host(AppButton(label: 'Press me', onPressed: () => pressedCount++)),
    );

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(pressedCount, 1);
  });

  testWidgets('does nothing when onPressed is null', (tester) async {
    await tester.pumpWidget(
      _host(const AppButton(label: 'Disabled', onPressed: null)),
    );

    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    await tester.pump();
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.enabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores taps and shows a progress indicator while loading', (
    tester,
  ) async {
    var pressedCount = 0;
    await tester.pumpWidget(
      _host(
        AppButton(
          label: 'Loading',
          onPressed: () => pressedCount++,
          isLoading: true,
        ),
      ),
    );

    await tester.tap(find.byType(AppButton), warnIfMissed: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(pressedCount, 0);
  });

  testWidgets('keeps the same size while loading', (tester) async {
    await tester.pumpWidget(
      _host(const AppButton(label: 'Submit', onPressed: _noop)),
    );
    final idleSize = tester.getSize(find.byType(AppButton));

    await tester.pumpWidget(
      _host(
        const AppButton(label: 'Submit', onPressed: _noop, isLoading: true),
      ),
    );
    final loadingSize = tester.getSize(find.byType(AppButton));

    expect(loadingSize, idleSize);
  });

  testWidgets('idle and loading sizes meet the 48-by-48 minimum', (
    tester,
  ) async {
    for (final isLoading in [false, true]) {
      await tester.pumpWidget(
        _host(AppButton(label: 'I', onPressed: _noop, isLoading: isLoading)),
      );
      final size = tester.getSize(find.byType(AppButton));

      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('truncates a long label within a 120-pixel-wide box', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AppButton(label: 'Submit', onPressed: _noop), width: 120),
    );
    final shortLabelHeight = tester.getSize(find.byType(AppButton)).height;

    await tester.pumpWidget(
      _host(
        const AppButton(
          label:
              'This is a very long button label that should wrap without '
              'overflowing its available width.',
          onPressed: _noop,
        ),
        width: 120,
      ),
    );

    expect(tester.getSize(find.byType(AppButton)).height, shortLabelHeight);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary uses a FilledButton and secondary an OutlinedButton', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AppButton(label: 'Primary', onPressed: _noop)),
    );
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);

    await tester.pumpWidget(
      _host(
        const AppButton(
          label: 'Secondary',
          onPressed: _noop,
          variant: AppButtonVariant.secondary,
        ),
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('shows an optional icon only when provided', (tester) async {
    await tester.pumpWidget(
      _host(
        const AppButton(
          label: 'Save',
          onPressed: _noop,
          icon: Icon(Icons.save),
        ),
      ),
    );
    expect(find.byIcon(Icons.save), findsOneWidget);

    await tester.pumpWidget(
      _host(const AppButton(label: 'Save', onPressed: _noop)),
    );
    expect(find.byIcon(Icons.save), findsNothing);
  });

  testWidgets('idle semantics expose the label and enabled button state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const AppButton(label: 'Pay', onPressed: _noop)),
    );

    expect(find.bySemanticsLabel('Pay'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(FilledButton)),
      isSemantics(
        label: 'Pay',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('loading semantics announce the label and loading state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const AppButton(label: 'Pay', onPressed: _noop, isLoading: true)),
    );

    expect(find.bySemanticsLabel('Pay, loading'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('disabled semantics expose a button that is not enabled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const AppButton(label: 'Pay', onPressed: null)),
    );

    expect(
      tester.getSemantics(find.byType(FilledButton)),
      isSemantics(label: 'Pay', isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });
}

void _noop() {}
