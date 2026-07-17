import '../models/plant.dart';
import '../models/garden_location.dart';
import '../models/buff.dart';
import '../models/weather.dart';
import 'sunlight_service.dart';
import 'weather_service.dart';

class TimeManager {
  // Simulates plant updates over time.
  // Returns a new Plant state and list of newly unlocked fact IDs (if any).
  static Map<String, dynamic> simulateProgress({
    required Plant plant,
    required DateTime targetTime,
    required GardenLocation location,
    required double blindsLevel,
    bool isPaused = false,
    Map<BuffType, double> activeBuffs = const {},
  }) {
    if (isPaused) {
      return {
        'plant': plant.copyWith(lastCalculatedTime: targetTime),
        'newlyUnlockedFacts': <String>[],
      };
    }

    final DateTime lastTime = plant.lastCalculatedTime;
    if (targetTime.isBefore(lastTime)) {
      return {
        'plant': plant.copyWith(lastCalculatedTime: targetTime),
        'newlyUnlockedFacts': <String>[],
      };
    }

    final int secondsElapsed = targetTime.difference(lastTime).inSeconds;
    if (secondsElapsed <= 0) {
      return {
        'plant': plant,
        'newlyUnlockedFacts': <String>[],
      };
    }

    double hoursElapsed = secondsElapsed / 3600.0;

    // Cap the offline simulation to 72 hours
    if (hoursElapsed > 72.0) {
      hoursElapsed = 72.0;
    }

    final species = plant.species;
    if (species == null) {
      return {
        'plant': plant.copyWith(lastCalculatedTime: targetTime),
        'newlyUnlockedFacts': <String>[],
      };
    }

    double water = plant.currentWaterLevel;
    double health = plant.health;
    double dust = plant.dustLevel;
    double progress = plant.growthProgress;
    double photoEnergy = plant.photosynthesisEnergy;
    int stage = plant.growthStage;
    final List<String> newlyUnlockedFacts = [];
    final List<String> currentFacts = List.from(plant.unlockedFactIds);

    double remainingHours = hoursElapsed;
    while (remainingHours > 0) {
      final double dt = remainingHours > 1.0 ? 1.0 : remainingHours;
      final currentSimTime = targetTime.subtract(Duration(milliseconds: (remainingHours * 3600000).toInt()));
      remainingHours -= dt;

      // 1b. Determine weather for this simulation hour
      final weather = WeatherService.getWeatherForTime(currentSimTime);
      double weatherLightMultiplier = 1.0;
      double weatherMoistureMultiplier = 1.0;
      if (weather == WeatherState.cloudy) {
        weatherLightMultiplier = 0.4;
      } else if (weather == WeatherState.rainy) {
        weatherLightMultiplier = 0.1;
        weatherMoistureMultiplier = 0.5;
      }

      // 1. Calculate sunlight for this hour
      final maxSunlight = SunlightService.calculateSunlight(currentSimTime.toUtc(), location.latitude, location.longitude);
      final effectiveLight = maxSunlight * (1.0 - blindsLevel) * weatherLightMultiplier;

      // 2. Photosynthesis Mechanic (fills energy)
      final lightDeviation = (effectiveLight - species.idealLightLevel).abs();
      // Tolerance window of 0.4. Efficiency drops to 0 if deviation > 0.4
      final lightEfficiency = (1.0 - (lightDeviation / 0.4)).clamp(0.0, 1.0);
      
      // Dust blocks sunlight
      final dustFactor = 1.0 - (dust / 100.0).clamp(0.0, 1.0);
      
      // Apply Light Absorption Buff
      final lightBuff = 1.0 + (activeBuffs[BuffType.lightAbsorption] ?? 0.0);
      final fill = 10.0 * lightEfficiency * dustFactor * lightBuff * dt;
      final drain = 2.0 * dt;
      
      photoEnergy = (photoEnergy + fill - drain).clamp(0.0, 100.0);

      // 3. Dust accumulation (0.4% per hour)
      dust = (dust + 0.4 * dt).clamp(0.0, 100.0);

      // 4. Water depletion
      final double lightTranspirationFactor = 1.0 + (effectiveLight * 0.6);
      
      // Apply Moisture Retention Buff
      final waterBuff = 1.0 - (activeBuffs[BuffType.moistureRetention] ?? 0.0);
      
      final double depletion = species.waterDepletionRate * lightTranspirationFactor * dustFactor * waterBuff * weatherMoistureMultiplier * dt;
      water = (water - depletion).clamp(0.0, 100.0);

      // 5. Health logic
      final double idealMoisture = species.idealMoisture;
      final double moistureDelta = (water - idealMoisture).abs();
      final double moistureEfficiency = 1.0 - (moistureDelta / (species.moistureToleranceWindow * 2.0)).clamp(0.0, 1.0);
      
      bool idealConditions = true;

      // Apply Resilience Buff to all negative health decays
      final resilienceBuff = 1.0 - (activeBuffs[BuffType.resilience] ?? 0.0);

      if (moistureEfficiency < 0.7) {
        idealConditions = false;
        final double decayRate = (0.7 - moistureEfficiency) * 2.0 * resilienceBuff; 
        health = (health - decayRate * dt).clamp(0.0, 100.0);
      }
      
      if (dust > 40.0) {
        idealConditions = false;
        final double dustDecay = ((dust - 40.0) / 60.0) * 0.8 * resilienceBuff;
        health = (health - dustDecay * dt).clamp(0.0, 100.0);
      }

      // 5b. Photoinhibition (Sunburn)
      // If the actual light is more than 0.4 above ideal, the plant burns.
      if (effectiveLight > species.idealLightLevel + 0.4) {
        idealConditions = false;
        final double sunburnSeverity = (effectiveLight - (species.idealLightLevel + 0.4));
        final double sunburnDecay = sunburnSeverity * 3.0 * resilienceBuff; // ~0.5 to 1.5 health per hour
        health = (health - sunburnDecay * dt).clamp(0.0, 100.0);
      }

      // If photosynthesis bank is completely empty, plant starves
      if (photoEnergy <= 0.0) {
        idealConditions = false;
        health = (health - 0.5 * resilienceBuff * dt).clamp(0.0, 100.0);
      }

      // Health recovery
      if (idealConditions && health < 100.0) {
        health = (health + 1.2 * dt).clamp(0.0, 100.0);
      }

      // 6. Growth calculations
      if (health > 0.0 && photoEnergy > 0.0 && stage < 5) {
        const double baseGrowthPerHour = 4.16; 
        
        final double healthFactor = (health / 100.0);
        // Energy acts as a multiplier. Over 50 is full speed.
        final double energyFactor = (photoEnergy / 50.0).clamp(0.0, 1.0);

        // Apply Growth Speed Buff
        final growthBuff = 1.0 + (activeBuffs[BuffType.growthSpeed] ?? 0.0);

        final double growth = baseGrowthPerHour * 
                             species.growthRateMultiplier * 
                             healthFactor * 
                             energyFactor *
                             growthBuff *
                             dt;

        progress += growth;

        if (progress >= 100.0 && stage < 5) {
          stage += 1;
          progress = 0.0;
          
          if (stage >= 2) {
            final factPrefix = 'stage_$stage';
            if (!currentFacts.contains(factPrefix)) {
              currentFacts.add(factPrefix);
              newlyUnlockedFacts.add(factPrefix);
            }
          }
        }
      }
    }

    final updatedPlant = plant.copyWith(
      currentWaterLevel: water,
      health: health,
      dustLevel: dust,
      growthProgress: progress,
      growthStage: stage,
      photosynthesisEnergy: photoEnergy,
      unlockedFactIds: currentFacts,
      lastCalculatedTime: targetTime,
    );

    return {
      'plant': updatedPlant,
      'newlyUnlockedFacts': newlyUnlockedFacts,
    };
  }

