import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/garden.dart';
import '../models/garden_location.dart';
import '../models/buff.dart';
import '../models/species.dart';
import '../services/time_manager.dart';
import 'garden_notifier.dart';
import 'player_profile_notifier.dart';
import 'focus_timer_notifier.dart';

// ---------------------------------------------------------------------------
// Re-export infrastructure providers so existing import paths keep working
// ---------------------------------------------------------------------------
export 'garden_notifier.dart'
    show
        storageServiceProvider,
        notificationServiceProvider,
        gamePausedProvider,
        gardenListProvider,
        activeGardenProvider,
        activeGardenIdProvider,
        GardenNotifier;

// ---------------------------------------------------------------------------
// Derived read-only plant list for the active garden
// ---------------------------------------------------------------------------

final plantListProvider = StateNotifierProvider<PlantTickNotifier, List<Plant>>((ref) {
  return PlantTickNotifier(ref);
});

// ---------------------------------------------------------------------------
// PlantTickNotifier
// ---------------------------------------------------------------------------

class PlantTickNotifier extends StateNotifier<List<Plant>> {
  final Ref _ref;
  Timer? _gameLoopTimer;
  bool _caughtUpOffline = false;

  PlantTickNotifier(this._ref) : super(const []) {
    _catchUpAllGardensOffline();
    _seedFromActiveGarden();
    _startTicker();

    _ref.listen<Garden?>(activeGardenProvider, (previous, next) {
      if (next != null) {
        state = next.plants;
        // Schedule notifications if location, blinds or plants list changed
        final locationChanged = previous?.locationId != next.locationId;
        final blindsChanged = previous?.blindsLevel != next.blindsLevel;
        final plantsChanged = previous?.plants.length != next.plants.length;
        if (locationChanged || blindsChanged || plantsChanged) {
          for (final plant in next.plants) {
            _scheduleFutureNotifications(plant, next.location!, next.blindsLevel);
          }
        }
      } else {
        state = [];
      }
    });
  }

  Map<BuffType, double> _calculateActiveBuffs() {
    final pressedIds = _ref.read(playerProfileProvider);
    final focusState = _ref.read(focusTimerProvider);
    
    final Map<BuffType, double> activeBuffs = {};
    for (final id in pressedIds) {
      final species = PlantSpecies.getById(id);
      if (species != null) {
        final buff = species.pressedBuff;
        activeBuffs[buff.type] = (activeBuffs[buff.type] ?? 0.0) + buff.value;
      }
    }
    
    if (focusState.isActive) {
      activeBuffs[BuffType.growthSpeed] = (activeBuffs[BuffType.growthSpeed] ?? 0.0) + 0.50; // 50% faster growth!
    }
    
    return activeBuffs;
  }

  void _catchUpAllGardensOffline() {
    if (_caughtUpOffline) return;
    _caughtUpOffline = true;

    final allGardens = _ref.read(gardenListProvider);
    if (allGardens.isEmpty) return;

    final now = DateTime.now();
    bool changedAny = false;
    final List<Garden> updatedGardens = [];
    final activeBuffs = _calculateActiveBuffs();

    for (final garden in allGardens) {
      bool changedGarden = false;
      final List<Plant> updatedPlants = [];

      for (final plant in garden.plants) {
        final simResult = TimeManager.simulateProgress(
          plant: plant,
          targetTime: now,
          location: garden.location!,
          blindsLevel: garden.blindsLevel,
          isPaused: false,
          activeBuffs: activeBuffs,
        );

        final updatedPlant = simResult['plant'] as Plant;
        updatedPlants.add(updatedPlant);

        if (updatedPlant != plant) {
          changedGarden = true;
          changedAny = true;
        }
      }

      if (changedGarden) {
        updatedGardens.add(garden.copyWith(plants: updatedPlants));
      } else {
        updatedGardens.add(garden);
      }
    }

    if (changedAny) {
      _ref.read(gardenListProvider.notifier).updateAllGardens(updatedGardens);
    }
  }

