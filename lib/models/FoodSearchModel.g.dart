// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FoodSearchModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodsAdapter extends TypeAdapter<Foods> {
  @override
  final int typeId = 1;

  @override
  Foods read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Foods(
      foodName: fields[0] as String?,
      foodType: fields[1] as String?,
      foodDescription: fields[2] as String?,
      foodId: fields[3] as String?,
      foodUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Foods obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.foodName)
      ..writeByte(1)
      ..write(obj.foodType)
      ..writeByte(2)
      ..write(obj.foodDescription)
      ..writeByte(3)
      ..write(obj.foodId)
      ..writeByte(4)
      ..write(obj.foodUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