  static Duration? estimateTimeUntilDry(Plant plant, GardenLocation location, double blindsLevel) {
    if (plant.species == null) return null;

    final species = plant.species!;
    final dustFactor = 1.0 - (plant.dustLevel / 100.0);
    final weather = WeatherService.getWeatherForTime(DateTime.now());
    double weatherLightMultiplier = 1.0;
    double weatherMoistureMultiplier = 1.0;
    if (weather == WeatherState.cloudy) {
      weatherLightMultiplier = 0.4;
    } else if (weather == WeatherState.rainy) {
      weatherLightMultiplier = 0.1;
      weatherMoistureMultiplier = 0.5;
    }
    // For estimation, assume average daylight (0.5 max sunlight)
    final effectiveLight = 0.5 * (1.0 - blindsLevel) * weatherLightMultiplier;
    final lightTranspirationFactor = 1.0 + (effectiveLight * 0.6);
    final depletionPerHour = species.waterDepletionRate * lightTranspirationFactor * dustFactor * weatherMoistureMultiplier;
    
    if (depletionPerHour <= 0) return null;
    
    final criticalThreshold = (species.idealMoisture - species.moistureToleranceWindow * 2.0).clamp(0.0, 100.0);
    if (plant.currentWaterLevel <= criticalThreshold) return null;
    
    final hours = (plant.currentWaterLevel - criticalThreshold) / depletionPerHour;
    return Duration(seconds: (hours * 3600).toInt());
  }

  static Duration? estimateTimeUntilNextStage(Plant plant, GardenLocation location, double blindsLevel) {
    if (plant.growthStage >= 5 || plant.health <= 0.0 || plant.species == null) return null;

    final species = plant.species!;
    const double baseGrowthPerHour = 4.16;
    final double healthFactor = (plant.health / 100.0);
    final double energyFactor = (plant.photosynthesisEnergy / 50.0).clamp(0.0, 1.0);

    final double growthPerHour = baseGrowthPerHour * 
                                 species.growthRateMultiplier * 
                                 healthFactor *
                                 energyFactor;
                                 
    if (growthPerHour <= 0) return null;

    final hours = (100.0 - plant.growthProgress) / growthPerHour;
    return Duration(seconds: (hours * 3600).toInt());
  }
}
