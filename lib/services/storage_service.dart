import 'package:hive_flutter/hive_flutter.dart';
import '../models/plant.dart';
import '../models/garden.dart';

class StorageService {
  static const String _boxName = 'window_garden_save';
  static const String _gardensKey = 'user_gardens';
  static const String _activeGardenIdKey = 'active_garden_id';
  static const String _audioVolumeKey = 'audio_volume';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlantAdapter());
    Hive.registerAdapter(GardenAdapter());
    _box = await Hive.openBox(_boxName);
  }

  Future<void> saveGardens(List<Garden> gardens) async {
    await _box.put(_gardensKey, gardens);
  }

  List<Garden> loadGardens() {
    final rawList = _box.get(_gardensKey);
    if (rawList == null) return [];
    try {
      return List<Garden>.from(rawList);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActiveGardenId(String id) async {
    await _box.put(_activeGardenIdKey, id);
  }

  String? loadActiveGardenId() {
    return _box.get(_activeGardenIdKey) as String?;
  }

  double getAudioVolume() {
    return _box.get(_audioVolumeKey, defaultValue: 0.5) as double;
  }

  Future<void> saveAudioVolume(double volume) async {
    await _box.put(_audioVolumeKey, volume);
  }
}
