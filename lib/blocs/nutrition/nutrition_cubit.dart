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

  Future<bool> addNutritionData({required MealType mealType,required NutritionModel nutritionModel})async{
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(minutes: 20));
    bool success = true;
    if(nutritionModel.value!=null){
      success &= await Health().writeMeal(
          mealType: mealType,
          startTime: earlier,
          endTime: now,
          caloriesConsumed: nutritionModel.value!.calories,
          protein: nutritionModel.value!.protein,
          fatTotal: nutritionModel.value!.fat,
          carbohydrates: nutritionModel.value!.carbs,
          calcium: nutritionModel.value!.calcium,
          cholesterol: nutritionModel.value!.cholesterol,
          fiber: nutritionModel.value!.fiber,
          iron: nutritionModel.value!.iron,
          potassium: nutritionModel.value!.potassium,
          sodium: nutritionModel.value!.sodium,
          sugar: nutritionModel.value!.sugar,
          name: nutritionModel.value!.name,
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
          recordingMethod: RecordingMethod.manual);
      return success;
    }else{
      return false;
    }



  }
}
