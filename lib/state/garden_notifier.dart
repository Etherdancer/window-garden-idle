import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garden.dart';
import '../models/plant.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers
// ---------------------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

// ---------------------------------------------------------------------------
// Garden providers
// ---------------------------------------------------------------------------

final activeGardenIdProvider = StateProvider<String?>((ref) {
  return ref.read(storageServiceProvider).loadActiveGardenId();
});

final gardenListProvider = StateNotifierProvider<GardenNotifier, List<Garden>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return GardenNotifier(storage, ref);
});

final activeGardenProvider = Provider<Garden?>((ref) {
  final gardens = ref.watch(gardenListProvider);
  final activeId = ref.watch(activeGardenIdProvider);
  if (gardens.isEmpty) return null;
  if (activeId == null) return gardens.first;
  try {
    return gardens.firstWhere((g) => g.id == activeId);
  } catch (_) {
    return gardens.first;
  }
});

final gamePausedProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// GardenNotifier
// ---------------------------------------------------------------------------

class GardenNotifier extends StateNotifier<List<Garden>> {
  final StorageService _storage;
  final Ref _ref;

  GardenNotifier(this._storage, this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _storage.loadGardens();
  }

  // ---- Garden CRUD ---------------------------------------------------------

  Future<void> addGarden(String locationId) async {
    final id = 'garden_${DateTime.now().millisecondsSinceEpoch}';
    final newGarden = Garden(
      id: id,
      locationId: locationId,
      plants: const [],
      createdAt: DateTime.now(),
      lightLevel: 0.5,
    );
    state = [...state, newGarden];
    await _storage.saveGardens(state);
    setActiveGarden(id);
  }

  Future<void> removeGarden(String gardenId) async {
    state = state.where((g) => g.id != gardenId).toList();
    await _storage.saveGardens(state);
    if (state.isNotEmpty) {
      setActiveGarden(state.first.id);
    } else {
      _ref.read(activeGardenIdProvider.notifier).state = null;
      await _storage.saveActiveGardenId('');
    }
  }

  void setActiveGarden(String gardenId) {
    _ref.read(activeGardenIdProvider.notifier).state = gardenId;
    _storage.saveActiveGardenId(gardenId);
  }

  // ---- Plant mutations inside a garden -------------------------------------

  Future<void> addPlantToGarden(
    String gardenId,
    String speciesId,
    String nickname,
  ) async {
    state = state.map((garden) {
      if (garden.id != gardenId || garden.isFull) return garden;
      final newPlant = Plant(
        id: 'plant_${DateTime.now().millisecondsSinceEpoch}',
        speciesId: speciesId,
        nickname: nickname,
        lastCalculatedTime: DateTime.now(),
        currentWaterLevel: 50.0,
      );
      return garden.copyWith(plants: [...garden.plants, newPlant]);
    }).toList();
    await _storage.saveGardens(state);
  }

  Future<void> removePlantFromGarden(String gardenId, String plantId) async {
    state = state.map((garden) {
      if (garden.id != gardenId) return garden;
      return garden.copyWith(
        plants: garden.plants.where((p) => p.id != plantId).toList(),
      );
    }).toList();
    await _storage.saveGardens(state);
  }

  Future<void> updateGardenLightLevel(String gardenId, double lightLevel) async {
    state = state.map((g) {
      return g.id == gardenId ? g.copyWith(lightLevel: lightLevel.clamp(0.0, 1.0)) : g;
    }).toList();
    await _storage.saveGardens(state);
  }

  Future<void> updateGardenPlants(String gardenId, List<Plant> plants) async {
    state = state.map((g) {
      return g.id == gardenId ? g.copyWith(plants: plants) : g;
    }).toList();
    await _storage.saveGardens(state);
  }

  /// Override the full state (used for catch-up simulation in plant_notifier)
  Future<void> updateAllGardens(List<Garden> gardens) async {
    state = gardens;
    await _storage.saveGardens(state);
  }

  // ---- Monetisation pause/resume -------------------------------------------

  void pauseAllGardens() {
    _ref.read(gamePausedProvider.notifier).state = true;
  }

  void resumeAllGardens() {
    final now = DateTime.now();
    state = state.map((garden) {
      return garden.copyWith(
        plants: garden.plants
            .map((p) => p.copyWith(lastCalculatedTime: now))
            .toList(),
      );
    }).toList();
    _storage.saveGardens(state);
    _ref.read(gamePausedProvider.notifier).state = false;
  }
}
