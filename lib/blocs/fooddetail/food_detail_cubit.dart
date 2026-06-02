import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../config/appconstants.dart';
import '../../models/food_with_servings_model.dart';
import '../../secrets/secrets.dart';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

part 'food_detail_state.dart';

class FoodDetailCubit extends Cubit<FoodDetailState> {
  FoodDetailCubit() : super(FoodDetailInitial());

  void fetchFoodDetails(String foodId) async {
    emit(FoodDetailLoading());
    if (foodId.isEmpty) {
      emit(const FoodDetailFailed(errorMessage: "foodId not found"));
      return;
    }

    await Hive.openBox(foodDetailLocationHive);
    Box foodDetailBox = Hive.box(foodDetailLocationHive);
    FoodWithServingsModel? isFoodFound = foodDetailBox.get(foodId);
    if (isFoodFound != null) {
      dev.log("foodDetail from cache");
      final cachedValue= FoodDetailSuccess(foodWithServingsModel: isFoodFound);
      emit(cachedValue);
      return;
    }

    try {
      final uri = Uri.parse('https://8ggapbx887.execute-api.ap-south-1.amazonaws.com/foods/details')
          .replace(queryParameters: {'foodId': foodId});

      final response = await http.get(uri);
      dev.log('Status: ${response.statusCode}');
      dev.log('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        FoodWithServingsModel foodServingModel = FoodWithServingsModel.fromJson(data);
        foodDetailBox.put(foodId, foodServingModel);
        dev.log("foodDetail added of id $foodId");
        emit(FoodDetailSuccess(foodWithServingsModel: foodServingModel));
      } else {
        emit(FoodDetailFailed(errorMessage: 'Error: ${response.statusCode} - ${response.body}'));
      }
    } catch (e) {
      dev.log('Exception: $e');
      emit(FoodDetailFailed(errorMessage: 'Exception: $e'));
    }
  }
}
