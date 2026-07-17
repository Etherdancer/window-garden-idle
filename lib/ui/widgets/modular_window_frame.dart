import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModularWindowFrame extends StatelessWidget {
  final String beamImagePath;
  final String benchImagePath;
  final double scale;

  const ModularWindowFrame({
    super.key,
    required this.beamImagePath,
    required this.benchImagePath,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Top Beam (Rotated 90 degrees)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100 * scale,
          child: Transform.rotate(
            angle: math.pi / 2,
            child: Image.asset(
              beamImagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        
        // Left Beam
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 80 * scale,
          child: Image.asset(
            beamImagePath,
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
        ),
        
        // Right Beam (Mirrored)
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 80 * scale,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: Image.asset(
              beamImagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        
        // Bottom Bench
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200 * scale,
          child: Image.asset(
            benchImagePath,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}
