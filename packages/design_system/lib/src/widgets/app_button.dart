import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

/// The visual style used by an [AppButton].
enum AppButtonVariant {
  /// Filled button for primary actions.
  primary,

  /// Outlined button for secondary actions.
  secondary,
}

/// A themed button with loading and accessibility-safe tap behavior.
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  /// Text displayed by the button.
  final String label;

  /// Called once when the enabled button is tapped.
  final VoidCallback? onPressed;

  /// The visual style of this button.
  final AppButtonVariant variant;

  /// An optional leading widget, usually an [Icon]. Icons are sized and
  /// colored by the button's theme; other widgets are not resized.
  final Widget? icon;

  /// Whether the button is showing its progress indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final handler = isLoading ? null : onPressed;
    final content = Semantics(
      label: isLoading ? '$label, loading' : label,
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: Spacing.sm)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox.square(
              dimension: Sizing.spinnerSize,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );

    // Accept the disabled styling and semantics while loading; null prevents
    // repeated taps until the operation finishes.
    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: handler,
        child: content,
      ),
    };
  }
}
