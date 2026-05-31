import '../models/plant.dart';

class TimeManager {
  // Simulates plant updates over time.
  // Returns a new Plant state and list of newly unlocked fact IDs (if any).
  static Map<String, dynamic> simulateProgress({
    required Plant plant,
    required DateTime targetTime,
    required double currentLightLevel,
    bool isPaused = false,
  }) {
    if (isPaused) {
      // If paused (e.g., player is viewing an ad), update the calculation anchor without simulating growth/decay
      return {
        'plant': plant.copyWith(lastCalculatedTime: targetTime),
        'newlyUnlockedFacts': <String>[],
      };
    }

    final DateTime lastTime = plant.lastCalculatedTime;
    if (targetTime.isBefore(lastTime)) {
      // Prevent clock manipulation backward exploits
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

    // Convert to hours (as double) for simulation precision
    // For idle games, a tick rate where 1 hour of real time is simulated in double-hours is ideal.
    double hoursElapsed = secondsElapsed / 3600.0;

    // Cap the offline simulation to 72 hours to prevent total plant wane
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
    int stage = plant.growthStage;
    final List<String> newlyUnlockedFacts = [];
    final List<String> currentFacts = List.from(plant.unlockedFactIds);

    // Run simulation in 1-hour increments for accuracy
    double remainingHours = hoursElapsed;
    while (remainingHours > 0) {
      final double dt = remainingHours > 1.0 ? 1.0 : remainingHours;
      remainingHours -= dt;

      // 1. Dust accumulation (0.4% per hour)
      dust = (dust + 0.4 * dt).clamp(0.0, 100.0);

      // 2. Water depletion (affected by light level and dust cover)
      // High light increases transpiration; heavy dust slightly slows transpiration
      final double dustTranspirationFactor = 1.0 - (dust / 100.0) * 0.2;
      final double lightTranspirationFactor = 1.0 + (currentLightLevel * 0.6);
      final double depletion = species.waterDepletionRate * lightTranspirationFactor * dustTranspirationFactor * dt;
      water = (water - depletion).clamp(0.0, 100.0);

      // 3. Health logic
      bool idealConditions = true;

      // Overwatering check
      if (water > species.maxWaterTolerance) {
        idealConditions = false;
        // Root rot risk increases health damage. Max penalty ~1.5/hr
        final double severity = (water - species.maxWaterTolerance) / (100.0 - species.maxWaterTolerance);
        health = (health - (0.5 + severity * 1.0) * dt).clamp(0.0, 100.0);
      }
      // Underwatering check
      else if (water < 20.0) {
        idealConditions = false;
        final double drynessFactor = (20.0 - water) / 20.0; // 0 (mild) to 1 (bone dry)
        // Max penalty ~1.0/hr. Plant takes several days to die
        health = (health - (0.2 + drynessFactor * 0.8) * dt).clamp(0.0, 100.0);
      }

      // Dust health check
      if (dust > 60.0) {
        idealConditions = false;
        health = (health - 0.2 * dt).clamp(0.0, 100.0);
      }

      // Light level deviation check
      final double lightDeviation = (currentLightLevel - species.idealLightLevel).abs();
      if (lightDeviation > 0.3) {
        idealConditions = false;
        health = (health - 0.3 * dt).clamp(0.0, 100.0);
      }

      // Health recovery under ideal conditions
      if (idealConditions && health < 100.0) {
        health = (health + 1.0 * dt).clamp(0.0, 100.0);
      }

      // 4. Growth calculations (only grows if health is > 40)
      if (health > 40.0 && stage < 5) {
        // Base growth per hour (takes ~24 hours of ideal care to level up)
        const double baseGrowthPerHour = 4.16; 
        
        // Light efficiency (optimal at idealLightLevel)
        final double lightEfficiency = (1.0 - (lightDeviation * 1.5)).clamp(0.0, 1.0);
        
        // Dust penalty (dust blocks up to 60% of photosynthesis)
        final double dustPhotosynthesisFactor = 1.0 - (dust / 100.0) * 0.6;
        
        // Health penalty (low health slows growth)
        final double healthFactor = (health / 100.0);

        final double growth = baseGrowthPerHour * 
                             species.growthRateMultiplier * 
                             lightEfficiency * 
                             dustPhotosynthesisFactor * 
                             healthFactor * 
                             dt;

        progress += growth;

        // Handle Stage Levelling
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
      unlockedFactIds: currentFacts,
      lastCalculatedTime: targetTime,
    );

    return {
      'plant': updatedPlant,
      'newlyUnlockedFacts': newlyUnlockedFacts,
    };
  }

  static Duration? estimateTimeUntilDry(Plant plant, double currentLightLevel) {
    if (plant.currentWaterLevel <= 20.0 || plant.species == null) return null;

    final species = plant.species!;
    final dustTranspirationFactor = 1.0 - (plant.dustLevel / 100.0) * 0.2;
    final lightTranspirationFactor = 1.0 + (currentLightLevel * 0.6);
    final depletionPerHour = species.waterDepletionRate * lightTranspirationFactor * dustTranspirationFactor;
    
    if (depletionPerHour <= 0) return null;
    
    final hours = (plant.currentWaterLevel - 20.0) / depletionPerHour;
    return Duration(seconds: (hours * 3600).toInt());
  }

  static Duration? estimateTimeUntilNextStage(Plant plant, double currentLightLevel) {
    if (plant.growthStage >= 5 || plant.health <= 40.0 || plant.species == null) return null;

    final species = plant.species!;
    const double baseGrowthPerHour = 4.16;
    final double lightDeviation = (currentLightLevel - species.idealLightLevel).abs();
    final double lightEfficiency = (1.0 - (lightDeviation * 1.5)).clamp(0.0, 1.0);
    final double dustPhotosynthesisFactor = 1.0 - (plant.dustLevel / 100.0) * 0.6;
    final double healthFactor = (plant.health / 100.0);

    final double growthPerHour = baseGrowthPerHour * 
                                 species.growthRateMultiplier * 
                                 lightEfficiency * 
                                 dustPhotosynthesisFactor * 
                                 healthFactor;
                                 
    if (growthPerHour <= 0) return null;

    final hours = (100.0 - plant.growthProgress) / growthPerHour;
    return Duration(seconds: (hours * 3600).toInt());
  }
}
