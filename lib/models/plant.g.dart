// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 0;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as String,
      speciesId: fields[1] as String,
      nickname: fields[2] as String,
      growthStage: fields[3] as int,
      growthProgress: fields[4] as double,
      currentWaterLevel: fields[5] as double,
      health: fields[6] as double,
      dustLevel: fields[7] as double,
      lastCalculatedTime: fields[8] as DateTime,
      unlockedFactIds: (fields[9] as List).cast<String>(),
      photosynthesisEnergy: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.speciesId)
      ..writeByte(2)
      ..write(obj.nickname)
      ..writeByte(3)
      ..write(obj.growthStage)
      ..writeByte(4)
      ..write(obj.growthProgress)
      ..writeByte(5)
      ..write(obj.currentWaterLevel)
      ..writeByte(6)
      ..write(obj.health)
      ..writeByte(7)
      ..write(obj.dustLevel)
      ..writeByte(8)
      ..write(obj.lastCalculatedTime)
      ..writeByte(9)
      ..write(obj.unlockedFactIds)
      ..writeByte(10)
      ..write(obj.photosynthesisEnergy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
