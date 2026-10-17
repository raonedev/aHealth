import 'dart:developer';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../features/streak/domain/entities/streak_entity.dart';
import '../../features/streak/presentation/cubit/streak_cubit.dart';
import '../../models/nutrition_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'nutrition_state.dart';

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit() : super(NutritionLoading());

  final Map<DateTime, List<NutritionModel>> _cache = {};
  DateTime selectedDate = DateTime.now();

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> getNutritionData({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    final targetDate = _dayKey(date ?? selectedDate);
    selectedDate = targetDate;
    emit(NutritionLoading());

    if (!forceRefresh && _cache.containsKey(targetDate)) {
      final cached = _cache[targetDate]!;
      emit(
        cached.isEmpty
            ? NutritionEmpty(date: targetDate)
            : NutritionSuccess(nutritionModel: cached, date: targetDate),
      );
      return;
    }

    try {
      final dayStart = targetDate;
      final dayEnd = _dayKey(DateTime.now()) == targetDate
          ? DateTime.now()
          : targetDate
                .add(const Duration(days: 1))
                .subtract(const Duration(seconds: 1));

      bool stepsPermission =
          await Health().hasPermissions([HealthDataType.NUTRITION]) ?? false;
      if (!stepsPermission) {
        stepsPermission = await Health().requestAuthorization(
          [HealthDataType.NUTRITION],
          permissions: [HealthDataAccess.READ_WRITE],
        );
      }
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.NUTRITION],
        startTime: dayStart,
        endTime: dayEnd,
      );

      if (healthData.isEmpty) {
        _cache[targetDate] = [];
        emit(NutritionEmpty(date: targetDate));
      } else {
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<NutritionModel> nutritionModel0 = [];
        for (HealthDataPoint healthDataPoint in healthData) {
          nutritionModel0.add(
            NutritionModel.fromJson(healthDataPoint.toJson()),
          );
        }
        _cache[targetDate] = nutritionModel0;
        emit(
          NutritionSuccess(nutritionModel: nutritionModel0, date: targetDate),
        );
      }
    } catch (e, s) {
      dev.log("Exception nutrition", error: e, stackTrace: s);
      emit(NutritionFailed(errorMessage: e.toString()));
    }
  }

  void invalidateCache(DateTime date) => _cache.remove(_dayKey(date));

  Future<bool> deleteNutritionData(NutritionModel model) async {
    if (model.uuid == null) {
      emit(NutritionFailed(errorMessage: "Invalid food log data"));
      return false;
    }
    emit(NutritionLoading());
    try {
      final success = await Health().deleteByUUID(
        type: HealthDataType.NUTRITION,
        uuid: model.uuid!,
      );
      if (success) {
        invalidateCache(selectedDate);
        await getNutritionData(date: selectedDate, forceRefresh: true);
      } else {
        emit(NutritionFailed(errorMessage: "Failed to delete food log"));
      }
      return success;
    } catch (e, s) {
      dev.log("Exception deleteNutritionData", error: e, stackTrace: s);
      emit(NutritionFailed(errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> updateNutritionQuantity({
    required NutritionModel model,
    required double quantity,
  }) async {
    final uuid = model.uuid;
    final valueFood = model.value;
    final oldQuantity = valueFood?.quantity ?? 1;
    final startTime = DateTime.tryParse(model.dateFrom ?? '');
    final endTime = DateTime.tryParse(model.dateTo ?? '');

    if (uuid == null ||
        valueFood == null ||
        !quantity.isFinite ||
        quantity < 0.001 ||
        !oldQuantity.isFinite ||
        oldQuantity < 0.001 ||
        startTime == null ||
        endTime == null) {
      emit(NutritionFailed(errorMessage: 'Invalid food log quantity'));
      return false;
    }

    final updatedValue = _nutritionAtQuantity(valueFood, quantity);
    emit(NutritionLoading());
    return _replaceNutritionMeal(
      uuid: uuid,
      originalValue: valueFood,
      updatedValue: updatedValue,
      startTime: startTime,
      endTime: endTime,
    );
  }

  ValueFood _nutritionAtQuantity(ValueFood valueFood, double quantity) {
    final multiplier = quantity / (valueFood.quantity ?? 1);
    return valueFood.copyWith(
      name: _nutritionNameWithQuantity(
        valueFood.displayName ?? 'Food',
        quantity,
      ),
      quantity: quantity,
      calories: _scale(valueFood.calories, multiplier),
      protein: _scale(valueFood.protein, multiplier),
      fat: _scale(valueFood.fat, multiplier),
      carbs: _scale(valueFood.carbs, multiplier),
      calcium: _scale(valueFood.calcium, multiplier),
      cholesterol: _scale(valueFood.cholesterol, multiplier),
      fiber: _scale(valueFood.fiber, multiplier),
      iron: _scale(valueFood.iron, multiplier),
      potassium: _scale(valueFood.potassium, multiplier),
      sodium: _scale(valueFood.sodium, multiplier),
      sugar: _scale(valueFood.sugar, multiplier),
      saturatedFat: _scale(valueFood.saturatedFat, multiplier),
      polyunsaturatedFat: _scale(valueFood.polyunsaturatedFat, multiplier),
      monounsaturatedFat: _scale(valueFood.monounsaturatedFat, multiplier),
      vitaminA: _scale(valueFood.vitaminA, multiplier),
      vitaminC: _scale(valueFood.vitaminC, multiplier),
    );
  }

  Future<bool> _replaceNutritionMeal({
    required String uuid,
    required ValueFood originalValue,
    required ValueFood updatedValue,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!await _deleteNutritionMeal(uuid)) {
      await _refreshNutritionData();
      emit(NutritionFailed(errorMessage: 'Failed to update food log'));
      return false;
    }

    final written = await _tryWriteNutritionMeal(
      valueFood: updatedValue,
      startTime: startTime,
      endTime: endTime,
      failureContext: 'writing updated food log',
    );
    if (!written) {
      final restored = await _tryWriteNutritionMeal(
        valueFood: originalValue,
        startTime: startTime,
        endTime: endTime,
        failureContext: 'restoring food log after failed quantity update',
      );
      await _refreshNutritionData();
      if (!restored) {
        emit(
          NutritionFailed(
            errorMessage:
                'Failed to update the food log and could not restore it.',
          ),
        );
      }
      return false;
    }

    await _refreshNutritionData();
    return true;
  }

  Future<bool> _deleteNutritionMeal(String uuid) async {
    try {
      return await Health().deleteByUUID(
        type: HealthDataType.NUTRITION,
        uuid: uuid,
      );
    } catch (error, stackTrace) {
      dev.log(
        'Exception deleting food log for quantity update',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _tryWriteNutritionMeal({
    required ValueFood valueFood,
    required DateTime startTime,
    required DateTime endTime,
    required String failureContext,
  }) async {
    try {
      return await _writeNutritionMeal(
        valueFood: valueFood,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (error, stackTrace) {
      dev.log('Exception $failureContext', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _refreshNutritionData() async {
    invalidateCache(selectedDate);
    await getNutritionData(date: selectedDate, forceRefresh: true);
  }

  double? _scale(double? value, double multiplier) =>
      value == null ? null : value * multiplier;

  String _nutritionNameWithQuantity(String name, double quantity) {
    final displayQuantity = quantity
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    final unit = quantity == 1 ? 'serving' : 'servings';
    return '$name ($displayQuantity $unit)';
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

  DateTime _timeForSelectedDate() {
    final n = DateTime.now();
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      n.hour,
      n.minute,
      n.second,
    );
  }

  Future<bool> addNutritionData({required ValueFood valueFood}) async {
    emit(NutritionLoading());
    try {
      final now = _timeForSelectedDate();
      final earlier = now.subtract(const Duration(minutes: 20));
      dev.log("logging : ${valueFood.name}");

      final healthValueFood = valueFood.copyWith(
        calcium: _mgToG(valueFood.calcium),
        cholesterol: _mgToG(valueFood.cholesterol),
        iron: _mgToG(valueFood.iron),
        potassium: _mgToG(valueFood.potassium),
        sodium: _mgToG(valueFood.sodium),
        vitaminC: _mgToG(valueFood.vitaminC),
        vitaminA: _mgToG(valueFood.vitaminA),
      );
      final success = await _writeNutritionMeal(
        valueFood: healthValueFood,
        startTime: earlier,
        endTime: now,
      );
      if (success) {
        invalidateCache(selectedDate);
        getNutritionData(date: selectedDate, forceRefresh: true);
        sl<StreakCubit>().logActivityAndRefresh(StreakActivityType.food);
        return true;
      } else {
        emit(NutritionFailed(errorMessage: "failed to add Nutririons"));
        return false;
      }
    } catch (e) {
      log("exception in addNutritionData", error: e);
      emit(NutritionFailed(errorMessage: "failed to add Nutririons"));
      return false;
    }
  }

  Future<bool> _writeNutritionMeal({
    required ValueFood valueFood,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return Health().writeMeal(
      mealType: _getMealType(endTime.hour),
      startTime: startTime,
      endTime: endTime,
      caloriesConsumed: valueFood.calories,
      protein: valueFood.protein,
      fatTotal: valueFood.fat,
      carbohydrates: valueFood.carbs,
      calcium: valueFood.calcium,
      cholesterol: valueFood.cholesterol,
      fiber: valueFood.fiber,
      iron: valueFood.iron,
      potassium: valueFood.potassium,
      sodium: valueFood.sodium,
      fatSaturated: valueFood.saturatedFat,
      fatPolyunsaturated: valueFood.polyunsaturatedFat,
      vitaminC: valueFood.vitaminC,
      vitaminA: valueFood.vitaminA,
      sugar: valueFood.sugar,
      name: valueFood.name,
      fatMonounsaturated: valueFood.monounsaturatedFat,
      recordingMethod: RecordingMethod.manual,
    );
  }

  double? _mgToG(double? mg) => mg == null ? null : mg / 1000;

  Future<bool> addMultipleNutritionData({
    required List<ValueFood> selectedFoods,
  }) async {
    // 1. Emit loading once for the entire batch operation
    emit(NutritionLoading());

    final now = _timeForSelectedDate();
    bool allSuccess = true;

    dev.log("Starting batch logging for ${selectedFoods.length} items...");

    try {
      for (int i = 0; i < selectedFoods.length; i++) {
        final valueFood = selectedFoods[i];

        // Slightly stagger the timestamps by a few seconds so Health Connect / Health Connect
        // treats them as distinct records within the batch if processed quickly.
        final itemEndTime = now.subtract(Duration(seconds: i * 5));
        final itemStartTime = itemEndTime.subtract(const Duration(minutes: 20));

        dev.log(
          "Batch logging item [${i + 1}/${selectedFoods.length}]: ${valueFood.name}",
        );
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
          name: '${valueFood.name} (${valueFood.servingDescription})',
          vitaminC: _mgToG(valueFood.vitaminC),
          vitaminA: _mgToG(valueFood.vitaminA),
          fatMonounsaturated: valueFood.monounsaturatedFat,
          recordingMethod: RecordingMethod.manual,
        );

        allSuccess &= success;
      }

      if (allSuccess) {
        invalidateCache(selectedDate);
        await getNutritionData(date: selectedDate, forceRefresh: true);
      } else {
        emit(
          NutritionFailed(
            errorMessage: "Failed to log some or all food items.",
          ),
        );
      }
    } catch (e, s) {
      allSuccess = false;
      dev.log(
        "Exception adding addMultipleNutritionData ",
        error: e,
        stackTrace: s,
      );
      emit(NutritionFailed(errorMessage: "An error occurred while saving: $e"));
    }

    return allSuccess;
  }
}
