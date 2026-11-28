import 'package:flutter/material.dart';

/// A cart icon button with a badge counting the units in the cart.
///
/// The badge is hidden when [itemCount] is 0. A screen reader reads the
/// button as "Cart, 3 items".
class CartBadge extends StatelessWidget {
  /// Creates the badge.
  const CartBadge({
    required this.itemCount,
    required this.onPressed,
    super.key,
  });

  /// The number of units in the cart, as `Cart.itemCount` counts them.
  final int itemCount;

  /// Called when the button is tapped, usually to open the cart.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final items = itemCount == 1 ? '1 item' : '$itemCount items';
    return IconButton(
      onPressed: onPressed,
      icon: Semantics(
        label: 'Cart, $items',
        excludeSemantics: true,
        child: Badge.count(
          count: itemCount,
          isLabelVisible: itemCount > 0,
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
