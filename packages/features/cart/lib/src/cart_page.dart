import 'package:cart_feature/src/cart_bloc.dart';
import 'package:cart_feature/src/cart_state.dart';
import 'package:cart_feature/src/cart_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows the [CartBloc]'s state, read from the widget tree.
///
/// The app provides the bloc and adds [CartStarted]. The app bar has no
/// `CartBadge`, because this is the cart.
class CartPage extends StatelessWidget {
  /// Creates the page.
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) => CartView(
        state: state,
        onQuantityChanged: (itemId, quantity) =>
            context.read<CartBloc>().add(CartQuantityChanged(itemId, quantity)),
        onClear: () => context.read<CartBloc>().add(const CartCleared()),
      ),
    );
  }
}
