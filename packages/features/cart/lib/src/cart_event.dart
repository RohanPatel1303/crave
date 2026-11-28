part of 'cart_bloc.dart';

/// Input to [CartBloc].
sealed class CartEvent {
  const CartEvent();
}

/// Starts watching the stored cart.
final class CartStarted extends CartEvent {
  /// Creates the start event.
  const CartStarted();
}

/// The user changed the quantity of the line for [itemId]. A [quantity] of 0
/// removes the line.
final class CartQuantityChanged extends CartEvent {
  /// Creates a quantity change for [itemId].
  const CartQuantityChanged(this.itemId, this.quantity);

  /// The item whose line changes.
  final String itemId;

  /// The new quantity, from 0 to 99.
  final int quantity;
}

/// The user emptied the cart.
final class CartCleared extends CartEvent {
  /// Creates the clear event.
  const CartCleared();
}

/// Added by the bloc itself when the stored cart changes, with `null` when
/// the cart is empty.
final class _CartChanged extends CartEvent {
  const _CartChanged(this.cart);

  final Cart? cart;
}
