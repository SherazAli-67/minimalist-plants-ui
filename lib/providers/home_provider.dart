import 'package:flutter/material.dart';
import 'package:plants_app_ui/core/app_data.dart';
import 'package:plants_app_ui/core/models/plant_model.dart';

class HomeProvider extends ChangeNotifier {
  int selectedCategoryIndex = 0;
  final Set<String> favoriteIds = {};

  List<PlantModel> get filteredPlants {
    final category = AppData.categories[selectedCategoryIndex].name;
    return AppData.plants.where((plant) => plant.category == category).toList();
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
  }

  bool isFavorite(String plantId) => favoriteIds.contains(plantId);

  void toggleFavorite(String plantId) {
    if (favoriteIds.contains(plantId)) {
      favoriteIds.remove(plantId);
    } else {
      favoriteIds.add(plantId);
    }
    notifyListeners();
  }
}
