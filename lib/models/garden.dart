import 'package:hive/hive.dart';
import 'plant.dart';
import 'garden_location.dart';

part 'garden.g.dart';

@HiveType(typeId: 1)
class Garden {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final List<Plant> plants; // max 4

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final double lightLevel; // per-garden light setting

  Garden({
    required this.id,
    required this.locationId,
    required this.plants,
    required this.createdAt,
    this.lightLevel = 0.5,
  });

  GardenLocation? get location => GardenLocation.getById(locationId);

  bool get isFull => plants.length >= 4;

  Garden copyWith({
    String? id,
    String? locationId,
    List<Plant>? plants,
    DateTime? createdAt,
    double? lightLevel,
  }) {
    return Garden(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      plants: plants ?? this.plants,
      createdAt: createdAt ?? this.createdAt,
      lightLevel: lightLevel ?? this.lightLevel,
    );
  }
}
