import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../models/product_ad.dart';
import '../state/plant_notifier.dart';
import '../state/player_profile_notifier.dart';
import '../models/buff.dart';
import 'widgets/native_ad_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category tab config
// ─────────────────────────────────────────────────────────────────────────────

const _kAllTab = 'all';

const _kJournalTabs = [
  _TabInfo(id: _kAllTab, label: 'All'),
  _TabInfo(id: 'The Tropical Canopy', label: 'Tropical'),
  _TabInfo(id: 'The Arid Survivors', label: 'Arid'),
  _TabInfo(id: 'The Balcony Bloomers', label: 'Bloomers'),
  _TabInfo(id: 'The Epiphytes', label: 'Epiphytes'),
  _TabInfo(id: 'The Shade Dwellers', label: 'Ferns'),
  _TabInfo(id: 'Micro-Farmers', label: 'Edibles'),
  _TabInfo(id: 'The Bog Hunters', label: 'Carnivorous'),
  _TabInfo(id: 'The Masters of Time', label: 'Bonsai'),
  _TabInfo(id: 'The Water Bowls', label: 'Aquatic'),
  _TabInfo(id: 'The Spring Sleepers', label: 'Bulbs'),
];

class _TabInfo {
  final String id;
  final String label;
  const _TabInfo({required this.id, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// JournalScreen
// ─────────────────────────────────────────────────────────────────────────────

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _kJournalTabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gather maximum growth stage achieved for each species from ALL gardens
    final Map<String, int> speciesMaxStage = {};
    try {
      final gardens = ref.watch(gardenListProvider);
      for (var garden in gardens) {
        for (var plant in garden.plants) {
          final currentMax = speciesMaxStage[plant.speciesId] ?? 0;
          if (plant.growthStage > currentMax) {
            speciesMaxStage[plant.speciesId] = plant.growthStage;
          }
        }
      }
    } catch (_) {}

    final pressedIds = ref.watch(playerProfileProvider);
    
    // Calculate global active buffs
    final Map<BuffType, double> activeBuffs = {};
    for (final id in pressedIds) {
      final s = PlantSpecies.getById(id);
      if (s != null) {
        final b = s.pressedBuff;
        activeBuffs[b.type] = (activeBuffs[b.type] ?? 0.0) + b.value;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5F0),
        elevation: 0,
        foregroundColor: const Color(0xFF2C2520),
        title: const Text(
          'Botanist Journal',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 13,
          ),
          labelColor: const Color(0xFF5D7A68),
          unselectedLabelColor: const Color(0xFF8A8279),
          indicatorColor: const Color(0xFF628B48),
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          tabs: _kJournalTabs
              .map((t) => Tab(text: t.label))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          // Active Buffs Summary Header
          if (activeBuffs.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFFE8ECD7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.stars, color: Color(0xFF628B48), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Global Active Buffs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E2D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: activeBuffs.entries.map((e) {
                      final buffType = e.key;
                      final totalValue = e.value;
                      // Determine short name manually or create a dummy PlantBuff
                      final dummy = PlantBuff(type: buffType, value: totalValue);
                      return Text(
                        '• ${dummy.shortName}: +${(totalValue * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF4A554A)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _kJournalTabs.map((tab) {
                return _JournalTabView(
                  categoryFilter: tab.id,
                  speciesMaxStage: speciesMaxStage,
                  pressedIds: pressedIds,
                  buildInfoRow: _buildInfoRow,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8A8279),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                color: Color(0xFF2C2520),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab view content
// ─────────────────────────────────────────────────────────────────────────────

class _JournalTabView extends StatelessWidget {
  final String categoryFilter;
  final Map<String, int> speciesMaxStage;
  final List<String> pressedIds;
  final Widget Function(String label, String value) buildInfoRow;

  const _JournalTabView({
    required this.categoryFilter,
    required this.speciesMaxStage,
    required this.pressedIds,
    required this.buildInfoRow,
  });

  List<PlantSpecies> get _filteredSpecies {
    if (categoryFilter == _kAllTab) {
      return PlantSpecies.registry;
    }
    return PlantSpecies.registry.where((s) {
      return s.category == categoryFilter;
    }).toList();
  }

  String _categoryDisplayName(PlantSpecies species) {
    return _capitalizeWords(species.category);
  }

  String _capitalizeWords(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final species = _filteredSpecies;

    if (species.isEmpty) {
      return const Center(
        child: Text(
          'No entries in this category yet.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: Color(0xFF8A8279),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: species.length,
      itemBuilder: (context, index) {
        final s = species[index];
        final maxStage = speciesMaxStage[s.id] ?? 0;
        final isPressed = pressedIds.contains(s.id);
        final categoryName = _categoryDisplayName(s);

        // Stage Unlocks mapping to Growth Stages 1-5
        final bool isStage1Unlocked = maxStage >= 1 || isPressed;
        final bool isStage2Unlocked = maxStage >= 2 || isPressed;
        final bool isStage3Unlocked = maxStage >= 3 || isPressed;
        final bool isStage4Unlocked = maxStage >= 4 || isPressed;
        final bool isStage5Unlocked = maxStage >= 5 || isPressed;

        final cardWidget = Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE4DCD3), width: 1.5),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              textColor: const Color(0xFF5D7A68),
              iconColor: const Color(0xFF5D7A68),
              title: Row(
                children: [
                  Icon(
                    isStage1Unlocked ? Icons.local_florist : Icons.spa,
                    color: const Color(0xFF5D7A68),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.commonName,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2520),
                          ),
                        ),
                        Text(
                          s.scientificName,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF8A8279),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 36, top: 4),
                child: Text(
                  isPressed
                      ? 'Fully Pressed - Buff Active'
                      : isStage5Unlocked 
                          ? '100% Discovered - Ready to Harvest' 
                          : isStage1Unlocked 
                              ? 'Growing... current record stage $maxStage'
                              : 'Plant to unlock taxonomy and biology data.',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                    color: isPressed ? const Color(0xFF628B48) : const Color(0xFF8A8279),
                    fontWeight: isPressed ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pressed Buff (if pressed)
                      if (isPressed)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8ECD7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: Color(0xFF628B48), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Provides: ${s.pressedBuff.description}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF324831),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      // Stage 0: Basic Description (Always Unlocked)
                      _buildCollapsibleStage(
                        context: context,
                        title: 'Basic Description',
                        isUnlocked: true,
                        lockedMessage: '',
                        initiallyExpanded: true,
                        content: Text(
                          s.journalData.description,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF4A423A),
                          ),
                        ),
                      ),
                      
                      // Stage 1: Taxonomy & Care
                      _buildCollapsibleStage(
                        context: context,
                        title: 'Taxonomy & Care',
                        isUnlocked: isStage1Unlocked,
                        lockedMessage: 'Plant this species in your garden to unlock Taxonomy & Care data.',
                        initiallyExpanded: false,
                        content: Column(
                          children: [
                            buildInfoRow('Family', s.family),
                            buildInfoRow('Native Habitat', s.nativeHabitat),
                            if (categoryName.isNotEmpty) buildInfoRow('Category', categoryName),
                            buildInfoRow('Ideal Humidity', '${(s.idealHumidityLevel * 100).toInt()}%'),
                          ],
                        ),
                      ),

                      // Stage 2: Botanical Image
                      _buildCollapsibleStage(
                        context: context,
                        title: 'Botanical Illustration',
                        isUnlocked: isStage2Unlocked,
                        lockedMessage: 'Grow this plant to Stage 2 to unlock its visual record.',
                        initiallyExpanded: false,
                        content: s.journalData.imageUrl != null && s.journalData.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  s.journalData.imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 100,
                                    color: const Color(0xFFE4DCD3),
                                    alignment: Alignment.center,
                                    child: const Text('Image unavailable', style: TextStyle(color: Color(0xFF8A8279))),
                                  ),
                                ),
                              )
                            : const Text('No image recorded for this species.'),
                      ),

                      // Stage 3: Botanical Details
                      _buildCollapsibleStage(
                        context: context,
                        title: 'Botanical Details',
                        isUnlocked: isStage3Unlocked,
                        lockedMessage: 'Grow this plant to Stage 3 to unlock Advanced Botanical Details.',
                        initiallyExpanded: false,
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology, color: Color(0xFF8A8279), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.journalData.botanicalDetails,
                                style: const TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF6E645A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stage 4: Uses and Recipes
                      _buildCollapsibleStage(
                        context: context,
                        title: s.journalData.useTitle ?? (s.category == 'Micro-Farmers' ? 'Culinary & Practical Use' : 'Specialized Display & Care'),
                        isUnlocked: isStage4Unlocked,
                        lockedMessage: s.category == 'Micro-Farmers' ? 'Grow this plant to Stage 4 to unlock practical uses and recipes.' : 'Grow this plant to Stage 4 to unlock specialized care techniques and display ideas.',
                        initiallyExpanded: false,
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(s.category == 'Micro-Farmers' ? Icons.restaurant : Icons.eco, color: const Color(0xFF8A8279), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.journalData.useBody ?? 'No uses recorded.',
                                style: const TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF6E645A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stage 5: Curiosities & Lore
                      _buildCollapsibleStage(
                        context: context,
                        title: 'Curiosities & Lore',
                        isUnlocked: isStage5Unlocked,
                        lockedMessage: 'Grow this plant to full maturity (Stage 5) to unlock rare Lore & Curiosities.',
                        initiallyExpanded: false,
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFFC7B35D), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.journalData.curiosities,
                                style: const TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF6E645A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        // Product Recommendations (only show if player has planted it)
        final recommendations = ProductAd.getRecommendationsFor(s.id);
        
        return Column(
          children: [
            cardWidget,
            if (isStage1Unlocked && recommendations.isNotEmpty)
              ...recommendations.map((ad) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NativeAdWidget(ad: ad),
              )),
          ],
        );
      },
    );
  }

  Widget _buildCollapsibleStage({
    required BuildContext context,
    required String title,
    required Widget content,
    required bool isUnlocked,
    required String lockedMessage,
    required bool initiallyExpanded,
  }) {
    if (!isUnlocked) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildLockedSection(lockedMessage),
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        iconColor: const Color(0xFF8A8279),
        collapsedIconColor: const Color(0xFF8A8279),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2520),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedSection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4DCD3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: const Color(0xFF8A8279).withValues(alpha: 0.5), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF8A8279).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
