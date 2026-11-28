import 'dart:async';

import 'package:cart_feature/src/cart_repository.dart';
import 'package:cart_feature/src/cart_state.dart';
import 'package:cart_feature/src/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_event.dart';

/// The cart stored on the device.
///
/// Changes go to the repository, and the new cart arrives through
/// [CartRepository.watchCart]. Adding an item is not an event here: the app
/// calls [CartRepository.add] itself, because a cart holding another
/// restaurant's items needs a dialog.
class CartBloc extends Bloc<CartEvent, CartState> {
  /// Creates a bloc that reads and changes the cart through `repository`.
  CartBloc({required this._repository}) : super(const CartState()) {
    on<CartStarted>(_onStarted);
    on<_CartChanged>(_onChanged);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartCleared>(_onCleared);
  }

  final CartRepository _repository;
  StreamSubscription<Cart?>? _subscription;

  void _onStarted(CartStarted event, Emitter<CartState> emit) {
    _subscription ??= _repository.watchCart().listen(
      (cart) => add(_CartChanged(cart)),
    );
  }

  void _onChanged(_CartChanged event, Emitter<CartState> emit) {
    emit(CartState(loaded: true, cart: event.cart));
  }

  Future<void> _onQuantityChanged(
    CartQuantityChanged event,
    Emitter<CartState> emit,
  ) => _repository.setQuantity(event.itemId, event.quantity);

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) =>
      _repository.clear();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
