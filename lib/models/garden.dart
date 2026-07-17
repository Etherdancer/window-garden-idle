import 'package:hive/hive.dart';
import 'plant.dart';
import 'garden_location.dart';
import 'weather.dart';
import '../services/weather_service.dart';

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
  final double blindsLevel; // 0.0 = fully open, 1.0 = fully closed

  Garden({
    required this.id,
    required this.locationId,
    required this.plants,
    required this.createdAt,
    this.blindsLevel = 0.0,
  });

  GardenLocation? get location => GardenLocation.getById(locationId);

  WeatherState get currentWeather => WeatherService.getWeatherForTime(DateTime.now());

  bool get isFull => plants.length >= 4;

  Garden copyWith({
    String? id,
    String? locationId,
    List<Plant>? plants,
    DateTime? createdAt,
    double? blindsLevel,
  }) {
    return Garden(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      plants: plants ?? this.plants,
      createdAt: createdAt ?? this.createdAt,
      blindsLevel: blindsLevel ?? this.blindsLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'locationId': locationId,
      'plants': plants.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'blindsLevel': blindsLevel,
    };
  }

  factory Garden.fromMap(Map<String, dynamic> map) {
    return Garden(
      id: map['id'] as String,
      locationId: map['locationId'] as String,
      plants: (map['plants'] as List<dynamic>).map((e) => Plant.fromMap(Map<String, dynamic>.from(e))).toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      blindsLevel: (map['blindsLevel'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
