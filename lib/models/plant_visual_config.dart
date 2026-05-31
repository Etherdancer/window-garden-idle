import 'package:flutter/material.dart';
import 'species.dart';
import 'dart:math';

enum PlantGrowthHabit {
  upright,     // Like a small tree or sturdy single stem (e.g. Basil, Mint)
  bushy,       // Many branches from the base (e.g. Thyme, Rosemary)
  trailing,    // Hanging/vine-like (e.g. Pothos, some beans)
  rosette,     // Circular arrangement from center (e.g. Aloe, Echeveria)
  tallStems,   // Multiple tall individual stems (e.g. Snake Plant, Chives)
  creeping,    // Low to the ground, spreading (e.g. creeping thyme)
}

enum LeafShape {
  oval,        // Standard leaf (Basil)
  pointy,      // Sharp tip (Mint)
  heart,       // Heart-shaped (Pothos)
  needle,      // Pine-like (Rosemary)
  lobed,       // Oak/Maple like (Oak, Geranium)
  sword,       // Long and straight (Snake plant, Lemongrass)
  fleshy,      // Thick succulent leaf (Aloe, Jade)
  round,       // Circular (Nasturtium)
}

class PlantVisualConfig {
  final PlantGrowthHabit growthHabit;
  final LeafShape leafShape;
  final Color primaryColor;
  final Color secondaryColor;
  final Color stemColor;
  final int branchingFactor; // 1 to 10
  final double leafDensity;  // 0.5 to 2.0
  final double stemThickness; // 0.5 to 2.0
  final bool hasFlowers;
  final Color? flowerColor;
  final bool hasFruits;
  final Color? fruitColor;

  const PlantVisualConfig({
    required this.growthHabit,
    required this.leafShape,
    required this.primaryColor,
    required this.secondaryColor,
    required this.stemColor,
    this.branchingFactor = 5,
    this.leafDensity = 1.0,
    this.stemThickness = 1.0,
    this.hasFlowers = false,
    this.flowerColor,
    this.hasFruits = false,
    this.fruitColor,
  });

