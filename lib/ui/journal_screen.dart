import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../models/product_ad.dart';
import '../state/plant_notifier.dart';
import 'widgets/native_ad_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category tab config
// ─────────────────────────────────────────────────────────────────────────────

const _kAllTab = 'all';

const _kJournalTabs = [
  _TabInfo(id: _kAllTab, label: 'All'),
  _TabInfo(id: 'Culinary Herbs', label: 'Herbs'),
  _TabInfo(id: 'Medicinal & Supplement Herbs', label: 'Medicinal'),
  _TabInfo(id: 'Superfoods & Adaptogens', label: 'Superfoods'),
  _TabInfo(id: 'Tea & Beverage Plants', label: 'Tea'),
  _TabInfo(id: 'Spice Plants', label: 'Spice'),
  _TabInfo(id: 'Edible Flowers & Garnish', label: 'Flowers'),
  _TabInfo(id: 'Windowsill Edibles', label: 'Veg'),
  _TabInfo(id: 'Traditional Medicine & Wellness', label: 'Traditional'),
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
          indicatorColor: const Color(0xFF5D7A68),
          indicatorWeight: 2.5,
          tabAlignment: TabAlignment.start,
          tabs: _kJournalTabs
              .map((t) => Tab(text: t.label))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _kJournalTabs.map((tab) {
          return _JournalTabView(
            categoryFilter: tab.id,
            speciesMaxStage: speciesMaxStage,
            buildInfoRow: _buildInfoRow,
          );
        }).toList(),
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
  final Widget Function(String label, String value) buildInfoRow;

  const _JournalTabView({
    required this.categoryFilter,
    required this.speciesMaxStage,
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
        final categoryName = _categoryDisplayName(s);

        // Stage Unlocks mapping to Growth Stages 1-5
        final bool isStage1Unlocked = maxStage >= 1;
        final bool isStage2Unlocked = maxStage >= 2;
        final bool isStage3Unlocked = maxStage >= 3;
        final bool isStage4Unlocked = maxStage >= 4;
        final bool isStage5Unlocked = maxStage >= 5;

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
                  isStage5Unlocked 
                      ? '100% Discovered' 
                      : isStage1Unlocked 
                          ? 'Growing... current record stage $maxStage'
                          : 'Plant to unlock taxonomy and biology data.',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 11,
                    color: Color(0xFF8A8279),
                  ),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        title: s.journalData.useTitle ?? 'Culinary & Practical Use',
                        isUnlocked: isStage4Unlocked,
                        lockedMessage: 'Grow this plant to Stage 4 to unlock practical uses and recipes.',
                        initiallyExpanded: false,
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.restaurant, color: Color(0xFF8A8279), size: 18),
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
