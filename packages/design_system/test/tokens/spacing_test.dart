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
