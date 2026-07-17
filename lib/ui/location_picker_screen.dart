import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// garden_location.dart is created by the locations agent
import '../models/garden_location.dart';
// garden_notifier.dart is created by the state agent
import '../state/garden_notifier.dart';

class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardens = ref.watch(gardenListProvider);
    final ownedLocationIds =
        gardens.map((g) => g.locationId).toSet();
    final locations = GardenLocation.registry;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE9),
        elevation: 0,
        foregroundColor: const Color(0xFF2C2520),
        title: const Text(
          'Add New Garden',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2520),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2C2520)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Choose your next windowsill',
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 13,
                  color: Color(0xFF8A8279),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  final isOwned =
                      ownedLocationIds.contains(location.id);
                    return _PickerLocationCard(
                      location: location,
                      isOwned: isOwned,
                      onTap: () {
                        _showLocationDetail(context, ref, location, isOwned);
                      },
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDetail(
      BuildContext context, WidgetRef ref, GardenLocation location, bool isOwned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F5F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image header
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(
                    image: AssetImage(location.windowImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '${location.emoji} ${location.name}',
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      location.tagline,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: Color(0xFF6E645A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isOwned ? Colors.grey : const Color(0xFF5D7A68),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isOwned
                          ? null
                          : () async {
                              await ref
                                  .read(gardenListProvider.notifier)
                                  .addGarden(location.id);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                      child: Text(
                        isOwned ? 'Garden Already Owned' : 'Create Garden Here',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
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
// Picker Location Card (with owned overlay badge)
// ─────────────────────────────────────────────────────────────────────────────

class _PickerLocationCard extends StatelessWidget {
  final GardenLocation location;
  final bool isOwned;
  final VoidCallback onTap;

  const _PickerLocationCard({
    required this.location,
    required this.isOwned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Base card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F0),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isOwned
                    ? const Color(0xFF5D7A68).withValues(alpha: 0.6)
                    : const Color(0xFFE4DCD3),
                width: isOwned ? 1.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent top strip
                Container(
                  height: 4,
                  color: location.accentPrimary,
                ),

                // Window image
                Expanded(
                  child: Image.asset(
                    location.windowImagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      color: location.accentPrimary.withValues(alpha: 0.28),
                      child: Center(
                        child: Text(
                          location.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  ),
                ),

                // Card body
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2520),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          location.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 10,
                            color: Color(0xFF8A8279),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Owned badge overlay
          if (isOwned)
            Positioned(
              top: 10,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D7A68),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
