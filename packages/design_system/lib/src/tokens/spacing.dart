/// Standard spacing values on the design system's 4-point grid.
abstract final class Spacing {
  // static const double none = 0.0;
  /// Extra-small spacing.
  static const double xs = 4;

  /// Small spacing.
  static const double sm = 8;

  /// Medium spacing.
  static const double md = 16;

  /// Large spacing.
  static const double lg = 24;

  /// Extra-large spacing.
  static const double xl = 32;
}

/// Standard corner radii on the design system's 4-point grid.
abstract final class Radii {
  // static const double none = 0.0;
  /// Small corner radius.
  static const double sm = 8;

  /// Medium corner radius.
  static const double md = 12;

  /// Large corner radius.
  static const double lg = 20;
}

/// Accessibility-related size constants.
abstract final class A11y {
  /// Minimum interactive target size in logical pixels.
  static const double minTapTargetSize = 48;
}
