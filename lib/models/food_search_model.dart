import 'package:hive/hive.dart';
import 'food_with_servings_model.dart';

part 'food_search_model.g.dart';

class FoodSearchModel {
  FoodSearchModel({List<Foods>? foods}) {
    _foods = foods;
  }

  FoodSearchModel.fromJson(dynamic json) {
    final list = json['foods_search']?['results']?['food'];
    if (list != null) {
      _foods = [];
      list.forEach((v) {
        _foods?.add(Foods.fromJson(v));
      });
    }
  }

  List<Foods>? _foods;

  FoodSearchModel copyWith({List<Foods>? foods}) =>
      FoodSearchModel(foods: foods ?? _foods);

  List<Foods>? get foods => _foods;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_foods != null) {
      map['foods'] = _foods?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

@HiveType(typeId: 1)
class Foods extends HiveObject {
  @HiveField(0)
  String? foodName;

  @HiveField(1)
  String? foodType;

  @HiveField(2)
  String? foodDescription;

  @HiveField(3)
  String? foodId;

  @HiveField(4)
  String? foodUrl;

  @HiveField(5)
  Servings? servings;

  Foods({
    this.foodName,
    this.foodType,
    this.foodDescription,
    this.foodId,
    this.foodUrl,
    this.servings,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    foodName = json['food_name'];
    foodType = json['food_type'];
    foodId = json['food_id'];
    foodUrl = json['food_url'];
    servings = json['servings'] != null
        ? Servings.fromJson(json['servings'])
        : null;

    // API no longer sends food_description. Build it from the first serving.
    final list = servings?.serving;
    final s = (list != null && list.isNotEmpty) ? list.first : null;
    foodDescription =
        json['food_description'] ??
        (s == null
            ? null
            : '${s.servingDescription} - Calories: ${s.calories}kcal | Fat: ${s.fat}g | Carbs: ${s.carbohydrate}g | Protein: ${s.protein}g');
  }

  Foods copyWith({
    String? foodName,
    String? foodType,
    String? foodDescription,
    String? foodId,
    String? foodUrl,
    Servings? servings,
  }) {
    return Foods(
      foodName: foodName ?? this.foodName,
      foodType: foodType ?? this.foodType,
      foodDescription: foodDescription ?? this.foodDescription,
      foodId: foodId ?? this.foodId,
      foodUrl: foodUrl ?? this.foodUrl,
      servings: servings ?? this.servings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_type': foodType,
      'food_description': foodDescription,
      'food_id': foodId,
      'food_url': foodUrl,
      'servings': servings?.toJson(),
    };
  }
}
