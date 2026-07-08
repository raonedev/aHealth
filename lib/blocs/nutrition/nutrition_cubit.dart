import 'dart:developer';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../../models/nutrition_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'nutrition_state.dart';

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit() : super(NutritionLoading());

  Future<void> getNutritionData() async {
    emit(NutritionLoading());
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    bool stepsPermission =
        await Health().hasPermissions([HealthDataType.NUTRITION]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await Health().requestAuthorization(
        [HealthDataType.NUTRITION],
        permissions: [HealthDataAccess.READ_WRITE],
      );
    }

    try {
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.NUTRITION],
        startTime: midnight,
        endTime: now,
      );

      if (healthData.isEmpty) {
        emit(NutritionEmpty());
      } else {
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<NutritionModel> nutritionModel0 = [];
        for (HealthDataPoint healthDataPoint in healthData) {
          NutritionModel nutritionModel =
              NutritionModel.fromJson(healthDataPoint.toJson());
          nutritionModel0.add(nutritionModel);
        }
        emit(NutritionSuccess(nutritionModel: nutritionModel0));
      }
    } catch (e) {
      emit(NutritionFailed(errorMessage: e.toString()));
    }
  }

  // Helper function to determine meal type based on the hour of the day
  MealType _getMealType(int hour) {
    if (hour >= 5 && hour < 11) {
      log('breakfast');
      return MealType.BREAKFAST;
    } else if (hour >= 11 && hour < 16) {
      log('lunch');
      return MealType.LUNCH;
    } else if (hour >= 19 && hour < 23) {
      log('dinner');
      return MealType.DINNER;
    } else {
      log('snack');
      return MealType.SNACK; // Default to 'snack' for late-night or early hours
    }
  }

  Future<bool> addNutritionData({required ValueFood valueFood}) async {
    emit(NutritionLoading());
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 20));
    dev.log("logging : ${valueFood.name}");

    bool success = true;
    success &= await Health().writeMeal(
        mealType: _getMealType(now.hour),
        startTime: earlier,
        endTime: now,
        caloriesConsumed: valueFood.calories,
        protein: valueFood.protein,
        fatTotal: valueFood.fat,
        carbohydrates: valueFood.carbs,
        calcium: _mgToG(valueFood.calcium),
        cholesterol: _mgToG(valueFood.cholesterol),
        fiber: valueFood.fiber,
        iron: _mgToG(valueFood.iron),
        potassium: _mgToG(valueFood.potassium),
        sodium: _mgToG(valueFood.sodium),
        vitaminC: _mgToG(valueFood.vitaminC),
        vitaminA: _mgToG(valueFood.vitaminA),
        sugar: valueFood.sugar,
        name: valueFood.name,
        fatMonounsaturated: valueFood.monounsaturatedFat,
        recordingMethod: RecordingMethod.manual
        );
    if (success) {
      getNutritionData();
    } else {
      emit(NutritionFailed(errorMessage: "failed to add Nutririons"));
    }
    return success;
  }

  double? _mgToG(double? mg) => mg == null ? null : mg / 1000;

  Future<bool> addMultipleNutritionData({required List<ValueFood> selectedFoods}) async {
  // 1. Emit loading once for the entire batch operation
  emit(NutritionLoading());
  
  final now = DateTime.now();
  bool allSuccess = true;
  
  dev.log("Starting batch logging for ${selectedFoods.length} items...");

  try {
    for (int i = 0; i < selectedFoods.length; i++) {
      final valueFood = selectedFoods[i];
      
      // Slightly stagger the timestamps by a few seconds so Health Connect / Health Connect 
      // treats them as distinct records within the batch if processed quickly.
      final itemEndTime = now.subtract(Duration(seconds: i * 5));
      final itemStartTime = itemEndTime.subtract(const Duration(minutes: 20));

      dev.log("Batch logging item [${i + 1}/${selectedFoods.length}]: ${valueFood.name}");
      await Future.delayed(Durations.short4);

      bool success = await Health().writeMeal(
        mealType: _getMealType(itemEndTime.hour),
        startTime: itemStartTime,
        endTime: itemEndTime,
        caloriesConsumed: valueFood.calories,
        protein: valueFood.protein,
        fatTotal: valueFood.fat,
        carbohydrates: valueFood.carbs,
        calcium: _mgToG(valueFood.calcium),
        cholesterol: _mgToG(valueFood.cholesterol),
        fiber: valueFood.fiber,
        iron: _mgToG(valueFood.iron),
        potassium: _mgToG(valueFood.potassium),
        sodium: _mgToG(valueFood.sodium),
        sugar: valueFood.sugar,
        name: valueFood.name,
        vitaminC: _mgToG(valueFood.vitaminC),
        vitaminA: _mgToG(valueFood.vitaminA),
        fatMonounsaturated: valueFood.monounsaturatedFat,
        recordingMethod: RecordingMethod.manual,
      );

      allSuccess &= success;
    }
    
    if (allSuccess) {
      // 2. Refresh your main landing data once everything is written successfully
      await getNutritionData();
    } else {
      emit(NutritionFailed(errorMessage: "Failed to log some or all food items."));
    }
    
  } catch (e,s) {
    allSuccess = false;
    dev.log("Exception adding addMultipleNutritionData ",error: e,stackTrace: s);
    emit(NutritionFailed(errorMessage: "An error occurred while saving: $e"));
  }

  return allSuccess;
}
}
