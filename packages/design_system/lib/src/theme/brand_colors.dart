import 'package:flutter/material.dart';

/// Additional semantic colors used by the Crave design system.
@immutable
final class BrandColors extends ThemeExtension<BrandColors> {
  /// Creates semantic brand colors.
  const BrandColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.loyalty,
  });

  /// Semantic colors for light themes.
  static const BrandColors light = BrandColors(
    success: Color(0xFF166534),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFF92400E),
    onWarning: Color(0xFFFFFFFF),
    loyalty: Color(0xFF1D4ED8),
  );

  /// Semantic colors for dark themes.
  static const BrandColors dark = BrandColors(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF052E16),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF422006),
    loyalty: Color(0xFF93C5FD),
  );

  /// Color used to communicate successful outcomes.
  final Color success;

  /// Foreground color for content displayed on [success].
  final Color onSuccess;

  /// Color used to communicate warnings.
  final Color warning;

  /// Foreground color for content displayed on [warning].
  final Color onWarning;

  /// Color used for loyalty-related UI.
  final Color loyalty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandColors &&
          success == other.success &&
          onSuccess == other.onSuccess &&
          warning == other.warning &&
          onWarning == other.onWarning &&
          loyalty == other.loyalty;

  @override
  int get hashCode =>
      Object.hash(success, onSuccess, warning, onWarning, loyalty);

  @override
  BrandColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? loyalty,
  }) {
    return BrandColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      loyalty: loyalty ?? this.loyalty,
    );
  }

  @override
  BrandColors lerp(covariant BrandColors? other, double t) {
    if (other is! BrandColors) {
      return this;
    }
    if (t == 0) {
      return this;
    }
    if (t == 1) {
      return other;
    }

    return BrandColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      loyalty: Color.lerp(loyalty, other.loyalty, t)!,
    );
  }
}

/// Extension to access [BrandColors] from a widget's build context.
extension BrandColorsContextExtension on BuildContext {
  /// The [BrandColors] registered in the current theme.
  BrandColors get brandColors {
    final colors = Theme.of(this).extension<BrandColors>();
    if (colors == null) {
      throw FlutterError(
        'No BrandColors found in the current ThemeData. '
        'Use AppTheme.light or AppTheme.dark, or register BrandColors in '
        'ThemeData.extensions.',
      );
    }
    return colors;
  }
}
