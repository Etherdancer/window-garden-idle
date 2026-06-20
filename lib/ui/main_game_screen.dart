import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
// garden_location.dart is created by the locations agent
import '../models/garden_location.dart';
import '../models/species.dart';
import '../state/plant_notifier.dart';
import '../services/pwa_install.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'journal_screen.dart';
import 'welcome_screen.dart';
import 'widgets/plant_visualizer.dart';
import 'widgets/garden_switcher_sheet.dart';
import 'widgets/add_plant_dialog.dart';
import 'widgets/procedural_window.dart';

class MainGameScreen extends ConsumerStatefulWidget {
  const MainGameScreen({super.key});

  @override
  ConsumerState<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends ConsumerState<MainGameScreen> {
  String? _selectedPlantId;
  bool _checkedFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    // If no gardens exist on first build, redirect to WelcomeScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_checkedFirstLaunch) return;
      _checkedFirstLaunch = true;
      final gardens = ref.read(gardenListProvider);
      if (gardens.isEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gardens = ref.watch(gardenListProvider);
    final activeGarden = ref.watch(activeGardenProvider);
    final isPaused = ref.watch(gamePausedProvider);

    // Redirect to welcome if no gardens (handles state changes during session)
    if (gardens.isEmpty && !isPaused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      });
      return const Scaffold(
        backgroundColor: Color(0xFFF3EFE9),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF5D7A68)),
        ),
      );
    }

    final plants = activeGarden?.plants ?? <Plant>[];
    final lightLevel = activeGarden?.lightLevel ?? 0.5;

    // Resolve selected plant
    final selectedPlant = plants.isEmpty
        ? null
        : plants.firstWhere(
            (p) => p.id == _selectedPlantId,
            orElse: () => plants.first,
          );

    if (selectedPlant != null && _selectedPlantId == null) {
      _selectedPlantId = selectedPlant.id;
    }

    // Resolve active location
    final location = activeGarden != null
        ? GardenLocation.getById(activeGarden.locationId)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      body: SafeArea(
        child: isPaused
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF5D7A68)),
                    SizedBox(height: 16),
                    Text(
                      'Redirecting back to your garden...',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        color: Color(0xFF6E645A),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // 1. Header & Navigation to Journal
                  _buildHeader(context, location),

                  // 2. Windowsill and Sunlight rays
                  Expanded(
                    flex: 5,
                    child: _buildWindowsillView(
                      context,
                      activeGarden,
                      location,
                      plants,
                      selectedPlant,
                      lightLevel,
                    ),
                  ),

                  // 3. Control Panel
                  Expanded(
                    flex: 4,
                    child: _buildControlPanel(
                      context,
                      activeGarden,
                      location,
                      selectedPlant,
                      lightLevel,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, GardenLocation? location) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tapping the title opens the garden switcher
          Expanded(
            child: GestureDetector(
              onTap: () => GardenSwitcherSheet.show(context),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (location != null)
                            Text(
                              '${location.emoji}  ',
                              style: const TextStyle(fontSize: 18),
                            ),
                          Text(
                            location?.name ?? 'Window Garden',
                            style: const TextStyle(
                              fontFamily: 'PlayfairDisplay',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2520),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.expand_more_rounded,
                            size: 18,
                            color: Color(0xFF8A8279),
                          ),
                        ],
                      ),
                      Text(
                        location?.tagline ?? 'A Cozy Botanical Space',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 11,
                          color: Color(0xFF8A8279),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Install App Button
          if (isPwaInstallable() || (kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)))
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton.filled(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (isPwaInstallable()) {
                    promptPwaInstall();
                  } else {
                    // Show iOS install instructions
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Install Window Garden'),
                        content: const Text('To install this app on your device, tap the Share icon and select "Add to Home Screen".'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.install_mobile, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFD67C52),
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                tooltip: 'Install App',
              ),
            ),

          // Botanist Journal Button
          IconButton.filled(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JournalScreen()),
              );
            },
            icon: const Icon(Icons.menu_book, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF5D7A68),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            tooltip: 'Botanist Journal',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Windowsill View
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWindowsillView(
    BuildContext context,
    dynamic activeGarden,
    GardenLocation? location,
    List<Plant> plants,
    Plant? selectedPlant,
    double lightLevel,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Procedural window view
        if (location != null)
          Positioned.fill(
            child: ProceduralWindowWidget(
              location: location,
              lightLevel: lightLevel,
            ),
          ),

        // The Windowsill Shelf
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF8D7156),
              border: Border(
                top: BorderSide(color: Color(0xFF755C44), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -4),
                ),
              ],
            ),
          ),
        ),

        // Row of 4 plant slots
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                if (index < plants.length) {
                  // Actual plant
                  final plant = plants[index];
                  final isSelected = plant.id == selectedPlant?.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedPlantId = plant.id;
                      });
                    },
                    child: _buildPlantPot(plant, isSelected),
                  );
                } else {
                  // Empty slot
                  return _buildEmptySlot(context, activeGarden);
                }
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantPot(Plant plant, bool isSelected) {
    Color soilColor = const Color(0xFFC2B6A3);
    if (plant.currentWaterLevel > 50.0) {
      soilColor = const Color(0xFF5A4432);
    } else if (plant.currentWaterLevel > 20.0) {
      soilColor = const Color(0xFF8B715C);
    }

    final species = plant.species;
    final maxWater = species?.maxWaterTolerance ?? 80.0;
    final isOverwatered = plant.currentWaterLevel > maxWater;

    // Slightly smaller pots for 4-plant layout (base 90 was 100)
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PlantVisualizerWidget(
          plant: plant,
          size: 90.0 + (plant.growthStage * 7),
        ),
        Container(
          width: 68,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE88A60), // Light terracotta highlight
                Color(0xFFD67C52), // Base terracotta
                Color(0xFFA05532), // Dark shadow
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(2, 6),
              ),
              if (isSelected)
                const BoxShadow(
                  color: Color(0xFF5D7A68),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF5D7A68) : const Color(0xFFA05532),
              width: isSelected ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Pot Rim
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF09A72),
                      Color(0xFFD67C52),
                    ],
                  ),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFA05532), width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Soil Level
              Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: soilColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  // Inner shadow effect for the pot depth
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: isOverwatered
                    ? Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : null,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          plant.nickname,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 11,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? const Color(0xFF2C2520)
                : const Color(0xFF8A8279),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySlot(BuildContext context, dynamic activeGarden) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (activeGarden != null) {
          AddPlantDialog.show(context, activeGarden.id as String);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Empty visualizer space placeholder
          const SizedBox(height: 90),
          // Dashed-border empty pot
          Container(
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD67C52).withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color: const Color(0xFFD67C52).withValues(alpha: 0.5),
                width: 1.5,
                // Note: Flutter doesn't natively support dashed borders
                // Using lower-opacity border for the "empty" appearance
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Color(0xFFD67C52),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'empty',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 11,
              color: const Color(0xFFD67C52).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Control Panel
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildControlPanel(
    BuildContext context,
    dynamic activeGarden,
    GardenLocation? location,
    Plant? plant,
    double currentLightLevel,
  ) {
    if (plant == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your garden is empty',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                color: Color(0xFF2C2520),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap an empty pot to plant your first seed.',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 13,
                color: Color(0xFF8A8279),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final species = plant.species;
    final maxWater = species?.maxWaterTolerance ?? 80.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Plant header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.nickname,
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2520),
                    ),
                  ),
                  Text(
                    species?.scientificName ?? '',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8A8279),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECE6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Stage ${plant.growthStage}/5',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6E645A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status bars
          _buildStatusBar(
              'Health', plant.health / 100.0, const Color(0xFFD95D5D)),
          _buildMoistureBar(plant, species),

          _buildStatusBar(
            'Photosynthesis',
            1.0 - (plant.dustLevel / 100.0),
            const Color(0xFFC7B35D),
            warningText:
                plant.dustLevel > 40.0 ? 'Dusty' : null,
          ),

          const Spacer(),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(plantListProvider.notifier)
                      .waterPlant(plant.id);
                },
                child: _buildActionButton(
                  icon: Icons.water_drop,
                  label: 'Water Plant',
                  color: location?.accentPrimary ?? const Color(0xFF5D84A6),
                ),
              ),
              GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx.abs() > 5 ||
                      details.delta.dy.abs() > 5) {
                    ref
                        .read(plantListProvider.notifier)
                        .cleanDust(plant.id);
                  }
                },
                child: _buildActionButton(
                  icon: Icons.clean_hands,
                  label: 'Wipe Dust',
                  color: location?.accentSecondary ?? const Color(0xFF8A8279),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Light slider (per-garden)
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Light Level',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 13,
                  color: Color(0xFF6E645A),
                ),
              ),
              Expanded(
                child: Slider(
                  value: currentLightLevel,
                  activeColor: Colors.amber,
                  inactiveColor: const Color(0xFFE4DCD3),
                  onChanged: (val) {
                    if (activeGarden != null) {
                      ref
                          .read(gardenListProvider.notifier)
                          .updateGardenLightLevel(
                              activeGarden.id as String, val);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatusBar(String label, double val, Color color,
      {String? warningText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                    color: Color(0xFF8A8279)),
              ),
              Text(
                warningText ?? '${(val * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: warningText != null
                      ? const Color(0xFFD95D5D)
                      : const Color(0xFF6E645A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: val,
            color: color,
            backgroundColor: const Color(0xFFEFECE6),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildMoistureBar(Plant plant, PlantSpecies? species) {
    // Determine safe range based on the plant's unique water need
    final double idealMoisture = (species?.waterNeed ?? 0.6) * 100.0;
    // Don't be too strict: safe range is ±25% of the ideal moisture
    final double safeMin = (idealMoisture - 25.0).clamp(0.0, 100.0);
    final double safeMax = (idealMoisture + 25.0).clamp(0.0, 100.0);
    
    final val = plant.currentWaterLevel;
    final bool isSafe = val >= safeMin && val <= safeMax;
    
    String? warningText;
    if (val < safeMin) warningText = 'Too Dry';
    if (val > safeMax) warningText = 'Saturated';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Moisture',
                style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                    color: Color(0xFF8A8279)),
              ),
              Text(
                warningText ?? '${val.toInt()}% (Safe)',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSafe
                      ? const Color(0xFF5D7A68) // Green if safe
                      : const Color(0xFFD95D5D), // Red if not
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD95D5D).withValues(alpha: 0.2), // Red (Too dry)
                  const Color(0xFFD95D5D).withValues(alpha: 0.2),
                  const Color(0xFF5D7A68).withValues(alpha: 0.25), // Green (Safe)
                  const Color(0xFF5D7A68).withValues(alpha: 0.25),
                  const Color(0xFFD95D5D).withValues(alpha: 0.2), // Red (Too wet)
                  const Color(0xFFD95D5D).withValues(alpha: 0.2),
                ],
                stops: [
                  0.0,
                  safeMin / 100.0,
                  safeMin / 100.0,
                  safeMax / 100.0,
                  safeMax / 100.0,
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: val / 100.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSafe ? const Color(0xFF5D7A68) : const Color(0xFFD95D5D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
