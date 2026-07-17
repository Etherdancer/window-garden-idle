import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../models/garden_location.dart';
import '../../services/sunlight_service.dart';

class ProceduralWindowWidget extends StatelessWidget {
  final GardenLocation location;
  final double blindsLevel;

  const ProceduralWindowWidget({
    Key? key,
    required this.location,
    required this.blindsLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationTz = tz.getLocation(location.timeZone);
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(minutes: 1), (_) => tz.TZDateTime.now(locationTz)),
      initialData: tz.TZDateTime.now(locationTz),
      builder: (context, snapshot) {
        final time = snapshot.data ?? tz.TZDateTime.now(locationTz);
        
        final maxSunlight = SunlightService.calculateSunlight(
          time.toUtc(), 
          location.latitude, 
          location.longitude,
        );

        // Determine tint color and blend mode based on maxSunlight and hour
        Color tintColor = Colors.transparent;
        BlendMode blendMode = BlendMode.dst;
        
        final hour = time.hour;
        
        if (maxSunlight == 0.0) {
          // Night
          tintColor = const Color(0xFF0A1526).withValues(alpha: 0.85);
          blendMode = BlendMode.srcATop; 
        } else if (maxSunlight < 0.3) {
          // Sunrise/Sunset (low sun)
          if (hour < 12) {
            tintColor = const Color(0xFFFFB07A).withValues(alpha: 0.35); // Sunrise warm
          } else {
            tintColor = const Color(0xFF5A2A3D).withValues(alpha: 0.55); // Sunset deep
          }
          blendMode = BlendMode.overlay;
        } else {
          // Day
          tintColor = Colors.transparent;
          blendMode = BlendMode.dst;
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
                blindsLevel: blindsLevel,
                maxSunlight: maxSunlight,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double blindsLevel;
  final double maxSunlight;

  _OverlayPainter({
    required this.blindsLevel,
    required this.maxSunlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isNight = maxSunlight <= 0.0;

    // Draw stars at night
    if (isNight) {
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

    // Window Blinds
    if (blindsLevel > 0.0) {
      final blindPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
      const double frameTopOffset = 14.0; // Account for the window frame
      const double slatHeight = 12.0;
      const double gapHeight = 8.0;
      const double step = slatHeight + gapHeight;
      
      final double visualHeight = size.height - frameTopOffset;
      final double coveredHeight = frameTopOffset + (visualHeight * blindsLevel);
      
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, frameTopOffset, size.width, coveredHeight - frameTopOffset));
      
      int totalSlats = (visualHeight / step).ceil();
      for (int i = 0; i < totalSlats; i++) {
        canvas.drawRect(
          Rect.fromLTWH(0, frameTopOffset + i * step, size.width, slatHeight),
          blindPaint,
        );
      }
      
      canvas.restore();
      
      // Draw the string pull
      canvas.drawLine(
        Offset(size.width * 0.9, frameTopOffset),
        Offset(size.width * 0.9, coveredHeight + 20),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(size.width * 0.9, coveredHeight + 20),
        6,
        Paint()..color = Colors.black54,
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    return oldDelegate.blindsLevel != blindsLevel || oldDelegate.maxSunlight != maxSunlight;
  }
}
