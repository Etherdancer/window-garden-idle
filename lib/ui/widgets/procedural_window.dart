import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../models/garden_location.dart';

class ProceduralWindowWidget extends StatelessWidget {
  final GardenLocation location;
  final double lightLevel;

  const ProceduralWindowWidget({
    Key? key,
    required this.location,
    required this.lightLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationTz = tz.getLocation(location.timeZone);
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(minutes: 1), (_) => tz.TZDateTime.now(locationTz)),
      initialData: tz.TZDateTime.now(locationTz),
      builder: (context, snapshot) {
        final time = snapshot.data ?? tz.TZDateTime.now(locationTz);
        final hour = time.hour;
        
        // Determine tint color and blend mode based on time of day
        Color tintColor = Colors.transparent;
        BlendMode blendMode = BlendMode.dst;
        
        if (hour >= 5 && hour < 8) {
          // Sunrise: warm orange/pink overlay
          tintColor = const Color(0xFFFFB07A).withValues(alpha: 0.35);
          blendMode = BlendMode.overlay;
        } else if (hour >= 8 && hour < 17) {
          // Day: unmodified beautiful image
          tintColor = Colors.transparent;
          blendMode = BlendMode.dst;
        } else if (hour >= 17 && hour < 20) {
          // Sunset: deep violet/red hard light
          tintColor = const Color(0xFF5A2A3D).withValues(alpha: 0.55);
          blendMode = BlendMode.hardLight;
        } else {
          // Night: dark blue multiply
          tintColor = const Color(0xFF0A1526).withValues(alpha: 0.85);
          blendMode = BlendMode.srcATop; 
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. The High-Fidelity Image with Time-of-Day Tint
            ColorFiltered(
              colorFilter: ColorFilter.mode(tintColor, blendMode),
              child: Image.asset(
                location.windowImagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: location.accentPrimary,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
            
            // 2. Procedural Overlays (Stars at night, Blinds during day)
            CustomPaint(
              size: Size.infinite,
              painter: _OverlayPainter(
                lightLevel: lightLevel,
                time: time,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double lightLevel;
  final DateTime time;

  _OverlayPainter({
    required this.lightLevel,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hour = time.hour;
    final isNight = hour >= 18 || hour < 6;

    // Draw stars at night
    if (hour >= 20 || hour < 5) {
      final random = Random(42); 
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
      for (int i = 0; i < 50; i++) {
        canvas.drawCircle(
          Offset(random.nextDouble() * size.width, random.nextDouble() * size.height * 0.7),
          random.nextDouble() * 2,
          starPaint,
        );
      }
    }

    // Window Blinds during the day
    if (!isNight && lightLevel < 0.5) {
      final blindPaint = Paint()..color = Colors.black.withValues(alpha: 0.8);
      int blindsCount = 12;
      double blindHeight = size.height / (blindsCount * 2);
      
      double blindCoverage = 1.0 - (lightLevel / 0.5).clamp(0.0, 1.0);
      int visibleBlinds = (blindsCount * blindCoverage).ceil();
      
      for (int i = 0; i < visibleBlinds; i++) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * blindHeight * 2, size.width, blindHeight),
          blindPaint,
        );
      }
      
      if (visibleBlinds > 0) {
        double currentBottom = visibleBlinds * blindHeight * 2;
        canvas.drawLine(
          Offset(size.width * 0.9, 0),
          Offset(size.width * 0.9, currentBottom + 20),
          Paint()
            ..color = Colors.black87
            ..strokeWidth = 2,
        );
        canvas.drawCircle(
          Offset(size.width * 0.9, currentBottom + 20),
          4,
          Paint()..color = Colors.black87,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.lightLevel != lightLevel ||
           oldDelegate.time.minute != time.minute ||
           oldDelegate.time.hour != time.hour;
  }
}
