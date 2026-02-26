import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../items/domain/entities/item_entity.dart';

final cartItemsProvider = NotifierProvider<CartItemsNotifier, List<ItemEntity>>(
  CartItemsNotifier.new,
);

final checkoutItemsProvider =
    NotifierProvider<CheckoutItemsNotifier, List<ItemEntity>>(
  CheckoutItemsNotifier.new,
);

class CartItemsNotifier extends Notifier<List<ItemEntity>> {
  @override
  List<ItemEntity> build() => [];

  void addItem(ItemEntity item) {
    final alreadyInCart = _containsItem(item);
    if (alreadyInCart) return;
    state = [...state, item];
  }

  void removeItem(ItemEntity item) {
    if (item.id != null) {
      state = state.where((existing) => existing.id != item.id).toList();
      return;
    }
    state = state.where((existing) => existing != item).toList();
  }

  void clear() {
    state = [];
  }

  bool _containsItem(ItemEntity item) {
    if (item.id != null) {
      return state.any((existing) => existing.id == item.id);
    }
    return state.contains(item);
  }
}

class CheckoutItemsNotifier extends Notifier<List<ItemEntity>> {
  @override
  List<ItemEntity> build() => [];

  void addItem(ItemEntity item) {
    final alreadyInCheckout = _containsItem(item);
    if (alreadyInCheckout) return;
    state = [...state, item];
  }

  void removeItem(ItemEntity item) {
    if (item.id != null) {
      state = state.where((existing) => existing.id != item.id).toList();
      return;
    }
    state = state.where((existing) => existing != item).toList();
  }

  void clear() {
    state = [];
  }

  bool _containsItem(ItemEntity item) {
    if (item.id != null) {
      return state.any((existing) => existing.id == item.id);
    }
    return state.contains(item);
  }
}
