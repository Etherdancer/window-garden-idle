import 'package:flutter/material.dart';

class EnvironmentService {
  /// Returns a color overlay based on the hour of the day.
  /// Blends colors smoothly based on minute/hour.
  static Color getAmbientLighting(DateTime time) {
    final double hour = time.hour + (time.minute / 60.0);

    // Deep Night (0 - 5)
    if (hour < 5.0) {
      return const Color(0xFF0F172A).withValues(alpha: 0.55); // Dark blue overlay
    }
    // Dawn (5 - 7)
    else if (hour < 7.0) {
      final t = (hour - 5.0) / 2.0; // 0.0 to 1.0
      return Color.lerp(
        const Color(0xFF0F172A).withValues(alpha: 0.55),
        const Color(0xFFFFE4B5).withValues(alpha: 0.2), // Warm morning light
        t,
      )!;
    }
    // Morning/Day (7 - 17)
    else if (hour < 17.0) {
      return Colors.transparent; // Natural light
    }
    // Golden Hour / Sunset (17 - 19)
    else if (hour < 19.0) {
      final t = (hour - 17.0) / 2.0;
      return Color.lerp(
        Colors.transparent,
        const Color(0xFFFF7E67).withValues(alpha: 0.25), // Orange/Pink
        t,
      )!;
    }
    // Dusk to Night (19 - 21)
    else if (hour < 21.0) {
      final t = (hour - 19.0) / 2.0;
      return Color.lerp(
        const Color(0xFFFF7E67).withValues(alpha: 0.25),
        const Color(0xFF0F172A).withValues(alpha: 0.55),
        t,
      )!;
    }
    // Night (21 - 24)
    else {
      return const Color(0xFF0F172A).withValues(alpha: 0.55);
    }
  }
}
