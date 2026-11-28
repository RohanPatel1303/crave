import 'package:cart_feature/src/cart_state.dart';
import 'package:cart_feature/src/models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The cart screen for [state].
///
/// Shows a spinner until the cart has loaded, a message when it is empty, and
/// otherwise each line with a quantity stepper, the total, and a button that
/// clears the cart.
class CartView extends StatelessWidget {
  /// Creates the view.
  const CartView({
    required this.state,
    required this.onQuantityChanged,
    required this.onClear,
    super.key,
  });

  /// The cart and whether it has loaded.
  final CartState state;

  /// Called with a line's item ID and its new quantity. A quantity of 0
  /// removes the line.
  final void Function(String itemId, int quantity) onQuantityChanged;

  /// Called when the user clears the cart.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: switch ((state.loaded, cart)) {
        (false, _) => const Center(child: CircularProgressIndicator()),
        (true, null) => const Center(
          child: Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Text('Your cart is empty', textAlign: TextAlign.center),
          ),
        ),
        (true, final Cart cart) => _CartBody(
          cart: cart,
          onQuantityChanged: onQuantityChanged,
          onClear: onClear,
        ),
      },
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.cart,
    required this.onQuantityChanged,
    required this.onClear,
  });

  final Cart cart;
  final void Function(String itemId, int quantity) onQuantityChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            children: [
              for (final line in cart.lines)
                _CartLineRow(
                  line: line,
                  onQuantityChanged: (quantity) =>
                      onQuantityChanged(line.itemId, quantity),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Merged so a screen reader reads "Total" with the amount.
                MergeSemantics(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Total', style: textTheme.titleMedium),
                      ),
                      Text(
                        formatMoney(cart.total),
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: onClear,
                    child: const Text('Clear cart'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({required this.line, required this.onQuantityChanged});

  /// The largest quantity a line can have, which the cart storage enforces.
  static const _maxQuantity = 99;

  final CartLine line;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final quantity = line.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            // Merged so a screen reader reads the name with its unit price.
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.name, style: textTheme.bodyLarge),
                  Text(
                    '${formatMoney(line.unitPrice)} each',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove, semanticLabel: 'Remove one ${line.name}'),
            // At 1 this asks for 0, which removes the line.
            onPressed: () => onQuantityChanged(quantity - 1),
          ),
          // Its own node, so a screen reader announces only the new quantity
          // when it changes, not the whole row.
          Semantics(
            container: true,
            liveRegion: true,
            label: 'Quantity $quantity',
            excludeSemantics: true,
            child: Text('$quantity', style: textTheme.titleMedium),
          ),
          IconButton(
            icon: Icon(Icons.add, semanticLabel: 'Add one ${line.name}'),
            onPressed: quantity >= _maxQuantity
                ? null
                : () => onQuantityChanged(quantity + 1),
          ),
          const SizedBox(width: Spacing.sm),
          Text(formatMoney(line.lineTotal), style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
