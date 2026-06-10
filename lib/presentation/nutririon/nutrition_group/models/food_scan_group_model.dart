import 'package:hive/hive.dart';
import '../../../../models/nutrition_model.dart';

part 'food_scan_group_model.g.dart';

@HiveType(typeId: 6)
class FoodScanGroup extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  List<ValueFoodHive> foods;

  FoodScanGroup({
    required this.uuid,
    required this.imagePath,
    required this.timestamp,
    required this.foods,
  });
}

@HiveType(typeId: 7)
class ValueFoodHive extends HiveObject {
  @HiveField(0) String? name;
  @HiveField(1) double? calories;
  @HiveField(2) double? protein;
  @HiveField(3) double? fat;
  @HiveField(4) double? carbs;
  @HiveField(5) double? calcium;
  @HiveField(6) double? cholesterol;
  @HiveField(7) double? fiber;
  @HiveField(8) double? iron;
  @HiveField(9) double? potassium;
  @HiveField(10) double? sodium;
  @HiveField(11) double? sugar;
  @HiveField(12) double? quantity;
  @HiveField(13) String? unit;
  @HiveField(14) String? servingDescription;
  @HiveField(15) String? metricServingAmount;
  @HiveField(16) String? metricServingUnit;
  @HiveField(17) String? numberOfUnits;
  @HiveField(18) String? measurementDescription;
  @HiveField(19) double? saturatedFat;
  @HiveField(20) double? polyunsaturatedFat;
  @HiveField(21) double? monounsaturatedFat;
  @HiveField(22) double? vitaminA;
  @HiveField(23) double? vitaminC;

  ValueFoodHive({
    this.name, this.calories, this.protein, this.fat, this.carbs,
    this.calcium, this.cholesterol, this.fiber, this.iron, this.potassium,
    this.sodium, this.sugar, this.quantity, this.unit, this.servingDescription,
    this.metricServingAmount, this.metricServingUnit, this.numberOfUnits,
    this.measurementDescription, this.saturatedFat, this.polyunsaturatedFat,
    this.monounsaturatedFat, this.vitaminA, this.vitaminC,
  });

  factory ValueFoodHive.fromValueFood(ValueFood v) => ValueFoodHive(
    name: v.name, calories: v.calories, protein: v.protein, fat: v.fat,
    carbs: v.carbs, calcium: v.calcium, cholesterol: v.cholesterol,
    fiber: v.fiber, iron: v.iron, potassium: v.potassium, sodium: v.sodium,
    sugar: v.sugar, quantity: v.quantity, unit: v.unit,
    servingDescription: v.servingDescription,
    metricServingAmount: v.metricServingAmount,
    metricServingUnit: v.metricServingUnit, numberOfUnits: v.numberOfUnits,
    measurementDescription: v.measurementDescription,
    saturatedFat: v.saturatedFat, polyunsaturatedFat: v.polyunsaturatedFat,
    monounsaturatedFat: v.monounsaturatedFat, vitaminA: v.vitaminA,
    vitaminC: v.vitaminC,
  );

  ValueFood toValueFood() => ValueFood(
    name: name, calories: calories, protein: protein, fat: fat, carbs: carbs,
    calcium: calcium, cholesterol: cholesterol, fiber: fiber, iron: iron,
    potassium: potassium, sodium: sodium, sugar: sugar, quantity: quantity,
    unit: unit, servingDescription: servingDescription,
    metricServingAmount: metricServingAmount, metricServingUnit: metricServingUnit,
    numberOfUnits: numberOfUnits, measurementDescription: measurementDescription,
    saturatedFat: saturatedFat, polyunsaturatedFat: polyunsaturatedFat,
    monounsaturatedFat: monounsaturatedFat, vitaminA: vitaminA, vitaminC: vitaminC,
  );
}