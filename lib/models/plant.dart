import 'package:hive/hive.dart';
import 'species.dart';

part 'plant.g.dart';

@HiveType(typeId: 0)
class Plant {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String speciesId;
  
  @HiveField(2)
  final String nickname;
  
  @HiveField(3)
  final int growthStage;          // 1 to 5
  
  @HiveField(4)
  final double growthProgress;     // 0.0 to 100.0 (percentage to next stage)
  
  @HiveField(5)
  final double currentWaterLevel;  // 0.0 to 100.0
  
  @HiveField(6)
  final double health;             // 0.0 to 100.0
  
  @HiveField(7)
  final double dustLevel;          // 0.0 to 100.0 (blocks photosynthesis)
  
  @HiveField(8)
  final DateTime lastCalculatedTime;
  
  @HiveField(9)
  final List<String> unlockedFactIds;

  @HiveField(10)
  final double photosynthesisEnergy; // 0.0 to 100.0 (fills up with light, powers growth)

  Plant({
    required this.id,
    required this.speciesId,
    required this.nickname,
    this.growthStage = 1,
    this.growthProgress = 0.0,
    this.currentWaterLevel = 50.0,
    this.health = 100.0,
    this.dustLevel = 0.0,
    required this.lastCalculatedTime,
    this.unlockedFactIds = const [],
    this.photosynthesisEnergy = 100.0,
  });

  // Get species info
  PlantSpecies? get species => PlantSpecies.getById(speciesId);

  // Convenient checks
  double getMoistureEfficiency() {
    final ideal = species?.idealMoisture ?? 50.0;
    final delta = (currentWaterLevel - ideal).abs();
    final window = species?.moistureToleranceWindow ?? 25.0;
    // 100% efficient at ideal, 50% efficient at edge of window, 0% at double the window
    return (1.0 - (delta / (window * 2.0))).clamp(0.0, 1.0);
  }

  bool isHydrationPoor() => getMoistureEfficiency() < 0.5;
  bool isWithered() => health < 40.0;
  bool isDusty() => dustLevel > 40.0;

  Plant copyWith({
    String? id,
    String? speciesId,
    String? nickname,
    int? growthStage,
    double? growthProgress,
    double? currentWaterLevel,
    double? health,
    double? dustLevel,
    DateTime? lastCalculatedTime,
    List<String>? unlockedFactIds,
    double? photosynthesisEnergy,
  }) {
    return Plant(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      nickname: nickname ?? this.nickname,
      growthStage: growthStage ?? this.growthStage,
      growthProgress: growthProgress ?? this.growthProgress,
      currentWaterLevel: currentWaterLevel ?? this.currentWaterLevel,
      health: health ?? this.health,
      dustLevel: dustLevel ?? this.dustLevel,
      lastCalculatedTime: lastCalculatedTime ?? this.lastCalculatedTime,
      unlockedFactIds: unlockedFactIds ?? this.unlockedFactIds,
      photosynthesisEnergy: photosynthesisEnergy ?? this.photosynthesisEnergy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'speciesId': speciesId,
      'nickname': nickname,
      'growthStage': growthStage,
      'growthProgress': growthProgress,
      'currentWaterLevel': currentWaterLevel,
      'health': health,
      'dustLevel': dustLevel,
      'lastCalculatedTime': lastCalculatedTime.toIso8601String(),
      'unlockedFactIds': unlockedFactIds,
      'photosynthesisEnergy': photosynthesisEnergy,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] as String,
      speciesId: map['speciesId'] as String,
      nickname: map['nickname'] as String,
      growthStage: map['growthStage'] as int,
      growthProgress: (map['growthProgress'] as num).toDouble(),
      currentWaterLevel: (map['currentWaterLevel'] as num).toDouble(),
      health: (map['health'] as num).toDouble(),
      dustLevel: (map['dustLevel'] as num).toDouble(),
      lastCalculatedTime: DateTime.parse(map['lastCalculatedTime'] as String),
      unlockedFactIds: List<String>.from(map['unlockedFactIds'] ?? []),
      photosynthesisEnergy: (map['photosynthesisEnergy'] as num).toDouble(),
    );
  }
}
