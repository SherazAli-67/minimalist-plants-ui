import 'package:plants_app_ui/core/models/plant_model.dart';

class CartItemModel {
  final PlantModel plant;
  final int quantity;

  const CartItemModel({
    required this.plant,
    required this.quantity,
  });

  double get totalPrice => plant.price * quantity;
}
