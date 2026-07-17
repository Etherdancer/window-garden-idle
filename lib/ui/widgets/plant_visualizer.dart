import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/plant.dart';
import '../../models/plant_visual_config.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

class PlantVisualizerWidget extends StatefulWidget {
  final Plant plant;
  final double size;

  const PlantVisualizerWidget({
    super.key,
    required this.plant,
    required this.size,
  });

  @override
  State<PlantVisualizerWidget> createState() => _PlantVisualizerWidgetState();
}

class _PlantVisualizerWidgetState extends State<PlantVisualizerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 500.ms);
  }

  @override
  void didUpdateWidget(PlantVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation if plant was watered significantly
    if (widget.plant.currentWaterLevel > oldWidget.plant.currentWaterLevel + 2) {
      _triggerInteraction();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerInteraction() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    setState(() => _showParticles = true);
    Future.delayed(1.seconds, () {
      if (mounted) setState(() => _showParticles = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always attempt to load the generated 2D isometric pixel art sprite
    bool hasSprite = true;
    String spritePath = 'assets/images/plants/${widget.plant.speciesId}.png';

    return GestureDetector(
      onTap: _triggerInteraction,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            if (hasSprite)
              Image.asset(
                spritePath,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: ParametricPlantPainter(plant: widget.plant),
                ),
              )
            else
              // Fallback to Data-Driven Parametric Plant Drawing
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: ParametricPlantPainter(plant: widget.plant),
              ),
            
            // Dust overlay
            if (widget.plant.dustLevel > 0)
              Opacity(
                opacity: (widget.plant.dustLevel / 100.0).clamp(0.0, 1.0) * 0.7,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: DustPainter(),
                ),
              ),
              
            // Happy Particles Overlay
            if (_showParticles)
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlesPainter(seed: DateTime.now().millisecondsSinceEpoch),
                ).animate().fadeIn(duration: 200.ms).moveY(begin: 10, end: -30, duration: 800.ms).fadeOut(delay: 500.ms),
              ),
          ],
        ).animate(controller: _controller, autoPlay: false).shake(hz: 3, curve: Curves.easeOut, rotation: 0.05),
      ),
    );
  }
}

