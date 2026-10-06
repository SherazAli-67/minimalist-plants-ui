import 'package:flutter/material.dart';
import 'package:plants_app_ui/core/app_data.dart';
import 'package:plants_app_ui/core/models/cart_item_model.dart';
import 'package:plants_app_ui/core/models/plant_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [...AppData.cartItems];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get deliveryAmount => AppData.deliveryAmount;

  double get cartTotal =>
      _items.fold<double>(0, (sum, item) => sum + item.totalPrice) + deliveryAmount;

  void addToCart(PlantModel plant) {
    final index = _items.indexWhere((item) => item.plant.id == plant.id);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = CartItemModel(plant: existing.plant, quantity: existing.quantity + 1);
    } else {
      _items.add(CartItemModel(plant: plant, quantity: 1));
    }
    notifyListeners();
  }
}
