// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_scan_group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodScanGroupAdapter extends TypeAdapter<FoodScanGroup> {
  @override
  final int typeId = 6;

  @override
  FoodScanGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodScanGroup(
      uuid: fields[0] as String,
      imagePath: fields[1] as String,
      timestamp: fields[2] as DateTime,
      foods: (fields[3] as List).cast<ValueFoodHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodScanGroup obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.foods);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodScanGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ValueFoodHiveAdapter extends TypeAdapter<ValueFoodHive> {
  @override
  final int typeId = 7;

  @override
  ValueFoodHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValueFoodHive(
      name: fields[0] as String?,
      calories: fields[1] as double?,
      protein: fields[2] as double?,
      fat: fields[3] as double?,
      carbs: fields[4] as double?,
      calcium: fields[5] as double?,
      cholesterol: fields[6] as double?,
      fiber: fields[7] as double?,
      iron: fields[8] as double?,
      potassium: fields[9] as double?,
      sodium: fields[10] as double?,
      sugar: fields[11] as double?,
      quantity: fields[12] as double?,
      unit: fields[13] as String?,
      servingDescription: fields[14] as String?,
      metricServingAmount: fields[15] as String?,
      metricServingUnit: fields[16] as String?,
      numberOfUnits: fields[17] as String?,
      measurementDescription: fields[18] as String?,
      saturatedFat: fields[19] as double?,
      polyunsaturatedFat: fields[20] as double?,
      monounsaturatedFat: fields[21] as double?,
      vitaminA: fields[22] as double?,
      vitaminC: fields[23] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ValueFoodHive obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.fat)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.calcium)
      ..writeByte(6)
      ..write(obj.cholesterol)
      ..writeByte(7)
      ..write(obj.fiber)
      ..writeByte(8)
      ..write(obj.iron)
      ..writeByte(9)
      ..write(obj.potassium)
      ..writeByte(10)
      ..write(obj.sodium)
      ..writeByte(11)
      ..write(obj.sugar)
      ..writeByte(12)
      ..write(obj.quantity)
      ..writeByte(13)
      ..write(obj.unit)
      ..writeByte(14)
      ..write(obj.servingDescription)
      ..writeByte(15)
      ..write(obj.metricServingAmount)
      ..writeByte(16)
      ..write(obj.metricServingUnit)
      ..writeByte(17)
      ..write(obj.numberOfUnits)
      ..writeByte(18)
      ..write(obj.measurementDescription)
      ..writeByte(19)
      ..write(obj.saturatedFat)
      ..writeByte(20)
      ..write(obj.polyunsaturatedFat)
      ..writeByte(21)
      ..write(obj.monounsaturatedFat)
      ..writeByte(22)
      ..write(obj.vitaminA)
      ..writeByte(23)
      ..write(obj.vitaminC);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueFoodHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
