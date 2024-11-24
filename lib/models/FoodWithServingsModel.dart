import 'package:hive/hive.dart';
part 'FoodWithServingsModel.g.dart';
/// food :
/// {"food_id":35718,"food_name":"Apples","food_type":"Generic","food_url":"https://www.fatsecret.com/calories-nutrition/usda/apples",
/// "servings":{"serving":
/// [{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]}}
@HiveType(typeId: 2)
class FoodWithServingsModel extends HiveObject{
  FoodWithServingsModel({this.food});

  @HiveField(0)
  Food? food;

  factory FoodWithServingsModel.fromJson(Map<String, dynamic> json) {
    return FoodWithServingsModel(
      food: json['food'] != null ? Food.fromJson(json['food']) : null,
    );
  }

  FoodWithServingsModel copyWith({Food? food}) => FoodWithServingsModel(food: food ?? this.food,);

  Map<String, dynamic> toJson() {
    return {
      'food': food?.toJson(),
    };
  }
}

/// food_id : 35718
/// food_name : "Apples"
/// food_type : "Generic"
/// food_url : "https://www.fatsecret.com/calories-nutrition/usda/apples"
/// servings : {"serving":[{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]}
@HiveType(typeId: 3)
class Food extends HiveObject{
  Food({
    this.foodId,
    this.foodName,
    this.foodType,
    this.foodUrl,
    this.servings,
  });


  @HiveField(0)
  String? foodId;
  @HiveField(1)
  String? foodName;
  @HiveField(2)
  String? foodType;
  @HiveField(3)
  String? foodUrl;
  @HiveField(4)
  Servings? servings;

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      foodId: json['food_id'],
      foodName: json['food_name'],
      foodType: json['food_type'],
      foodUrl: json['food_url'],
      servings:
      json['servings'] != null ? Servings.fromJson(json['servings']) : null,
    );
  }

  Food copyWith({
    String? foodId,
    String? foodName,
    String? foodType,
    String? foodUrl,
    Servings? servings,
  }) =>Food(
        foodId: foodId ?? this.foodId,
        foodName: foodName ?? this.foodName,
        foodType: foodType ?? this.foodType,
        foodUrl: foodUrl ?? this.foodUrl,
        servings: servings ?? this.servings,
      );

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'food_type': foodType,
      'food_url': foodUrl,
      'servings': servings?.toJson(),
    };
  }

}

/// serving : [{"serving_id":32915,"serving_description":"1 medium (2-3/4\" dia) (approx 3 per lb)","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=32915&portionamount=1.000","metric_serving_amount":138.000,"metric_serving_unit":"g","number_of_units":1.000,"measurement_description":"medium (2-3/4\" dia) (approx 3 per lb)","calories":72,"carbohydrate":19.06,"protein":0.36,"fat":0.23,"saturated_fat":0.039,"polyunsaturated_fat":0.070,"monounsaturated_fat":0.010,"cholesterol":0,"sodium":1,"potassium":148,"fiber":3.3,"sugar":14.34,"vitamin_a":4,"vitamin_c":6.3,"calcium":8,"iron":0.17},{"serving_id":58449,"serving_description":"100 g","serving_url":"https://www.fatsecret.com/calories-nutrition/usda/apples?portionid=58449&portionamount=100.000","metric_serving_amount":100.000,"metric_serving_unit":"g","number_of_units":100.000,"measurement_description":"g","calories":52,"carbohydrate":13.81,"protein":0.26,"fat":0.17,"saturated_fat":0.028,"polyunsaturated_fat":0.051,"monounsaturated_fat":0.007,"cholesterol":0,"sodium":1,"potassium":107,"fiber":2.4,"sugar":10.39,"vitamin_a":3,"vitamin_c":4.6,"calcium":6,"iron":0.12},null]
@HiveType(typeId: 4)
class Servings extends HiveObject{
  Servings({
    this.serving,
  });

  @HiveField(0)
  List<Serving>? serving;

  factory Servings.fromJson(Map<String, dynamic> json) {
    return Servings(
      serving: json['serving'] != null
          ? List<Serving>.from(
          json['serving']?.map((v) => v != null ? Serving.fromJson(v) : null)
          as Iterable)
          : null,
    );
  }

  Servings copyWith({
    List<Serving>? serving,
  }) => Servings(serving: serving ?? this.serving);

