// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FoodWithServingsModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodWithServingsModelAdapter extends TypeAdapter<FoodWithServingsModel> {
  @override
  final int typeId = 2;

  @override
  FoodWithServingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodWithServingsModel(
      food: fields[0] as Food?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodWithServingsModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.food);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodWithServingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodAdapter extends TypeAdapter<Food> {
  @override
  final int typeId = 3;

  @override
  Food read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Food(
      foodId: fields[0] as String?,
      foodName: fields[1] as String?,
      foodType: fields[2] as String?,
      foodUrl: fields[3] as String?,
      servings: fields[4] as Servings?,
    );
  }

  @override
  void write(BinaryWriter writer, Food obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.foodId)
      ..writeByte(1)
      ..write(obj.foodName)
      ..writeByte(2)
      ..write(obj.foodType)
      ..writeByte(3)
      ..write(obj.foodUrl)
      ..writeByte(4)
      ..write(obj.servings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServingsAdapter extends TypeAdapter<Servings> {
  @override
  final int typeId = 4;

  @override
  Servings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Servings(
      serving: (fields[0] as List?)?.cast<Serving>(),
    );
  }

  @override
  void write(BinaryWriter writer, Servings obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.serving);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServingAdapter extends TypeAdapter<Serving> {
  @override
  final int typeId = 5;

  @override
  Serving read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Serving(
      servingId: fields[0] as String?,
      servingDescription: fields[1] as String?,
      servingUrl: fields[2] as String?,
      metricServingAmount: fields[3] as String?,
      metricServingUnit: fields[4] as String?,
      numberOfUnits: fields[5] as String?,
      measurementDescription: fields[6] as String?,
      calories: fields[7] as String?,
      carbohydrate: fields[8] as String?,
      protein: fields[9] as String?,
      fat: fields[10] as String?,
      saturatedFat: fields[11] as String?,
      polyunsaturatedFat: fields[12] as String?,
      monounsaturatedFat: fields[13] as String?,
      cholesterol: fields[14] as String?,
      sodium: fields[15] as String?,
      potassium: fields[16] as String?,
      fiber: fields[17] as String?,
      sugar: fields[18] as String?,
      vitaminA: fields[19] as String?,
      vitaminC: fields[20] as String?,
      calcium: fields[21] as String?,
      iron: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Serving obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.servingId)
      ..writeByte(1)
      ..write(obj.servingDescription)
      ..writeByte(2)
      ..write(obj.servingUrl)
      ..writeByte(3)
      ..write(obj.metricServingAmount)
      ..writeByte(4)
      ..write(obj.metricServingUnit)
      ..writeByte(5)
      ..write(obj.numberOfUnits)
      ..writeByte(6)
      ..write(obj.measurementDescription)
      ..writeByte(7)
      ..write(obj.calories)
      ..writeByte(8)
      ..write(obj.carbohydrate)
      ..writeByte(9)
      ..write(obj.protein)
      ..writeByte(10)
      ..write(obj.fat)
      ..writeByte(11)
      ..write(obj.saturatedFat)
      ..writeByte(12)
      ..write(obj.polyunsaturatedFat)
      ..writeByte(13)
      ..write(obj.monounsaturatedFat)
      ..writeByte(14)
      ..write(obj.cholesterol)
      ..writeByte(15)
      ..write(obj.sodium)
      ..writeByte(16)
      ..write(obj.potassium)
      ..writeByte(17)
      ..write(obj.fiber)
      ..writeByte(18)
      ..write(obj.sugar)
      ..writeByte(19)
      ..write(obj.vitaminA)
      ..writeByte(20)
      ..write(obj.vitaminC)
      ..writeByte(21)
      ..write(obj.calcium)
      ..writeByte(22)
      ..write(obj.iron);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
