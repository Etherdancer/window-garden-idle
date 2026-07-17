import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'garden_notifier.dart'; // contains storageServiceProvider

class PlayerProfileNotifier extends StateNotifier<List<String>> {
  final StorageService _storageService;

  PlayerProfileNotifier(super.initialState, this._storageService);

  void pressPlant(String speciesId) {
    if (!state.contains(speciesId)) {
      final newState = [...state, speciesId];
      state = newState;
      _storageService.savePressedSpeciesIds(newState);
    }
  }

  bool hasPressed(String speciesId) {
    return state.contains(speciesId);
  }
}

final playerProfileProvider = StateNotifierProvider<PlayerProfileNotifier, List<String>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final initialIds = storageService.loadPressedSpeciesIds();
  return PlayerProfileNotifier(initialIds, storageService);
});