  void _seedFromActiveGarden() {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden != null) {
      state = activeGarden.plants;
    }
  }

  void _startTicker() {
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 10), (_) => tick());
  }

  void tick() {
    final isPaused = _ref.read(gamePausedProvider);
    if (isPaused) return;

    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null || activeGarden.plants.isEmpty) return;

    final now = DateTime.now();
    bool changed = false;
    final List<Plant> updatedPlants = [];
    final notifications = _ref.read(notificationServiceProvider);
    final activeBuffs = _calculateActiveBuffs();

    for (final plant in activeGarden.plants) {
      final simResult = TimeManager.simulateProgress(
        plant: plant,
        targetTime: now,
        location: activeGarden.location!,
        blindsLevel: activeGarden.blindsLevel,
        isPaused: false,
        activeBuffs: activeBuffs,
      );

      final updatedPlant = simResult['plant'] as Plant;
      updatedPlants.add(updatedPlant);

      if (updatedPlant != plant) changed = true;

      final newFacts = simResult['newlyUnlockedFacts'] as List<String>? ?? [];
      for (final factId in newFacts) {
        notifications.showNotification(
          id: plant.id.hashCode + factId.hashCode,
          title: '📖 New Journal Page Unlocked!',
          body: '${updatedPlant.nickname} has grown! Read about it in your Botanist Journal.',
        );
      }

      if (updatedPlant.isHydrationPoor() && !plant.isHydrationPoor()) {
        notifications.showNotification(
          id: plant.id.hashCode,
          title: '💧 Care Alert: Poor Hydration',
          body: '${updatedPlant.nickname} is running low on water! Soil moisture is far from ideal.',
        );
      }
    }

    if (changed) {
      state = updatedPlants;
      _ref.read(gardenListProvider.notifier).updateGardenPlants(
        activeGarden.id,
        updatedPlants,
      );
    }
  }

  void _scheduleFutureNotifications(Plant plant, GardenLocation location, double blindsLevel) {
    final notifications = _ref.read(notificationServiceProvider);

    notifications.cancelNotificationsForPlant(plant.id.hashCode);

    final timeUntilDry = TimeManager.estimateTimeUntilDry(plant, location, blindsLevel);
    if (timeUntilDry != null) {
      notifications.scheduleDehydrationWarning(plant, timeUntilDry);
    }

    final timeUntilStage = TimeManager.estimateTimeUntilNextStage(plant, location, blindsLevel);
    if (timeUntilStage != null) {
      notifications.scheduleGrowthEvent(plant, timeUntilStage);
    }
  }

  Future<void> waterPlant(String plantId, {required double targetLevel}) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;

    final notifications = _ref.read(notificationServiceProvider);

    final updatedPlants = activeGarden.plants.map((plant) {
      if (plant.id != plantId) return plant;
      
      final species = plant.species;
      final newWater = targetLevel.clamp(0.0, 100.0);
      
      double newHealth = plant.health;
      
      // If they watered it to a level that is highly inefficient (e.g. overwatered), apply a slight immediate shock.
      if (species != null) {
        final ideal = species.idealMoisture;
        final delta = (newWater - ideal).abs();
        final efficiency = 1.0 - (delta / (species.moistureToleranceWindow * 2.0)).clamp(0.0, 1.0);
        
        if (efficiency < 0.3) {
          newHealth = (newHealth - 5.0).clamp(0.0, 100.0);
          notifications.showNotification(
            id: plant.id.hashCode + 99,
            title: '⚠️ Care Alert: Poor Hydration',
            body: "${plant.nickname}'s new moisture level is far from ideal. Watch its health carefully.",
          );
        }
      }

      return plant.copyWith(
        currentWaterLevel: newWater,
        health: newHealth,
        lastCalculatedTime: DateTime.now(),
      );
    }).toList();

    state = updatedPlants;
    await _ref.read(gardenListProvider.notifier).updateGardenPlants(
      activeGarden.id,
      updatedPlants,
    );

    // Reschedule notifications for the watered plant
    final wateredPlant = updatedPlants.firstWhere((p) => p.id == plantId);
    _scheduleFutureNotifications(wateredPlant, activeGarden.location!, activeGarden.blindsLevel);

    await _triggerHaptic();
  }

  Future<void> cleanDust(String plantId) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;

    final updatedPlants = activeGarden.plants.map((plant) {
      if (plant.id != plantId) return plant;
      return plant.copyWith(dustLevel: 0.0, lastCalculatedTime: DateTime.now());
    }).toList();

    state = updatedPlants;
    await _ref.read(gardenListProvider.notifier).updateGardenPlants(
      activeGarden.id,
      updatedPlants,
    );

    // Reschedule notifications for the cleaned plant
    final cleanedPlant = updatedPlants.firstWhere((p) => p.id == plantId);
    _scheduleFutureNotifications(cleanedPlant, activeGarden.location!, activeGarden.blindsLevel);

    await _triggerHaptic();
  }

  Future<void> updateBlindsLevel(double newBlinds) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;
    await _ref
        .read(gardenListProvider.notifier)
        .updateGardenBlindsLevel(activeGarden.id, newBlinds);

    // Reschedule notifications for all plants in the garden based on new blinds level
    for (final plant in activeGarden.plants) {
      _scheduleFutureNotifications(plant, activeGarden.location!, newBlinds);
    }

    tick();
  }

  Future<void> uprootPlant(String plantId) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;

    final updatedPlants = activeGarden.plants.where((p) => p.id != plantId).toList();

    state = updatedPlants;
    await _ref.read(gardenListProvider.notifier).updateGardenPlants(
      activeGarden.id,
      updatedPlants,
    );
  }

  void pauseSimulation() {
    _ref.read(gardenListProvider.notifier).pauseAllGardens();
    _gameLoopTimer?.cancel();
  }

  void resumeSimulation() {
    _ref.read(gardenListProvider.notifier).resumeAllGardens();
    _startTicker();
    tick();
  }

  Future<void> _triggerHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// windowsillLightProvider
// ---------------------------------------------------------------------------

final windowsillBlindsProvider = Provider<double>((ref) {
  final garden = ref.watch(activeGardenProvider);
  return garden?.blindsLevel ?? 0.0;
});
