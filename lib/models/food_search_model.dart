import 'package:hive/hive.dart';

part 'food_search_model.g.dart';

/// foods : [{"food_name":"Apples","food_type":"Generic","food_description":"Per 100g - Calories: 52kcal | Fat: 0.17g | Carbs: 13.81g | Protein: 0.26g","food_id":"35718","food_url":"https://www.fatsecret.com/calories-nutrition/usda/apples"},{"food_name":"Honeycrisp Apples","food_type":"Generic","food_description":"Per 100g - Calories: 52kcal | Fat: 0.17g | Carbs: 13.81g | Protein: 0.26g","food_id":"1902657","food_url":"https://www.fatsecret.com/calories-nutrition/generic/apples-honeycrisp"}]

class FoodSearchModel {
  FoodSearchModel({
    List<Foods>? foods,
  }) {
    _foods = foods;
  }

  FoodSearchModel.fromJson(dynamic json) {
    if (json['foods'] != null && json['foods']['food'] != null) {
      _foods = [];
      json['foods']['food'].forEach((v) {
        _foods?.add(Foods.fromJson(v));
      });
    }
  }

  List<Foods>? _foods;

  FoodSearchModel copyWith({
    List<Foods>? foods,
  }) =>
      FoodSearchModel(
        foods: foods ?? _foods,
      );

  List<Foods>? get foods => _foods;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_foods != null) {
      map['foods'] = _foods?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// food_name : "Apples"
/// food_type : "Generic"
/// food_description : "Per 100g - Calories: 52kcal | Fat: 0.17g | Carbs: 13.81g | Protein: 0.26g"
/// food_id : "35718"
/// food_url : "https://www.fatsecret.com/calories-nutrition/usda/apples"


@HiveType(typeId: 1) // Assign a unique typeId for the Foods class
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

  Foods({
    this.foodName,
    this.foodType,
    this.foodDescription,
    this.foodId,
    this.foodUrl,
  });

  Foods.fromJson(Map<String, dynamic> json) {
    foodName = json['food_name'];
    foodType = json['food_type'];
    foodDescription = json['food_description'];
    foodId = json['food_id'];
    foodUrl = json['food_url'];
  }

  Foods copyWith({
    String? foodName,
    String? foodType,
    String? foodDescription,
    String? foodId,
    String? foodUrl,
  }) {
    return Foods(
      foodName: foodName ?? this.foodName,
      foodType: foodType ?? this.foodType,
      foodDescription: foodDescription ?? this.foodDescription,
      foodId: foodId ?? this.foodId,
      foodUrl: foodUrl ?? this.foodUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_type': foodType,
      'food_description': foodDescription,
      'food_id': foodId,
      'food_url': foodUrl,
    };
  }
}
