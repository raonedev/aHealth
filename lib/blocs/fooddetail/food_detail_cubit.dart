import 'package:hive_flutter/hive_flutter.dart';

import '../../config/appconstants.dart';
import '../../models/food_with_servings_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'food_detail_state.dart';

class FoodDetailCubit extends Cubit<FoodDetailState> {
  FoodDetailCubit() : super(FoodDetailInitial());

  Future<void> fetchFoodDetails(String foodId) async {
    emit(FoodDetailLoading());
    if (foodId.isEmpty) {
      emit(const FoodDetailFailed(errorMessage: "foodId not found"));
      return;
    }

    final box = await Hive.openBox(foodDetailLocationHive);
    final FoodWithServingsModel? cached = box.get(foodId);
    if (cached != null) {
      emit(FoodDetailSuccess(foodWithServingsModel: cached));
    } else {
      emit(const FoodDetailFailed(errorMessage: "food details not found"));
    }
  }
}
