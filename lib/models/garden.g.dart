// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GardenAdapter extends TypeAdapter<Garden> {
  @override
  final int typeId = 1;

  @override
  Garden read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Garden(
      id: fields[0] as String,
      locationId: fields[1] as String,
      plants: (fields[2] as List).cast<Plant>(),
      createdAt: fields[3] as DateTime,
      blindsLevel: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Garden obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locationId)
      ..writeByte(2)
      ..write(obj.plants)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.blindsLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
