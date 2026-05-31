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
  });

  // Get species info
  PlantSpecies? get species => PlantSpecies.getById(speciesId);

  // Convenient checks
  bool isOverwatered(double maxTolerance) => currentWaterLevel > maxTolerance;
  bool isSeverelyOverwatered(double maxTolerance) => currentWaterLevel > (maxTolerance + 10.0);
  bool isDry() => currentWaterLevel < 20.0;
  bool isWithered() => health < 40.0;

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
    );
  }
}
