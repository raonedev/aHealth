import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ahealth/models/food_search_model.dart';

import '../../secrets/secrets.dart';

part 'food_search_state.dart';

const String _baseUrl = 'https://8ggapbx887.execute-api.ap-south-1.amazonaws.com';

class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit() : super(FoodSearchInitailize());

  Future<void> searchFood(String query, {int page = 0, int limit = 20}) async {
    if (query.isEmpty) {
      emit(const FoodSearchFailed(errorMessage: "Please enter food"));
      return;
    }
    emit(FoodSearchLoading());

    try {
      final uri = Uri.parse('$_baseUrl/foods/search').replace(queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(uri);
      dev.log('Search status: ${response.statusCode}');
      dev.log('Search response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        emit(FoodSearchSuccess(
            foodSearchModel: FoodSearchModel.fromJson(decoded)));
      } else {
        emit(FoodSearchFailed(
            errorMessage: 'Error: ${response.statusCode} ${response.body}'));
      }
    } catch (e) {
      emit(FoodSearchFailed(errorMessage: e.toString()));
    }
  }

  Future<void> getFoodDetails(String foodId) async {
    emit(FoodDetailsLoading());

    try {
      final uri = Uri.parse('$_baseUrl/foods/details')
          .replace(queryParameters: {'foodId': foodId});

      final response = await http.get(uri);
      dev.log('Details status: ${response.statusCode}');
      dev.log('Details response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        emit(FoodDetailsSuccess(foodDetails: decoded['food']));
      } else {
        emit(FoodSearchFailed(
            errorMessage: 'Error: ${response.statusCode} ${response.body}'));
      }
    } catch (e) {
      emit(FoodSearchFailed(errorMessage: e.toString()));
    }
  }
}