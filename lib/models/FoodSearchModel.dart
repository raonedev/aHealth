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

class Foods {
  Foods({
    String? foodName,
    String? foodType,
    String? foodDescription,
    String? foodId,
    String? foodUrl,
  }) {
    _foodName = foodName;
    _foodType = foodType;
    _foodDescription = foodDescription;
    _foodId = foodId;
    _foodUrl = foodUrl;
  }

  Foods.fromJson(dynamic json) {
    _foodName = json['food_name'];
    _foodType = json['food_type'];
    _foodDescription = json['food_description'];
    _foodId = json['food_id'];
    _foodUrl = json['food_url'];
  }

  String? _foodName;
  String? _foodType;
  String? _foodDescription;
  String? _foodId;
  String? _foodUrl;

  Foods copyWith({
    String? foodName,
    String? foodType,
    String? foodDescription,
    String? foodId,
    String? foodUrl,
  }) =>
      Foods(
        foodName: foodName ?? _foodName,
        foodType: foodType ?? _foodType,
        foodDescription: foodDescription ?? _foodDescription,
        foodId: foodId ?? _foodId,
        foodUrl: foodUrl ?? _foodUrl,
      );

  String? get foodName => _foodName;

  String? get foodType => _foodType;

  String? get foodDescription => _foodDescription;

  String? get foodId => _foodId;

  String? get foodUrl => _foodUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['food_name'] = _foodName;
    map['food_type'] = _foodType;
    map['food_description'] = _foodDescription;
    map['food_id'] = _foodId;
    map['food_url'] = _foodUrl;
    return map;
  }
}
