import 'dart:developer';

import '../../models/NutritionModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health/health.dart';

part 'nutrition_state.dart';

class NutritionCubit extends Cubit<NutritionState> {
  NutritionCubit() : super(NutritionLoading());

  Future<void> getNutritionData()async{
    emit(NutritionLoading());
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    bool stepsPermission = await Health().hasPermissions([HealthDataType.NUTRITION]) ?? false;
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

      if(healthData.isEmpty){
        emit(const NutritionFailed(errorMessage: "NULL"));
      }else{
        // sort the data points by date
        healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        List<NutritionModel> nutritionModel0=[];
        for(HealthDataPoint healthDataPoint in healthData){
          NutritionModel stepModel = NutritionModel.fromJson(healthDataPoint.toJson());
          nutritionModel0.add(stepModel);
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

  Future<bool> addNutritionData({required ValueFood valueFood})async{
    emit(NutritionLoading());
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 20));

    bool success = true;
    success &= await Health().writeMeal(
          mealType: _getMealType(now.hour),
          startTime: earlier,
          endTime: now,
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
          sugar: valueFood.sugar,
          name: valueFood.name,
          vitaminC: valueFood.vitaminC,
          vitaminA: valueFood.vitaminA,
          fatMonounsaturated: valueFood.monounsaturatedFat,

          recordingMethod: RecordingMethod.manual
          // caffeine: 0.002,
          // vitaminA: 0.001,
          // vitaminC: 0.002,
          // vitaminD: 0.003,
          // vitaminE: 0.004,
          // vitaminK: 0.005,
          // b1Thiamin: 0.006,
          // b2Riboflavin: 0.007,
          // b3Niacin: 0.008,
          // b5PantothenicAcid: 0.009,
          // b6Pyridoxine: 0.010,
          // b7Biotin: 0.011,
          // b9Folate: 0.012,
          // b12Cobalamin: 0.013,
          // copper: 0.016,
          // iodine: 0.017,
          // magnesium: 0.019,
          // manganese: 0.020,
          // phosphorus: 0.021,
          // selenium: 0.023,
          // zinc: 0.025,
          // water: 0.026,
          // molybdenum: 0.027,
          // chloride: 0.028,
          // chromium: 0.029,
          );
    if(success){
      getNutritionData();
    }else{
      emit(NutritionFailed(errorMessage: "failed to add Nutririons"));
    }
      return success;




  }
}
