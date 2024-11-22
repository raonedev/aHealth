/// food :
/// {"food_id":35718,"food_name":"Apples","food_type":"Generic","food_url":"https://www.fatsecret.com/calories-nutrition/usda/apples",
/// "servings":{"serving":
/// [{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]}}

class FoodWithServingsModel {
  FoodWithServingsModel({Food? food}) {
    _food = food;
  }

  FoodWithServingsModel.fromJson(dynamic json) {
    _food = json['food'] != null ? Food.fromJson(json['food']) : null;
  }

  Food? _food;

  FoodWithServingsModel copyWith({Food? food}) => FoodWithServingsModel(food: food ?? _food,);

  Food? get food => _food;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_food != null) {
      map['food'] = _food?.toJson();
    }
    return map;
  }
}

/// food_id : 35718
/// food_name : "Apples"
/// food_type : "Generic"
/// food_url : "https://www.fatsecret.com/calories-nutrition/usda/apples"
/// servings : {"serving":[{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]}

class Food {
  Food({
    String? foodId,
    String? foodName,
    String? foodType,
    String? foodUrl,
    Servings? servings,
  }) {
    _foodId = foodId;
    _foodName = foodName;
    _foodType = foodType;
    _foodUrl = foodUrl;
    _servings = servings;
  }

  Food.fromJson(dynamic json) {
    _foodId = json['food_id'];
    _foodName = json['food_name'];
    _foodType = json['food_type'];
    _foodUrl = json['food_url'];
    _servings =
        json['servings'] != null ? Servings.fromJson(json['servings']) : null;
  }

  String? _foodId;
  String? _foodName;
  String? _foodType;
  String? _foodUrl;
  Servings? _servings;

  Food copyWith({
    String? foodId,
    String? foodName,
    String? foodType,
    String? foodUrl,
    Servings? servings,
  }) =>Food(
        foodId: foodId ?? _foodId,
        foodName: foodName ?? _foodName,
        foodType: foodType ?? _foodType,
        foodUrl: foodUrl ?? _foodUrl,
        servings: servings ?? _servings,
      );

  String? get foodId => _foodId;

  String? get foodName => _foodName;

  String? get foodType => _foodType;

  String? get foodUrl => _foodUrl;

  Servings? get servings => _servings;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['food_id'] = _foodId;
    map['food_name'] = _foodName;
    map['food_type'] = _foodType;
    map['food_url'] = _foodUrl;
    if (_servings != null) {
      map['servings'] = _servings?.toJson();
    }
    return map;
  }
}

/// serving : [{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]

class Servings {
  Servings({
    List<Serving>? serving,
  }) {
    _serving = serving;
  }

  Servings.fromJson(dynamic json) {
    if (json['serving'] != null) {
      _serving = [];
      json['serving'].forEach((v) {
        _serving?.add(Serving.fromJson(v));
      });
    }
  }

  List<Serving>? _serving;

  Servings copyWith({
    List<Serving>? serving,
  }) =>
      Servings(
        serving: serving ?? _serving,
      );

