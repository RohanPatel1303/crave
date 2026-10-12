import 'dart:ui';

import 'package:design_system/src/theme/brand_colors.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:test/test.dart';

void main() {
  test('spacing tokens follow the 4-point grid and grow in order', () {
    const values = [Spacing.xs, Spacing.sm, Spacing.md, Spacing.lg, Spacing.xl];

    _expectGridAndIncreasingOrder(values, 'Spacing');
  });

  test('radius tokens follow the 4-point grid and grow in order', () {
    const values = [Radii.sm, Radii.md, Radii.lg];

    _expectGridAndIncreasingOrder(values, 'Radius');
  });

  test('minimum tap target meets the 48-point accessibility guideline', () {
    expect(A11y.minTapTargetSize, greaterThanOrEqualTo(48));
  });

  test('copyWith with one argument changes only that field', () {
    const original = BrandColors.light;
    final updated = original.copyWith(success: const Color(0xFF000000));

    expect(updated.success, equals(const Color(0xFF000000)));
    expect(updated.onSuccess, equals(original.onSuccess));
    expect(updated.warning, equals(original.warning));
    expect(updated.onWarning, equals(original.onWarning));
    expect(updated.loyalty, equals(original.loyalty));
  });

  test('lerp with t=0 returns the original color and '
      't=1 returns the target color', () {
    const original = BrandColors.light;
    const target = BrandColors.dark;
    final result0 = original.lerp(target, 0);
    final result1 = original.lerp(target, 1);

    expect(result0, equals(original));
    expect(result1, equals(target));
  });

  test('lerp halfway differs from both ends', () {
    const original = BrandColors.light;
    const target = BrandColors.dark;
    final resultHalf = original.lerp(target, 0.5);

    for (final colors in [
      (resultHalf.success, original.success, target.success),
      (resultHalf.onSuccess, original.onSuccess, target.onSuccess),
      (resultHalf.warning, original.warning, target.warning),
      (resultHalf.onWarning, original.onWarning, target.onWarning),
      (resultHalf.loyalty, original.loyalty, target.loyalty),
    ]) {
      expect(colors.$1, isNot(colors.$2));
      expect(colors.$1, isNot(colors.$3));
    }
  });

  test('lerp(null,0.5) returns this', () {
    const original = BrandColors.light;
    final resultHalf = original.lerp(null, 0.5);

    expect(resultHalf, equals(original));
  });

  test('on-colors meet 4.5:1 contrast against success and warning '
      'in both themes', () {
    for (final colors in [BrandColors.light, BrandColors.dark]) {
      expect(
        _calculateContrast(colors.success, colors.onSuccess),
        greaterThanOrEqualTo(4.5),
        reason: 'Success contrast should pass in $colors',
      );
      expect(
        _calculateContrast(colors.warning, colors.onWarning),
        greaterThanOrEqualTo(4.5),
        reason: 'Warning contrast should pass in $colors',
      );
    }
  });
}

void _expectGridAndIncreasingOrder(List<double> values, String tokenName) {
  for (var index = 0; index < values.length; index++) {
    expect(
      values[index] % 4,
      0,
      reason: '${values[index]} should be a multiple of 4',
    );

    if (index > 0) {
      expect(
        values[index],
        greaterThan(values[index - 1]),
        reason: '$tokenName values should increase from left to right',
      );
    }
  }
}

double _calculateContrast(Color color1, Color color2) {
  final luminance1 = color1.computeLuminance();
  final luminance2 = color2.computeLuminance();

  final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
  final darker = luminance1 > luminance2 ? luminance2 : luminance1;

  return (lighter + 0.05) / (darker + 0.05);
}