  // A factory to get a distinct config based on species ID and traits
  static PlantVisualConfig getConfigForSpecies(String speciesId) {
    final species = PlantSpecies.getById(speciesId);
    if (species == null) return _defaultConfig;

    final name = species.name.toLowerCase();
    final family = species.family.toLowerCase();
    final category = species.category.toLowerCase();
    
    // Deterministic random for slight variations even within generic fallbacks
    final rand = Random(speciesId.hashCode);

    // 1. Specific overrides for well-known distinct plants
    if (name.contains('basil')) {
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: name.contains('thai') ? LeafShape.pointy : LeafShape.oval,
        primaryColor: name.contains('purple') ? Colors.purple[800]! : const Color(0xFF388E3C),
        secondaryColor: const Color(0xFF4CAF50),
        stemColor: name.contains('thai') ? Colors.purple[700]! : const Color(0xFF66BB6A),
        branchingFactor: 4,
        leafDensity: 1.2,
        hasFlowers: true,
        flowerColor: Colors.white,
      );
    }
    if (name.contains('rosemary')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.bushy,
        leafShape: LeafShape.needle,
        primaryColor: Color(0xFF4C7B5D),
        secondaryColor: Color(0xFF5D8C6E),
        stemColor: Color(0xFF795548), // woody stem
        branchingFactor: 8,
        leafDensity: 1.5,
        stemThickness: 1.5,
      );
    }
    if (name.contains('thyme') || name.contains('oregano') || name.contains('marjoram')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.creeping,
        leafShape: LeafShape.round,
        primaryColor: Color(0xFF558B2F),
        secondaryColor: Color(0xFF689F38),
        stemColor: Color(0xFF8D6E63),
        branchingFactor: 10,
        leafDensity: 1.8,
        stemThickness: 0.8,
      );
    }
    if (name.contains('mint') || name.contains('peppermint') || name.contains('spearmint') || name.contains('balm')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: LeafShape.pointy,
        primaryColor: Color(0xFF2E7D32),
        secondaryColor: Color(0xFF43A047),
        stemColor: Color(0xFF4CAF50),
        branchingFactor: 6,
        leafDensity: 1.1,
      );
    }
    if (name.contains('chive') || name.contains('lemongrass') || name.contains('onion')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.tallStems,
        leafShape: LeafShape.sword,
        primaryColor: Color(0xFF4CAF50),
        secondaryColor: Color(0xFF81C784),
        stemColor: Color(0xFF4CAF50),
        branchingFactor: 1,
        leafDensity: 1.0,
      );
    }
    if (name.contains('aloe') || name.contains('succulent')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.rosette,
        leafShape: LeafShape.fleshy,
        primaryColor: Color(0xFF81C784),
        secondaryColor: Color(0xFFA5D6A7),
        stemColor: Colors.transparent,
        branchingFactor: 1,
        leafDensity: 1.5,
      );
    }
    if (name.contains('jade')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: LeafShape.round,
        primaryColor: Color(0xFF2E7D32),
        secondaryColor: Color(0xFF4CAF50),
        stemColor: Color(0xFF5D4037),
        branchingFactor: 5,
        leafDensity: 1.2,
        stemThickness: 2.0, // thick trunk
      );
    }
    if (name.contains('snake plant') || name.contains('sansevieria')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.tallStems,
        leafShape: LeafShape.sword,
        primaryColor: Color(0xFF1B5E20),
        secondaryColor: Color(0xFFC8E6C9), // variegated edges
        stemColor: Colors.transparent,
        branchingFactor: 1,
        leafDensity: 0.8,
      );
    }
    if (name.contains('spider plant')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.rosette,
        leafShape: LeafShape.sword,
        primaryColor: Color(0xFF4CAF50),
        secondaryColor: Colors.white, // striped
        stemColor: Colors.transparent,
        branchingFactor: 1,
        leafDensity: 2.0,
      );
    }
    if (name.contains('pothos') || name.contains('ivy') || name.contains('vine') || name.contains('monstera') || category.contains('vine')) {
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.trailing,
        leafShape: name.contains('monstera') ? LeafShape.lobed : LeafShape.heart,
        primaryColor: const Color(0xFF1B5E20),
        secondaryColor: const Color(0xFF81C784), // marble effect
        stemColor: const Color(0xFF66BB6A),
        branchingFactor: 3,
        leafDensity: 0.8,
      );
    }
    if (name.contains('fern') || name.contains('asparagus')) {
      return const PlantVisualConfig(
        growthHabit: PlantGrowthHabit.bushy,
        leafShape: LeafShape.needle,
        primaryColor: Color(0xFF43A047),
        secondaryColor: Color(0xFF66BB6A),
        stemColor: Color(0xFF388E3C),
        branchingFactor: 10,
        leafDensity: 2.0,
        stemThickness: 0.5,
      );
    }
    if (category.contains('edible flowers') || category.contains('flower') || name.contains('rose') || name.contains('chamomile') || name.contains('lavender')) {
      Color fColor = Colors.pink;
      if (name.contains('chamomile')) fColor = Colors.white;
      if (name.contains('lavender')) fColor = Colors.deepPurple;
      if (name.contains('sunflower')) fColor = Colors.yellow;
      if (name.contains('butterfly pea')) fColor = Colors.blue;
      if (name.contains('hibiscus')) fColor = Colors.red;

      return PlantVisualConfig(
        growthHabit: name.contains('lavender') ? PlantGrowthHabit.bushy : PlantGrowthHabit.upright,
        leafShape: name.contains('lavender') ? LeafShape.needle : LeafShape.lobed,
        primaryColor: const Color(0xFF4CAF50),
        secondaryColor: const Color(0xFF66BB6A),
        stemColor: const Color(0xFF388E3C),
        branchingFactor: 4,
        leafDensity: 1.0,
        hasFlowers: true,
        flowerColor: fColor,
      );
    }
    if (category.contains('windowsill edibles') || name.contains('tomato') || name.contains('pepper') || name.contains('chili')) {
      Color frColor = Colors.red;
      if (name.contains('lemon') || name.contains('lime')) frColor = name.contains('lemon') ? Colors.yellow : Colors.greenAccent;
      if (name.contains('habanero')) frColor = Colors.orange;

      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: name.contains('tomato') ? LeafShape.lobed : LeafShape.pointy,
        primaryColor: const Color(0xFF388E3C),
        secondaryColor: const Color(0xFF4CAF50),
        stemColor: const Color(0xFF4CAF50),
        branchingFactor: 5,
        leafDensity: 1.2,
        stemThickness: 1.5,
        hasFruits: true,
        fruitColor: frColor,
      );
    }

    // 2. Family-based heuristics
    if (family == 'lamiaceae') {
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: LeafShape.pointy,
        primaryColor: _randColor(rand, 0xFF388E3C),
        secondaryColor: _randColor(rand, 0xFF4CAF50),
        stemColor: const Color(0xFF4CAF50),
        branchingFactor: 5,
        leafDensity: 1.1,
      );
    }
    if (family == 'apiaceae') { // Parsley, Cilantro, Dill, Fennel
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.bushy,
        leafShape: name.contains('dill') || name.contains('fennel') ? LeafShape.needle : LeafShape.lobed,
        primaryColor: _randColor(rand, 0xFF43A047),
        secondaryColor: _randColor(rand, 0xFF66BB6A),
        stemColor: const Color(0xFF66BB6A),
        branchingFactor: 7,
        leafDensity: 1.5,
        stemThickness: 0.8,
      );
    }
    if (family == 'asteraceae') { // Chamomile, Echinacea, Dandelion
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: LeafShape.lobed,
        primaryColor: _randColor(rand, 0xFF4CAF50),
        secondaryColor: _randColor(rand, 0xFF81C784),
        stemColor: const Color(0xFF4CAF50),
        branchingFactor: 3,
        leafDensity: 0.9,
        hasFlowers: true,
        flowerColor: Colors.yellow[300], // default asteraceae flower
      );
    }

    // 3. Fallback generic configurations by category
    if (category == 'culinary herbs') {
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.bushy,
        leafShape: LeafShape.oval,
        primaryColor: _randColor(rand, 0xFF4CAF50),
        secondaryColor: _randColor(rand, 0xFF81C784),
        stemColor: const Color(0xFF66BB6A),
      );
    } else if (category == 'spice plants') {
      return PlantVisualConfig(
        growthHabit: PlantGrowthHabit.upright,
        leafShape: LeafShape.pointy,
        primaryColor: _randColor(rand, 0xFF2E7D32),
        secondaryColor: _randColor(rand, 0xFF4CAF50),
        stemColor: const Color(0xFF5D4037),
        stemThickness: 1.2,
      );
    }

    // Ultimate fallback
    return _defaultConfig;
  }

  static const _defaultConfig = PlantVisualConfig(
    growthHabit: PlantGrowthHabit.upright,
    leafShape: LeafShape.oval,
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF81C784),
    stemColor: Color(0xFF388E3C),
  );

  static Color _randColor(Random rand, int baseHex) {
    // Slighly vary the color for distinctness
    final baseColor = Color(baseHex);
    final hsl = HSLColor.fromColor(baseColor);
    final newHsl = hsl.withHue((hsl.hue + (rand.nextDouble() * 20 - 10)).clamp(0.0, 360.0))
                      .withLightness((hsl.lightness + (rand.nextDouble() * 0.1 - 0.05)).clamp(0.0, 1.0));
    return newHsl.toColor();
  }
}
