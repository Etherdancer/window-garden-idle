import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/garden.dart';
import '../services/time_manager.dart';
import 'garden_notifier.dart';

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
      } else {
        state = [];
      }
    });
  }

  void _catchUpAllGardensOffline() {
    if (_caughtUpOffline) return;
    _caughtUpOffline = true;

    final allGardens = _ref.read(gardenListProvider);
    if (allGardens.isEmpty) return;

    final now = DateTime.now();
    bool changedAny = false;
    final List<Garden> updatedGardens = [];

    for (final garden in allGardens) {
      bool changedGarden = false;
      final List<Plant> updatedPlants = [];

      for (final plant in garden.plants) {
        final simResult = TimeManager.simulateProgress(
          plant: plant,
          targetTime: now,
          currentLightLevel: garden.lightLevel,
          isPaused: false,
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

    for (final plant in activeGarden.plants) {
      final simResult = TimeManager.simulateProgress(
        plant: plant,
        targetTime: now,
        currentLightLevel: activeGarden.lightLevel,
        isPaused: false,
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

      if (updatedPlant.isDry() && !plant.isDry()) {
        notifications.showNotification(
          id: plant.id.hashCode,
          title: '💧 Care Alert: Dry Soil',
          body: '${updatedPlant.nickname} is running low on water! Soil moisture is dry.',
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

  void _scheduleFutureNotifications(Plant plant, double lightLevel) {
    final notifications = _ref.read(notificationServiceProvider);
    notifications.cancelNotificationsForPlant(plant.id.hashCode);

    final timeUntilDry = TimeManager.estimateTimeUntilDry(plant, lightLevel);
    if (timeUntilDry != null) {
      notifications.scheduleDehydrationWarning(plant, timeUntilDry);
    }

    final timeUntilNextStage = TimeManager.estimateTimeUntilNextStage(plant, lightLevel);
    if (timeUntilNextStage != null) {
      notifications.scheduleGrowthEvent(plant, timeUntilNextStage);
    }
  }

  Future<void> waterPlant(String plantId) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;

    final notifications = _ref.read(notificationServiceProvider);

    final updatedPlants = activeGarden.plants.map((plant) {
      if (plant.id != plantId) return plant;
      final maxWater = plant.species?.maxWaterTolerance ?? 80.0;
      final newWater = (plant.currentWaterLevel + 35.0).clamp(0.0, 100.0);
      
      double newHealth = plant.health;
      if (newWater > maxWater) {
        // Immediate shock penalty for overwatering
        final excess = newWater - maxWater;
        newHealth = (newHealth - (excess * 0.5)).clamp(0.0, 100.0);

        notifications.showNotification(
          id: plant.id.hashCode + 99,
          title: '⚠️ Care Alert: Overwatered!',
          body: "${plant.nickname}'s soil is saturated. Excess water might lead to root rot.",
        );
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
    _scheduleFutureNotifications(wateredPlant, activeGarden.lightLevel);

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
    _scheduleFutureNotifications(cleanedPlant, activeGarden.lightLevel);

    await _triggerHaptic();
  }

  Future<void> updateLightLevel(double newLight) async {
    final activeGarden = _ref.read(activeGardenProvider);
    if (activeGarden == null) return;
    await _ref
        .read(gardenListProvider.notifier)
        .updateGardenLightLevel(activeGarden.id, newLight);

    // Reschedule notifications for all plants in the garden based on new light level
    for (final plant in activeGarden.plants) {
      _scheduleFutureNotifications(plant, newLight);
    }

    tick();
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

final windowsillLightProvider = Provider<double>((ref) {
  final garden = ref.watch(activeGardenProvider);
  return garden?.lightLevel ?? 0.5;
});
