import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/nutrition_model.dart';
import '../../../services/nutrition_service.dart';
import '../nutrition_group/models/food_scan_group_model.dart';

class FoodImage extends StatelessWidget {
  const FoodImage({super.key, required this.item});
  final NutritionModel item;

  @override
  Widget build(BuildContext context) {

    final groups = NutritionService.getAllGroups();
    final group = groups.cast<FoodScanGroup?>().firstWhere(
      (g) => g!.foods.any((f) =>
          item.value?.name != null &&
          f.name != null &&
          item.value!.name!.startsWith(f.name!)),
      orElse: () => null,
    );

    if (group != null) {
      final file = File(group.imagePath);
      if (file.existsSync()) {
        return Image.file(file, width: 60, height: 60, fit: BoxFit.cover);
      }
    }

    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade100,
      child: Icon(Icons.restaurant, color: Colors.grey.shade400),
    );

  }
}
