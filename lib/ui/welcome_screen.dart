import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// garden_location.dart is created by the locations agent
import '../models/garden_location.dart';
import '../state/garden_notifier.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
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
  bool _isLoggingIn = false;

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

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoggingIn = true);
    final authService = ref.read(authServiceProvider);
    final userCredential = await authService.signInWithGoogle();
    if (userCredential != null) {
      final cloudSync = ref.read(cloudSyncServiceProvider);
      final gardens = await cloudSync.syncFromCloud();
      if (gardens != null && gardens.isNotEmpty) {
        await ref.read(gardenListProvider.notifier).loadFromCloud(gardens);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainGameScreen()),
        );
        return;
      }
    }
    setState(() => _isLoggingIn = false);
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
                      const SizedBox(height: 16),
                      if (_isLoggingIn)
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D7A68)),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _loginWithGoogle,
                          icon: const Icon(Icons.cloud_sync, size: 18),
                          label: const Text('Load Cloud Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8ECD7),
                            foregroundColor: const Color(0xFF324831),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
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
            Expanded(
              child: Image.asset(
                location.windowImagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
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
          ],
        ),
      ),
    );
  }
}
