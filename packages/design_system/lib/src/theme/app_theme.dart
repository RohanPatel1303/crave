import 'package:design_system/src/theme/brand_colors.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

/// Shared light and dark themes for the application.
abstract final class AppTheme {
  static const Color _brandSeed = Color(0xFF1D4ED8);

  /// The light application theme.
  static ThemeData get light =>
      _build(ColorScheme.fromSeed(seedColor: _brandSeed), BrandColors.light);

  /// The dark application theme.
  static ThemeData get dark => _build(
    ColorScheme.fromSeed(seedColor: _brandSeed, brightness: Brightness.dark),
    BrandColors.dark,
  );

  static ThemeData _build(ColorScheme scheme, BrandColors brand) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.md),
    );

    return ThemeData(
      colorScheme: scheme,
      extensions: [brand],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(A11y.minTapTargetSize, A11y.minTapTargetSize),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(A11y.minTapTargetSize, A11y.minTapTargetSize),
          shape: buttonShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
    );
  }
}
