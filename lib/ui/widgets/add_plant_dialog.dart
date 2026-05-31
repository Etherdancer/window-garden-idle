import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/species.dart';
import '../../models/plant.dart';
// garden_notifier.dart is created by the state agent
import '../../state/garden_notifier.dart';
import 'plant_visualizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category chip config
// ─────────────────────────────────────────────────────────────────────────────

const _kAllCategory = 'all';

const _kCategories = [
  _CategoryInfo(id: _kAllCategory, label: 'All', emoji: ''),
  _CategoryInfo(id: 'Culinary Herbs', label: 'Herbs', emoji: '🌿'),
  _CategoryInfo(id: 'Medicinal & Supplement Herbs', label: 'Medicinal', emoji: '💊'),
  _CategoryInfo(id: 'Superfoods & Adaptogens', label: 'Superfoods', emoji: '⚡'),
  _CategoryInfo(id: 'Tea & Beverage Plants', label: 'Tea', emoji: '🍵'),
  _CategoryInfo(id: 'Spice Plants', label: 'Spice', emoji: '🌶️'),
  _CategoryInfo(id: 'Edible Flowers & Garnish', label: 'Flowers', emoji: '🌸'),
  _CategoryInfo(id: 'Windowsill Edibles', label: 'Veg', emoji: '🥬'),
  _CategoryInfo(id: 'Traditional Medicine & Wellness', label: 'Traditional', emoji: '🧘'),
];

const _kCategoryColors = <String, Color>{
  'Culinary Herbs': Color(0xFF5D7A68),
  'Medicinal & Supplement Herbs': Color(0xFF7A5D7A),
  'Superfoods & Adaptogens': Color(0xFFD67C52),
  'Tea & Beverage Plants': Color(0xFF5D7A6E),
  'Spice Plants': Color(0xFFA65D5D),
  'Edible Flowers & Garnish': Color(0xFFA65D8A),
  'Windowsill Edibles': Color(0xFF6E8A5D),
  'Traditional Medicine & Wellness': Color(0xFF8A7A5D),
};

Color _colorForCategory(String category) =>
    _kCategoryColors[category] ?? const Color(0xFF5D7A68);

class _CategoryInfo {
  final String id;
  final String label;
  final String emoji;
  const _CategoryInfo({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AddPlantDialog
// ─────────────────────────────────────────────────────────────────────────────

class AddPlantDialog extends ConsumerStatefulWidget {
  final String gardenId;

  const AddPlantDialog({super.key, required this.gardenId});

  static void show(BuildContext context, String gardenId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPlantDialog(gardenId: gardenId),
    );
  }

  @override
  ConsumerState<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends ConsumerState<AddPlantDialog> {
  final _searchController = TextEditingController();
  String _selectedCategory = _kAllCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlantSpecies> get _filtered {
    return PlantSpecies.registry.where((s) {
      // Category filter
      final catMatch = _selectedCategory == _kAllCategory ||
          s.category == _selectedCategory;

      // Text filter
      final textMatch = _searchQuery.isEmpty ||
          s.commonName.toLowerCase().contains(_searchQuery) ||
          s.scientificName.toLowerCase().contains(_searchQuery);

      return catMatch && textMatch;
    }).toList();
  }

  Future<void> _onSpeciesTap(PlantSpecies species) async {
    HapticFeedback.lightImpact();
    final nicknameController =
        TextEditingController(text: species.commonName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5F0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Name your plant',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2520),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              species.commonName,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 13,
                color: Color(0xFF8A8279),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nicknameController,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF2C2520),
              ),
              decoration: InputDecoration(
                hintText: 'Nickname',
                hintStyle: const TextStyle(
                  fontFamily: 'OpenSans',
                  color: Color(0xFF8A8279),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFE4DCD3), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF5D7A68), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: Color(0xFF8A8279),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D7A68),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Plant',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final nickname = nicknameController.text.trim().isNotEmpty
          ? nicknameController.text.trim()
          : species.commonName;
      await ref
          .read(gardenListProvider.notifier)
          .addPlantToGarden(widget.gardenId, species.id, nickname);
      if (!mounted) return;
      Navigator.pop(context); // close the species picker sheet
    }
    nicknameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F5F0),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4DCD3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Title ─────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose a Plant',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2520),
                    ),
                  ),
                ),
              ),

              // ── Search ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 14,
                    color: Color(0xFF2C2520),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search plants...',
                    hintStyle: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 13,
                      color: Color(0xFF8A8279),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF8A8279),
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFE4DCD3), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF5D7A68), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFEFECE6),
                  ),
                ),
              ),

              // ── Category chips ────────────────────────────────────────
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  itemCount: _kCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _kCategories[index];
                    final isSelected = _selectedCategory == cat.id;
                    final chipColor = cat.id == _kAllCategory
                        ? const Color(0xFF5D7A68)
                        : _colorForCategory(cat.id);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategory = cat.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? chipColor
                                : chipColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: chipColor.withValues(
                                  alpha: isSelected ? 1.0 : 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            cat.emoji.isEmpty
                                ? cat.label
                                : '${cat.emoji} ${cat.label}',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : chipColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(color: Color(0xFFE4DCD3), height: 1),

              // ── Species list ──────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No plants found.',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            color: Color(0xFF8A8279),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final species = filtered[index];
                          return _SpeciesTile(
                            species: species,
                            onTap: () => _onSpeciesTap(species),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Species Tile
// ─────────────────────────────────────────────────────────────────────────────

class _SpeciesTile extends StatelessWidget {
  final PlantSpecies species;
  final VoidCallback onTap;

  const _SpeciesTile({required this.species, required this.onTap});

  String get _categoryLabel {
    return species.category;
  }

  Color get _categoryColor {
    return _colorForCategory(species.category);
  }

  String get _careHint {
    // Derive a one-line care hint from species data
    if (species.idealHumidityLevel > 0.7) {
      return 'Loves high humidity — mist regularly';
    } else if (species.waterDepletionRate < 1.0) {
      return 'Very drought-tolerant — water sparingly';
    } else if (species.idealLightLevel > 0.7) {
      return 'Thrives in bright, indirect light';
    } else if (species.idealLightLevel < 0.3) {
      return 'Great for low-light corners';
    } else {
      return 'Happy with moderate light and water';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dummyPlant = Plant(
      id: 'dummy',
      speciesId: species.id,
      nickname: '',
      lastCalculatedTime: DateTime.now(),
      growthStage: 5, // mature plant preview
      health: 100.0,
      currentWaterLevel: 50.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4DCD3), width: 1),
        ),
        child: Row(
          children: [
            // ── Mini Preview ──────────────────────────────────────────
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Transform.translate(
                  offset: const Offset(0, 10), // Push down to hide pot visually
                  child: PlantVisualizerWidget(
                    plant: dummyPlant,
                    size: 45,
                  ),
                ),
              ),
            ),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonName,
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2520),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    species.scientificName,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8A8279),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Category badge
                      if (_categoryLabel.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _categoryColor.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _categoryLabel,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _categoryColor,
                            ),
                          ),
                        ),
                      if (_categoryLabel.isNotEmpty)
                        const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _careHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 10,
                            color: Color(0xFF8A8279),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Arrow ─────────────────────────────────────────────────
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8A8279),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