  List<Serving>? get serving => _serving;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_serving != null) {
      map['serving'] = _serving?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// serving_id : 32915
/// serving_description : "1 medium (2-3/4\" dia) (approx 3 per lb)"
/// serving_url : "https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000"
/// metric_serving_amount : 138.000
/// metric_serving_unit : "g"
/// number_of_units : 1.000
/// measurement_description : "medium (2-3/4\" dia) (approx 3 per lb)"
/// calories : 72
/// carbohydrate : 19.06
/// protein : 0.36
/// fat : 0.23
/// saturated_fat : 0.039
/// polyunsaturated_fat : 0.070
/// polyunsaturated_fat : 0.070
/// cholesterol : 0
/// sodium : 1
/// potassium : 148
/// fiber : 3.3
/// sugar : 14.34
/// vitamin_a : 4
/// vitamin_c : 6.3
/// calcium : 8
/// iron : 0.17

class Serving {
  Serving({
    String? servingId,
    String? servingDescription,
    String? servingUrl,
    String? metricServingAmount,
    String? metricServingUnit,
    String? numberOfUnits,
    String? measurementDescription,
    String? calories,
    String? carbohydrate,
    String? protein,
    String? fat,
    String? saturatedFat,
    String? polyunsaturatedFat,
    String? monounsaturatedFat,
    String? cholesterol,
    String? sodium,
    String? potassium,
    String? fiber,
    String? sugar,
    String? vitaminA,
    String? vitaminC,
    String? calcium,
    String? iron,
  }) {
    _servingId = servingId;
    _servingDescription = servingDescription;
    _servingUrl = servingUrl;
    _metricServingAmount = metricServingAmount;
    _metricServingUnit = metricServingUnit;
    _numberOfUnits = numberOfUnits;
    _measurementDescription = measurementDescription;
    _calories = calories;
    _carbohydrate = carbohydrate;
    _protein = protein;
    _fat = fat;
    _saturatedFat = saturatedFat;
    _polyunsaturatedFat = polyunsaturatedFat;
    _monounsaturatedFat = monounsaturatedFat;
    _cholesterol = cholesterol;
    _sodium = sodium;
    _potassium = potassium;
    _fiber = fiber;
    _sugar = sugar;
    _vitaminA = vitaminA;
    _vitaminC = vitaminC;
    _calcium = calcium;
    _iron = iron;
  }

  Serving.fromJson(dynamic json) {
    _servingId = json['serving_id'];
    _servingDescription = json['serving_description'];
    _servingUrl = json['serving_url'];
    _metricServingAmount = json['metric_serving_amount'];
    _metricServingUnit = json['metric_serving_unit'];
    _numberOfUnits = json['number_of_units'];
    _measurementDescription = json['measurement_description'];
    _calories = json['calories'];
    _carbohydrate = json['carbohydrate'];
    _protein = json['protein'];
    _fat = json['fat'];
    _saturatedFat = json['saturated_fat'];
    _polyunsaturatedFat = json['polyunsaturated_fat'];
    _monounsaturatedFat = json['monounsaturated_fat'];
    _cholesterol = json['cholesterol'];
    _sodium = json['sodium'];
    _potassium = json['potassium'];
    _fiber = json['fiber'];
    _sugar = json['sugar'];
    _vitaminA = json['vitamin_a'];
    _vitaminC = json['vitamin_c'];
    _calcium = json['calcium'];
    _iron = json['iron'];
  }

  String? _servingId;
  String? _servingDescription;
  String? _servingUrl;
  String? _metricServingAmount;
  String? _metricServingUnit;
  String? _numberOfUnits;
  String? _measurementDescription;
  String? _calories;
  String? _carbohydrate;
  String? _protein;
  String? _fat;
  String? _saturatedFat;
  String? _polyunsaturatedFat;
  String? _monounsaturatedFat;
  String? _cholesterol;
  String? _sodium;
  String? _potassium;
  String? _fiber;
  String? _sugar;
  String? _vitaminA;
  String? _vitaminC;
  String? _calcium;
  String? _iron;

  Serving copyWith({
    String? servingId,
    String? servingDescription,
    String? servingUrl,
    String? metricServingAmount,
    String? metricServingUnit,
    String? numberOfUnits,
    String? measurementDescription,
    String? calories,
    String? carbohydrate,
    String? protein,
    String? fat,
    String? saturatedFat,
    String? polyunsaturatedFat,
    String? monounsaturatedFat,
    String? cholesterol,
    String? sodium,
    String? potassium,
    String? fiber,
    String? sugar,
    String? vitaminA,
    String? vitaminC,
    String? calcium,
    String? iron,
  }) =>
      Serving(
        servingId: servingId ?? _servingId,
        servingDescription: servingDescription ?? _servingDescription,
        servingUrl: servingUrl ?? _servingUrl,
        metricServingAmount: metricServingAmount ?? _metricServingAmount,
        metricServingUnit: metricServingUnit ?? _metricServingUnit,
        numberOfUnits: numberOfUnits ?? _numberOfUnits,
        measurementDescription:
            measurementDescription ?? _measurementDescription,
        calories: calories ?? _calories,
        carbohydrate: carbohydrate ?? _carbohydrate,
        protein: protein ?? _protein,
        fat: fat ?? _fat,
        saturatedFat: saturatedFat ?? _saturatedFat,
        polyunsaturatedFat: polyunsaturatedFat ?? _polyunsaturatedFat,
        monounsaturatedFat: monounsaturatedFat ?? _monounsaturatedFat,
        cholesterol: cholesterol ?? _cholesterol,
        sodium: sodium ?? _sodium,
        potassium: potassium ?? _potassium,
        fiber: fiber ?? _fiber,
        sugar: sugar ?? _sugar,
        vitaminA: vitaminA ?? _vitaminA,
        vitaminC: vitaminC ?? _vitaminC,
        calcium: calcium ?? _calcium,
        iron: iron ?? _iron,
      );

  String? get servingId => _servingId;

  String? get servingDescription => _servingDescription;

  String? get servingUrl => _servingUrl;

  String? get metricServingAmount => _metricServingAmount;

  String? get metricServingUnit => _metricServingUnit;

  String? get numberOfUnits => _numberOfUnits;

  String? get measurementDescription => _measurementDescription;

  String? get calories => _calories;

  String? get carbohydrate => _carbohydrate;

  String? get protein => _protein;

  String? get fat => _fat;

  String? get saturatedFat => _saturatedFat;

  String? get polyunsaturatedFat => _polyunsaturatedFat;

  String? get monounsaturatedFat => _monounsaturatedFat;

  String? get cholesterol => _cholesterol;

  String? get sodium => _sodium;

  String? get potassium => _potassium;

  String? get fiber => _fiber;

  String? get sugar => _sugar;

  String? get vitaminA => _vitaminA;

  String? get vitaminC => _vitaminC;

  String? get calcium => _calcium;

  String? get iron => _iron;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['serving_id'] = _servingId;
    map['serving_description'] = _servingDescription;
    map['serving_url'] = _servingUrl;
    map['metric_serving_amount'] = _metricServingAmount;
    map['metric_serving_unit'] = _metricServingUnit;
    map['number_of_units'] = _numberOfUnits;
    map['measurement_description'] = _measurementDescription;
    map['calories'] = _calories;
    map['carbohydrate'] = _carbohydrate;
    map['protein'] = _protein;
    map['fat'] = _fat;
    map['saturated_fat'] = _saturatedFat;
    map['polyunsaturated_fat'] = _polyunsaturatedFat;
    map['monounsaturated_fat'] = _monounsaturatedFat;
    map['cholesterol'] = _cholesterol;
    map['sodium'] = _sodium;
    map['potassium'] = _potassium;
    map['fiber'] = _fiber;
    map['sugar'] = _sugar;
    map['vitamin_a'] = _vitaminA;
    map['vitamin_c'] = _vitaminC;
    map['calcium'] = _calcium;
    map['iron'] = _iron;
    return map;
  }
}
