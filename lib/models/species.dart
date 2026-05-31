import '../data/species_culinary.dart';
import '../data/species_medicinal.dart';
import '../data/species_superfoods.dart';
import '../data/species_tea.dart';
import '../data/species_spice.dart';
import '../data/species_flowers.dart';
import '../data/species_edibles.dart';
import '../data/species_traditional.dart';

class PlantJournalData {
  final String description;
  final String botanicalDetails;
  final String curiosities;
  final String imageUrl;
  final String useTitle;
  final String useBody;

  const PlantJournalData({
    required this.description,
    required this.botanicalDetails,
    required this.curiosities,
    required this.imageUrl,
    required this.useTitle,
    required this.useBody,
  });
}

class PlantSpecies {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String category;
  final double waterNeed;
  final double lightNeed;
  final double growthRate;
  final PlantJournalData journalData;

  const PlantSpecies({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.category,
    required this.waterNeed,
    required this.lightNeed,
    required this.growthRate,
    required this.journalData,
  });

  String get commonName => name;
  String get nativeHabitat => "Various";
  double get idealLightLevel => lightNeed;
  double get waterDepletionRate => waterNeed;
  double get maxWaterTolerance => 90.0;
  double get idealHumidityLevel => 0.5;
  double get growthRateMultiplier => growthRate;

  static PlantSpecies? getById(String id) {
    try {
      return registry.firstWhere((species) => species.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<PlantSpecies> get registry => [
    ...culinaryPlants,
    ...medicinalPlants,
    ...superfoodPlants,
    ...teaPlants,
    ...spicePlants,
    ...flowerPlants,
    ...ediblePlants,
    ...traditionalPlants,
  ];
}
