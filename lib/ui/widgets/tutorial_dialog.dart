import 'package:flutter/material.dart';

class TutorialDialog extends StatelessWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const TutorialDialog();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F4EB), // Warm paper color
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF5D7A68),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFFE5DFD5), size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Botanist\'s Guide',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7F4EB),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to your Window Garden.',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2520),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.light_mode,
                      color: const Color(0xFFD4A373),
                      title: 'Real Sunlight',
                      description: 'Sunlight enters your room based on real-time astronomical data for your selected city.',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.energy_savings_leaf,
                      color: const Color(0xFF8BA888),
                      title: 'Photosynthesis',
                      description: 'Adjust your window blinds to match your plant\'s ideal lighting. When the lighting is just right, they store energy quickly!',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.water_drop,
                      color: const Color(0xFF6B8E9B),
                      title: 'Watering & Health',
                      description: 'Don\'t forget to water them and wipe off the dust. Plants use stored energy and water to grow slowly over time.',
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BA888),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'I understand',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2520),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 13,
                  color: Color(0xFF6E645A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
