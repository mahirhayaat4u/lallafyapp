import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';

/// Cart state — mirrors Zustand's useCartStore
///
/// 💡 React Native equivalent: This is like your Zustand store:
///   const { items, addItem, removeItem, updateQty, clearCart } = useCartStore()
///
/// In Flutter Riverpod, we use a StateNotifier to manage the cart state.
/// The cart is local-only (no API sync needed until checkout).

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  double get shipping => subtotal >= 999 ? 0 : 99;
  double get total => subtotal + shipping;
  bool get isEmpty => items.isEmpty;
  double get freeShippingRemaining => subtotal >= 999 ? 0 : 999 - subtotal;

  /// Group items by store (mirrors CartPage.tsx groups)
  Map<String, List<CartItem>> get groupedByStore {
    final map = <String, List<CartItem>>{};
    for (final item in items) {
      final key = item.storeId ?? 'default';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(CartItem item) {
    final existingIndex =
        state.items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      // Already in cart — increment quantity
      final updated = List<CartItem>.from(state.items);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, item]);
    }
  }

  void removeItem(String productId) {
    state = CartState(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQty(String productId, int newQty) {
    if (newQty <= 0) {
      removeItem(productId);
      return;
    }
    final updated = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: newQty.clamp(1, item.stock));
      }
      return item;
    }).toList();
    state = CartState(items: updated);
  }

  void clearCart() {
    state = const CartState();
  }
}

/// Cart provider — global app state
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
