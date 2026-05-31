import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// garden_location.dart is created by the locations agent
import '../../models/garden_location.dart';
// garden_notifier.dart is created by the state agent
import '../../state/garden_notifier.dart';
import '../location_picker_screen.dart';

class GardenSwitcherSheet extends ConsumerWidget {
  const GardenSwitcherSheet({super.key});

  /// Call this to open the sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GardenSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardens = ref.watch(gardenListProvider);
    final activeGardenId = ref.watch(activeGardenIdProvider);
    final gardenNotifier = ref.read(gardenListProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
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
              // ── Drag handle ───────────────────────────────────────────
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

              // ── Title row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Gardens',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2520),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8A8279),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // ── Garden list ───────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: gardens.length,
                  itemBuilder: (context, index) {
                    final garden = gardens[index];
                    final location =
                        GardenLocation.getById(garden.locationId);
                    final isActive = garden.id == activeGardenId;

                    if (location == null) return const SizedBox.shrink();

                    return _GardenTile(
                      garden: garden,
                      location: location,
                      isActive: isActive,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        gardenNotifier.setActiveGarden(garden.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              // ── Divider + Add New Garden button ───────────────────────
              const Divider(
                  color: Color(0xFFE4DCD3), height: 1, indent: 20, endIndent: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LocationPickerScreen()),
                      );
                    },
                    icon: const Text(
                      '＋',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5D7A68),
                      ),
                    ),
                    label: const Text(
                      'Add New Garden',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D7A68),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                          color: Color(0xFF5D7A68), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
// Individual Garden Tile
// ─────────────────────────────────────────────────────────────────────────────

class _GardenTile extends StatelessWidget {
  final dynamic garden; // Garden (from garden_notifier)
  final GardenLocation location;
  final bool isActive;
  final VoidCallback onTap;

  const _GardenTile({
    required this.garden,
    required this.location,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? location.accentPrimary.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? location.accentPrimary.withValues(alpha: 0.4)
                : const Color(0xFFE4DCD3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // ── Thumbnail ─────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  location.windowImagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: location.accentPrimary.withValues(alpha: 0.25),
                    child: Center(
                      child: Text(
                        location.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${location.emoji}  ${location.name}',
                    style: const TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2520),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${(garden.plants as List).length}/4 plants',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 11,
                      color: Color(0xFF8A8279),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active indicator ──────────────────────────────────────
            if (isActive)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D7A68),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
