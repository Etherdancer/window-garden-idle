import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../models/garden.dart';

class StorageService {
  static const String _boxName = 'window_garden_save';
  static const String _gardensKey = 'user_gardens';
  static const String _activeGardenIdKey = 'active_garden_id';
  static const String _audioVolumeKey = 'audio_volume';

  Box? _box;
  final Map<String, dynamic> _fallbackMemory = {};

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(PlantAdapter());
      Hive.registerAdapter(GardenAdapter());
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Warning: Local storage is blocked by browser settings (e.g. Brave Shields). Using in-memory fallback. Save data will be lost on refresh.');
      _box = null;
    }
  }

  Future<void> saveGardens(List<Garden> gardens) async {
    if (_box != null) {
      await _box!.put(_gardensKey, gardens);
    } else {
      _fallbackMemory[_gardensKey] = gardens;
    }
  }

  List<Garden> loadGardens() {
    final rawList = _box != null ? _box!.get(_gardensKey) : _fallbackMemory[_gardensKey];
    if (rawList == null) return [];
    try {
      return List<Garden>.from(rawList);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActiveGardenId(String id) async {
    if (_box != null) {
      await _box!.put(_activeGardenIdKey, id);
    } else {
      _fallbackMemory[_activeGardenIdKey] = id;
    }
  }

  String? loadActiveGardenId() {
    return _box != null 
        ? _box!.get(_activeGardenIdKey) as String? 
        : _fallbackMemory[_activeGardenIdKey] as String?;
  }

  double getAudioVolume() {
    return _box != null 
        ? _box!.get(_audioVolumeKey, defaultValue: 0.5) as double 
        : _fallbackMemory[_audioVolumeKey] ?? 0.5;
  }

  Future<void> saveAudioVolume(double volume) async {
    if (_box != null) {
      await _box!.put(_audioVolumeKey, volume);
    } else {
      _fallbackMemory[_audioVolumeKey] = volume;
    }
  }

  bool getHasSeenTutorial() {
    return _box != null 
        ? _box!.get('has_seen_tutorial', defaultValue: false) as bool 
        : _fallbackMemory['has_seen_tutorial'] ?? false;
  }

  Future<void> saveHasSeenTutorial(bool value) async {
    if (_box != null) {
      await _box!.put('has_seen_tutorial', value);
    } else {
      _fallbackMemory['has_seen_tutorial'] = value;
    }
  }

  List<String> loadPressedSpeciesIds() {
    final rawList = _box != null ? _box!.get('pressed_species_ids') : _fallbackMemory['pressed_species_ids'];
    if (rawList == null) return [];
    try {
      return List<String>.from(rawList);
    } catch (_) {
      return [];
    }
  }

  Future<void> savePressedSpeciesIds(List<String> ids) async {
    if (_box != null) {
      await _box!.put('pressed_species_ids', ids);
    } else {
      _fallbackMemory['pressed_species_ids'] = ids;
    }
  }
}
