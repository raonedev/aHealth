import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ahealth/models/food_search_model.dart';

import '../../config/appconstants.dart';
import '../../models/food_with_servings_model.dart';

part 'food_search_state.dart';

const String _baseUrl =
    'https://8ggapbx887.execute-api.ap-south-1.amazonaws.com';

class FoodSearchCubit extends Cubit<FoodSearchState> {
  FoodSearchCubit() : super(FoodSearchInitailize());

  int _activeSearchRequest = 0;

  void clearSearch() {
    _activeSearchRequest++;
    emit(FoodSearchInitailize());
  }

  Future<void> searchFood(String query, {int page = 0, int limit = 20}) async {
    final requestId = ++_activeSearchRequest;
    if (query.isEmpty) {
      emit(const FoodSearchFailed(errorMessage: "Please enter food"));
      return;
    }
    emit(FoodSearchLoading());

    try {
      final uri = Uri.parse('$_baseUrl/foods/search').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri);
      dev.log('Search status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = FoodSearchModel.fromJson(decoded);

        // Save each food with servings, same type as before
        final box = await Hive.openBox(foodDetailLocationHive);
        for (final f in model.foods ?? <Foods>[]) {
          if (f.foodId != null) {
            await box.put(
              f.foodId,
              FoodWithServingsModel(
                food: Food(
                  foodId: f.foodId,
                  foodName: f.foodName,
                  foodType: f.foodType,
                  foodUrl: f.foodUrl,
                  servings: f.servings,
                ),
              ),
            );
          }
        }

        if (requestId != _activeSearchRequest || isClosed) return;
        emit(FoodSearchSuccess(foodSearchModel: model));
      } else {
        if (requestId != _activeSearchRequest || isClosed) return;
        emit(const FoodSearchFailed(errorMessage: 'Something went wrong.'));
      }
    } on SocketException catch (error, stackTrace) {
      dev.log(
        'Food search network error',
        error: error,
        stackTrace: stackTrace,
      );
      if (requestId != _activeSearchRequest || isClosed) return;
      emit(const FoodSearchFailed.noInternet());
    } on http.ClientException catch (error, stackTrace) {
      dev.log(
        'Food search request failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (requestId != _activeSearchRequest || isClosed) return;
      emit(const FoodSearchFailed.noInternet());
    } on TimeoutException catch (error, stackTrace) {
      dev.log('Food search timed out', error: error, stackTrace: stackTrace);
      if (requestId != _activeSearchRequest || isClosed) return;
      emit(const FoodSearchFailed.noInternet());
    } catch (error, stackTrace) {
      dev.log(
        'Unexpected food search error',
        error: error,
        stackTrace: stackTrace,
      );
      if (requestId != _activeSearchRequest || isClosed) return;
      emit(const FoodSearchFailed(errorMessage: 'Something went wrong.'));
    }
  }
}
