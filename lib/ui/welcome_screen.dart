import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// garden_location.dart is created by the locations agent
import '../models/garden_location.dart';
// garden_notifier.dart is created by the state agent
import '../state/garden_notifier.dart';
import 'main_game_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectLocation(BuildContext context, GardenLocation location) async {
    await ref.read(gardenListProvider.notifier).addGarden(location.id);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locations = GardenLocation.registry;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where would you like your\nfirst garden?',
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2520),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a windowsill from around the world',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: Color(0xFF8A8279),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Grid of Location Cards ───────────────────────────────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return _LocationCard(
                        location: location,
                        onTap: () => _selectLocation(context, location),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location Card
// ─────────────────────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final GardenLocation location;
  final VoidCallback onTap;

  const _LocationCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            color: const Color(0xFFE4DCD3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent color top strip
            Container(
              height: 4,
              color: location.accentPrimary,
            ),

            // Window image
            SizedBox(
              height: 90,
              child: Image.asset(
                location.windowImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 90,
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
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
