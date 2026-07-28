import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../profileinfo/activity_factor.dart';

class NutritionTargets {
  final int bmr;
  final int tdee;
  final int target;
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final String activityLabel;

  NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.target,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.activityLabel,
  });
}

class TargetCalorieCalculator {
  static Future<NutritionTargets> calculate() async {
    final prefs = await SharedPreferences.getInstance();

    final weight = prefs.getDouble(PrefKeys.weight) ?? 70;
    final height = prefs.getDouble(PrefKeys.height) ?? 170;
    final age = prefs.getInt(PrefKeys.age) ?? 25;
    final gender = prefs.getString(PrefKeys.gender) ?? 'male';
    final goal = prefs.getString(PrefKeys.healthGoal) ?? 'maintainWeight';

    final bmr = gender == 'female'
        ? (10 * weight) + (6.25 * height) - (5 * age) - 161
        : (10 * weight) + (6.25 * height) - (5 * age) + 5;

    final activityLevelStr =
        prefs.getString(PrefKeys.activityLevel) ?? 'lightlyActive';
    final activityLevel = ActivityLevel.values.firstWhere(
      (e) => e.name == activityLevelStr,
      orElse: () => ActivityLevel.lightlyActive,
    );
    final tdee = bmr * activityLevel.factor;

    final targetCalories = switch (goal) {
      'lossWeight' => tdee - 500,
      'gainWeight' => tdee + 500,
      'gainMuscle' => tdee + 300,
      _ => tdee,
    };

    // Protein
    final proteinPerKg = switch (goal) {
      'lossWeight' => 2.0,
      'gainWeight' => 1.8,
      'gainMuscle' => 2.0,
      _ => 1.6,
    };

    final protein = weight * proteinPerKg; // g

    // Fat
    final fat = weight * 1.0; // g

    // Remaining calories go to carbs
    final proteinCalories = protein * 4;
    final fatCalories = fat * 9;
    final carbCalories = targetCalories - proteinCalories - fatCalories;
    final carbs = carbCalories / 4;

    const labels = {
      ActivityLevel.sedentary: 'Sedentary',
      ActivityLevel.lightlyActive: 'Lightly active',
      ActivityLevel.moderatelyActive: 'Moderately active',
      ActivityLevel.veryActive: 'Very active',
      ActivityLevel.extraActive: 'Extra active',
    };

    return NutritionTargets(
      bmr: bmr.round(),
      tdee: tdee.round(),
      target: targetCalories.round(),
      protein: protein,
      carbs: carbs,
      fat: fat,
      activityLabel: labels[activityLevel]!,
    );
  }
}
