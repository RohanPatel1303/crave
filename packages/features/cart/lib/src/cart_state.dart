import 'package:cart_feature/src/models.dart';
import 'package:meta/meta.dart';

/// The state of `CartBloc`: the cart as stored on the device.
@immutable
final class CartState {
  /// Creates a state. The defaults describe a state before the database has
  /// emitted anything.
  const CartState({this.loaded = false, this.cart});

  /// Whether the database has emitted at least once. When it is true and
  /// [cart] is null, the cart is empty.
  final bool loaded;

  /// The cart, or null when it is empty or not yet loaded.
  final Cart? cart;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState && other.loaded == loaded && other.cart == cart;

  @override
  int get hashCode => Object.hash(loaded, cart);

  @override
  String toString() => 'CartState(loaded: $loaded, cart: $cart)';
}