// ---------------------------------------------------------
// Particles Painter (Hearts/Sparkles)
// ---------------------------------------------------------
class ParticlesPainter extends CustomPainter {
  final int seed;
  ParticlesPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < 6; i++) {
      paint.color = random.nextBool() ? const Color(0xFFFFB6C1) : const Color(0xFF87CEFA);
      double dx = size.width * 0.2 + random.nextDouble() * size.width * 0.6;
      double dy = size.height * 0.2 + random.nextDouble() * size.height * 0.4;
      canvas.drawCircle(Offset(dx, dy), 3 + random.nextDouble() * 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// Dust Painter
// ---------------------------------------------------------
class DustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;
      
    final random = Random(42); 
    
    for (int i = 0; i < 50; i++) {
      double dx = random.nextDouble() * size.width;
      double dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), random.nextDouble() * 2 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DustPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// Parametric Plant Painter
// ---------------------------------------------------------
class ParametricPlantPainter extends CustomPainter {
  final Plant plant;
  late final PlantVisualConfig config;
  late final int seed;
  late final double healthRatio;

  ParametricPlantPainter({required this.plant}) {
    config = PlantVisualConfig.getConfigForSpecies(plant.speciesId);
    seed = plant.id.hashCode ^ plant.speciesId.hashCode;
    healthRatio = (plant.health / 100.0).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    
    if (plant.growthStage == 1) {
      _drawSprout(canvas, size);
    } else {
      _drawMaturePlant(canvas, size, random);
    }
  }

  Color _applyHealthToColor(Color baseColor) {
    final witheredColor = const Color(0xFF9E8A54);
    return Color.lerp(witheredColor, baseColor, healthRatio) ?? baseColor;
  }

  void _drawMaturePlant(Canvas canvas, Size size, Random random) {
    final primaryLeafColor = _applyHealthToColor(config.primaryColor);
    final secondaryLeafColor = _applyHealthToColor(config.secondaryColor);
    final stemColor = _applyHealthToColor(config.stemColor);

    switch (config.growthHabit) {
      case PlantGrowthHabit.upright:
      case PlantGrowthHabit.bushy:
        _drawBranchingSystem(canvas, size, random, primaryLeafColor, secondaryLeafColor, stemColor);
        break;
      case PlantGrowthHabit.trailing:
        _drawTrailingSystem(canvas, size, random, primaryLeafColor, secondaryLeafColor, stemColor);
        break;
      case PlantGrowthHabit.rosette:
        _drawRosetteSystem(canvas, size, random, primaryLeafColor, secondaryLeafColor, stemColor);
        break;
      case PlantGrowthHabit.tallStems:
        _drawTallStemsSystem(canvas, size, random, primaryLeafColor, secondaryLeafColor, stemColor);
        break;
      case PlantGrowthHabit.creeping:
        _drawCreepingSystem(canvas, size, random, primaryLeafColor, secondaryLeafColor, stemColor);
        break;
    }
  }

  void _drawBranchingSystem(Canvas canvas, Size size, Random random, Color pColor, Color sColor, Color stemColor) {
    final numBranches = (config.growthHabit == PlantGrowthHabit.bushy)
        ? (plant.growthStage * 2) + config.branchingFactor
        : (plant.growthStage) + (config.branchingFactor / 2).floor();
        
    final stemPaint = Paint()
      ..color = stemColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, size.width * 0.02 * config.stemThickness)
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final bottomY = size.height;

    for (int i = 0; i < numBranches; i++) {
      canvas.save();
      canvas.translate(centerX, bottomY);
      
      double spread = (config.growthHabit == PlantGrowthHabit.bushy) ? 2.0 : 1.0;
      double angle = ((i / (numBranches > 1 ? numBranches - 1 : 1)) - 0.5) * spread;
      if (numBranches == 1) angle = 0;
      
      double branchLen = size.height * (0.2 + (plant.growthStage * 0.15)) * (0.7 + random.nextDouble() * 0.6);
      canvas.rotate(angle);
      
      // Draw Branch
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(branchLen * (random.nextDouble() * 0.4 - 0.2), -branchLen * 0.5, 0, -branchLen);
      canvas.drawPath(path, stemPaint);
      
      // Draw Leaves along branch
      int numLeaves = (plant.growthStage * 2 * config.leafDensity).floor() + random.nextInt(3);
      for (int j = 1; j <= numLeaves; j++) {
        double t = j / (numLeaves + 1);
        double lx = _quadBezier(t, 0, branchLen * 0.1, 0);
        double ly = _quadBezier(t, 0, -branchLen * 0.5, -branchLen);
        bool isLeft = j % 2 == 0;
        double leafAngle = isLeft ? -1.0 : 1.0;
        double leafLen = size.width * 0.04 * config.leafDensity + (plant.growthStage * size.width * 0.01);
        _drawDetailedLeaf(canvas, Offset(lx, ly), leafAngle, leafLen, pColor, sColor, random);
      }
      
      // Draw Top feature (Flower, Fruit, or Leaf)
      if (config.hasFlowers && plant.growthStage >= 4 && random.nextDouble() > 0.3) {
        _drawFlower(canvas, Offset(0, -branchLen), size.width * 0.08, config.flowerColor ?? Colors.pink, random);
      } else if (config.hasFruits && plant.growthStage == 5 && random.nextDouble() > 0.4) {
        _drawFruit(canvas, Offset(0, -branchLen), size.width * 0.06, config.fruitColor ?? Colors.red, random);
      } else {
        _drawDetailedLeaf(canvas, Offset(0, -branchLen), -pi / 2, size.width * 0.05 * config.leafDensity + (plant.growthStage * size.width * 0.01), pColor, sColor, random);
      }

      canvas.restore();
    }
  }

  void _drawTrailingSystem(Canvas canvas, Size size, Random random, Color pColor, Color sColor, Color stemColor) {
    final vinePaint = Paint()
      ..color = stemColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, size.width * 0.015 * config.stemThickness);

    final centerX = size.width / 2;
    final startY = size.height * 0.9; 

    int numVines = (plant.growthStage * config.branchingFactor / 3).ceil();

    for (int i = 0; i < numVines; i++) {
      final path = Path();
      path.moveTo(centerX, startY);
      
      double endX = centerX + ((random.nextDouble() - 0.5) * size.width * 1.5);
      double endY = startY - (size.height * (0.2 + (plant.growthStage * 0.15)));

      path.quadraticBezierTo(
        centerX + (endX - centerX) / 2,
        startY - size.height * 0.2,
        endX, 
        endY
      );

      canvas.drawPath(path, vinePaint);

      int numLeaves = (3 * config.leafDensity + plant.growthStage * 2).floor();
      for (int j = 1; j <= numLeaves; j++) {
        double t = j / numLeaves;
        double lx = _quadBezier(t, centerX, centerX + (endX - centerX) / 2, endX);
        double ly = _quadBezier(t, startY, startY - size.height * 0.2, endY);
        
        _drawDetailedLeaf(canvas, Offset(lx, ly), (j % 2 == 0) ? -0.5 : 0.5, size.width * 0.08, pColor, sColor, random);
      }
    }
  }

  void _drawRosetteSystem(Canvas canvas, Size size, Random random, Color pColor, Color sColor, Color stemColor) {
    final centerX = size.width / 2;
    final bottomY = size.height * 0.9;

    int numLeaves = (plant.growthStage * config.branchingFactor * 2) + 2;

    canvas.save();
    canvas.translate(centerX, bottomY);

    for (int i = numLeaves; i > 0; i--) {
      double angle = (i * 1.61803398875) * 2 * pi; 
      double radius = size.width * 0.05 * (i / numLeaves) * plant.growthStage;
      double leafLength = size.width * 0.15 * config.leafDensity * (1.2 - (i / numLeaves));

      canvas.save();
      canvas.rotate(angle);
      canvas.translate(0, -radius);
      
      _drawDetailedLeaf(canvas, const Offset(0, 0), -pi / 2, leafLength * 3, pColor, sColor, random);
      canvas.restore();
    }
    
    canvas.restore();
  }

  void _drawTallStemsSystem(Canvas canvas, Size size, Random random, Color pColor, Color sColor, Color stemColor) {
    final centerX = size.width / 2;
    final bottomY = size.height;

    int numBlades = plant.growthStage * config.branchingFactor; 

    for (int i = 0; i < numBlades; i++) {
      double angle = ((i / (numBlades > 1 ? numBlades - 1 : 1)) - 0.5) * 1.0; 
      if (numBlades == 1) angle = 0;

      double heightFactor = 0.5 + (random.nextDouble() * 0.5); 
      double bladeHeight = size.height * heightFactor * (0.2 + (plant.growthStage * 0.15));

      canvas.save();
      canvas.translate(centerX, bottomY);
      canvas.rotate(angle);

      _drawDetailedLeaf(canvas, const Offset(0, 0), -pi / 2, bladeHeight * 1.5, pColor, sColor, random);

      // optional top flower (e.g. chives)
      if (config.hasFlowers && plant.growthStage >= 4 && random.nextDouble() > 0.6) {
        _drawFlower(canvas, Offset(0, -bladeHeight), size.width * 0.06, config.flowerColor ?? Colors.purple, random);
      }

      canvas.restore();
    }
  }

  void _drawCreepingSystem(Canvas canvas, Size size, Random random, Color pColor, Color sColor, Color stemColor) {
    final stemPaint = Paint()
      ..color = stemColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.5, size.width * 0.015 * config.stemThickness)
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final bottomY = size.height;

    int numCreeps = plant.growthStage * config.branchingFactor;
    for (int i = 0; i < numCreeps; i++) {
      canvas.save();
      canvas.translate(centerX, bottomY);
      
      double angle = (random.nextDouble() - 0.5) * 2.5;
      double len = size.width * 0.4 * (0.5 + random.nextDouble() * 0.5) * (plant.growthStage / 5);
      
      canvas.rotate(angle);
      
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(len * 0.2, -size.height * 0.1, 0, -len);
      canvas.drawPath(path, stemPaint);
      
      int numLeavesInCluster = (2 + plant.growthStage) * config.leafDensity.floor();
      for (int j = 0; j < numLeavesInCluster; j++) {
        double leafAngle = (random.nextDouble() - 0.5) * 4.0;
        _drawDetailedLeaf(canvas, Offset(0, -len + (random.nextDouble() * len * 0.5)), leafAngle, size.width * 0.06, pColor, sColor, random);
      }
      
      canvas.restore();
    }
  }

  // --------------------------------------------------------------------------
  // The crucial parametrized leaf drawing function
  // --------------------------------------------------------------------------
  void _drawDetailedLeaf(Canvas canvas, Offset position, double angle, double length, Color pColor, Color sColor, Random random) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    double scale = length / 20.0;
    canvas.scale(scale);

    final path = Path();
    path.moveTo(0, 0);

    switch (config.leafShape) {
      case LeafShape.oval:
        path.quadraticBezierTo(10, -10, 20, 0);
        path.quadraticBezierTo(10, 10, 0, 0);
        break;
      case LeafShape.pointy:
        path.quadraticBezierTo(8, -5, 20, 0);
        path.quadraticBezierTo(8, 5, 0, 0);
        break;
      case LeafShape.heart:
        path.cubicTo(5, -15, 15, -5, 20, 0);
        path.cubicTo(15, 5, 5, 15, 0, 0);
        break;
      case LeafShape.needle:
        path.quadraticBezierTo(10, -2, 25, 0);
        path.quadraticBezierTo(10, 2, 0, 0);
        break;
      case LeafShape.lobed:
        path.quadraticBezierTo(5, -8, 10, -4);
        path.quadraticBezierTo(15, -10, 20, 0);
        path.quadraticBezierTo(15, 10, 10, 4);
        path.quadraticBezierTo(5, 8, 0, 0);
        break;
      case LeafShape.sword:
        path.quadraticBezierTo(2, -length * 0.05, 20, 0);
        path.quadraticBezierTo(2, length * 0.05, 0, 0);
        break;
      case LeafShape.fleshy:
        path.quadraticBezierTo(12, -8, 20, 0);
        path.quadraticBezierTo(12, 8, 0, 0);
        break;
      case LeafShape.round:
        path.addOval(Rect.fromCircle(center: const Offset(10, 0), radius: 10));
        break;
    }
    
    path.close();

    // Add subtle drop shadow for depth
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.3), 1.5, false);

    // Apply linear gradient to leaf for realistic lighting
    final Rect bounds = path.getBounds();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(pColor, Colors.white, 0.15)!,
          pColor,
          Color.lerp(pColor, Colors.black, 0.25)!,
        ],
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    
    final detailPaint = Paint()
      ..color = sColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(path, paint);

    // Draw leaf veins/details based on shape
    if (config.leafShape != LeafShape.needle && config.leafShape != LeafShape.sword && config.leafShape != LeafShape.fleshy) {
      canvas.drawLine(const Offset(0, 0), const Offset(18, 0), detailPaint); // central vein
      if (length > 10) { // lateral veins if large enough
        canvas.drawLine(const Offset(5, 0), const Offset(10, -4), detailPaint);
        canvas.drawLine(const Offset(10, 0), const Offset(15, 4), detailPaint);
      }
    } else if (config.leafShape == LeafShape.fleshy) {
      // Outline for fleshy
      canvas.drawPath(path, detailPaint);
    } else if (config.leafShape == LeafShape.sword) {
      canvas.drawLine(const Offset(0, 0), const Offset(20, 0), detailPaint);
    }

    canvas.restore();
  }

  void _drawFlower(Canvas canvas, Offset center, double radius, Color color, Random random) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Add shadow
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)), Colors.black.withValues(alpha: 0.2), 2.0, false);

    final petalPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.1)!,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.fill;

    final centerPaint = Paint()
      ..color = Colors.brown[700]!
      ..style = PaintingStyle.fill;

    int numPetals = 5 + random.nextInt(4);
    for (int i = 0; i < numPetals; i++) {
      canvas.save();
      canvas.rotate(i * (2 * pi) / numPetals);
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(radius * 0.8, -radius * 0.5, radius * 1.5, 0);
      path.quadraticBezierTo(radius * 0.8, radius * 0.5, 0, 0);
      path.close();
      canvas.drawPath(path, petalPaint);
      
      // Delicate petal lines
      canvas.drawLine(const Offset(0, 0), Offset(radius, 0), Paint()..color = Colors.white.withValues(alpha: 0.3)..strokeWidth = 0.5);
      canvas.restore();
    }
    
    // Flower Center detail
    canvas.drawCircle(Offset.zero, radius * 0.4, centerPaint);
    canvas.drawCircle(Offset(-radius * 0.1, -radius * 0.1), radius * 0.1, Paint()..color = Colors.yellow[600]!);

    canvas.restore();
  }

  void _drawFruit(Canvas canvas, Offset center, double radius, Color color, Random random) {
    // Add drop shadow
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: center, radius: radius)), Colors.black.withValues(alpha: 0.3), 3.0, false);

    final fruitPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(color, Colors.white, 0.3)!,
          color,
          Color.lerp(color, Colors.black, 0.4)!,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
      
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fruitPaint);
    
    // Specular highlight
    canvas.drawOval(
      Rect.fromCenter(center: center + Offset(-radius * 0.4, -radius * 0.4), width: radius * 0.5, height: radius * 0.3),
      highlightPaint
    );
    
    // Fruit stem
    canvas.drawLine(center + Offset(0, -radius * 0.8), center + Offset(0, -radius * 1.4), Paint()..color = Colors.brown..strokeWidth = 1.5);
  }

  double _quadBezier(double t, double p0, double p1, double p2) {
    return pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + pow(t, 2) * p2;
  }

  void _drawSprout(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = _applyHealthToColor(config.stemColor).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, size.width * 0.03)
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final bottomY = size.height;
    final topY = size.height * 0.8;

    final path = Path();
    path.moveTo(centerX, bottomY);
    path.quadraticBezierTo(centerX + size.width * 0.02, bottomY - size.height * 0.1, centerX, topY);
    canvas.drawPath(path, stemPaint);

    double leafLen = size.width * 0.12;
    _drawDetailedLeaf(canvas, Offset(centerX, topY), -0.5, leafLen, config.primaryColor, config.secondaryColor, Random(seed));
    _drawDetailedLeaf(canvas, Offset(centerX, topY), 0.5, leafLen, config.primaryColor, config.secondaryColor, Random(seed));
  }

  @override
  bool shouldRepaint(covariant ParametricPlantPainter oldDelegate) {
    return oldDelegate.plant.id != plant.id ||
           oldDelegate.plant.growthStage != plant.growthStage ||
           oldDelegate.plant.health != plant.health;
  }
}