  Map<String, dynamic> toJson() {
    return {
      'serving': serving?.map((v) => v.toJson()).toList(),
    };
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
@HiveType(typeId: 5)
class Serving {
  Serving({
    this.servingId,
    this.servingDescription,
    this.servingUrl,
    this.metricServingAmount,
    this.metricServingUnit,
    this.numberOfUnits,
    this.measurementDescription,
    this.calories,
    this.carbohydrate,
    this.protein,
    this.fat,
    this.saturatedFat,
    this.polyunsaturatedFat,
    this.monounsaturatedFat,
    this.cholesterol,
    this.sodium,
    this.potassium,
    this.fiber,
    this.sugar,
    this.vitaminA,
    this.vitaminC,
    this.calcium,
    this.iron,
  });

  @HiveField(0)
  String? servingId;
  @HiveField(1)
  String? servingDescription;
  @HiveField(2)
  String? servingUrl;
  @HiveField(3)
  String? metricServingAmount;
  @HiveField(4)
  String? metricServingUnit;
  @HiveField(5)
  String? numberOfUnits;
  @HiveField(6)
  String? measurementDescription;
  @HiveField(7)
  String? calories;
  @HiveField(8)
  String? carbohydrate;
  @HiveField(9)
  String? protein;
  @HiveField(10)
  String? fat;
  @HiveField(11)
  String? saturatedFat;
  @HiveField(12)
  String? polyunsaturatedFat;
  @HiveField(13)
  String? monounsaturatedFat;
  @HiveField(14)
  String? cholesterol;
  @HiveField(15)
  String? sodium;
  @HiveField(16)
  String? potassium;
  @HiveField(17)
  String? fiber;
  @HiveField(18)
  String? sugar;
  @HiveField(19)
  String? vitaminA;
  @HiveField(20)
  String? vitaminC;
  @HiveField(21)
  String? calcium;
  @HiveField(22)
  String? iron;


  factory Serving.fromJson(Map<String, dynamic> json) {
    return Serving(
      servingId: json['serving_id'],
      servingDescription: json['serving_description'],
      servingUrl: json['serving_url'],
      metricServingAmount: json['metric_serving_amount'],
      metricServingUnit: json['metric_serving_unit'],
      numberOfUnits: json['number_of_units'],
      measurementDescription: json['measurement_description'],
      calories: json['calories'],
      carbohydrate: json['carbohydrate'],
      protein: json['protein'],
      fat: json['fat'],
      saturatedFat: json['saturated_fat'],
      polyunsaturatedFat: json['polyunsaturated_fat'],
      monounsaturatedFat: json['monounsaturated_fat'],
      cholesterol: json['cholesterol'],
      sodium: json['sodium'],
      potassium: json['potassium'],
      fiber: json['fiber'],
      sugar: json['sugar'],
      vitaminA: json['vitamin_a'],
      vitaminC: json['vitamin_c'],
      calcium: json['calcium'],
      iron: json['iron'],
    );
  }

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
        servingId: servingId ?? this.servingId,
        servingDescription: servingDescription ?? this.servingDescription,
        servingUrl: servingUrl ?? this.servingUrl,
        metricServingAmount: metricServingAmount ?? this.metricServingAmount,
        metricServingUnit: metricServingUnit ?? this.metricServingUnit,
        numberOfUnits: numberOfUnits ?? this.numberOfUnits,
        measurementDescription:
            measurementDescription ?? this.measurementDescription,
        calories: calories ?? this.calories,
        carbohydrate: carbohydrate ?? this.carbohydrate,
        protein: protein ?? this.protein,
        fat: fat ?? this.fat,
        saturatedFat: saturatedFat ?? this.saturatedFat,
        polyunsaturatedFat: polyunsaturatedFat ?? this.polyunsaturatedFat,
        monounsaturatedFat: monounsaturatedFat ?? this.monounsaturatedFat,
        cholesterol: cholesterol ?? this.cholesterol,
        sodium: sodium ?? this.sodium,
        potassium: potassium ?? this.potassium,
        fiber: fiber ?? this.fiber,
        sugar: sugar ?? this.sugar,
        vitaminA: vitaminA ?? this.vitaminA,
        vitaminC: vitaminC ?? this.vitaminC,
        calcium: calcium ?? this.calcium,
        iron: iron ?? this.iron,
      );


  Map<String, dynamic> toJson() {
    return {
      'serving_id': servingId,
      'serving_description': servingDescription,
      'serving_url': servingUrl,
      'metric_serving_amount': metricServingAmount,
      'metric_serving_unit': metricServingUnit,
      'number_of_units': numberOfUnits,
      'measurement_description': measurementDescription,
      'calories': calories,
      'carbohydrate': carbohydrate,
      'protein': protein,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'polyunsaturated_fat': polyunsaturatedFat,
      'monounsaturated_fat': monounsaturatedFat,
      'cholesterol': cholesterol,
      'sodium': sodium,
      'potassium': potassium,
      'fiber': fiber,
      'sugar': sugar,
      'vitamin_a': vitaminA,
      'vitamin_c': vitaminC,
      'calcium': calcium,
      'iron': iron,
    };
  }
}


