import 'package:flutter/material.dart';
import '../../models/garden_location.dart';

class NativeWindowFrame extends StatelessWidget {
  final WindowFrameType frameType;

  const NativeWindowFrame({super.key, required this.frameType});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: WindowFramePainter(frameType: frameType),
    );
  }
}

class WindowFramePainter extends CustomPainter {
  final WindowFrameType frameType;

  WindowFramePainter({required this.frameType});

  @override
  void paint(Canvas canvas, Size size) {
    switch (frameType) {
      case WindowFrameType.modern:
        _paintModern(canvas, size);
        break;
      case WindowFrameType.stone:
        _paintStone(canvas, size);
        break;
      case WindowFrameType.traditional:
      default:
        _paintRural(canvas, size);
        break;
    }
  }

  void _paintModern(Canvas canvas, Size size) {
    final double frameW = 20.0;
    final double sashW = 14.0;
    final double sillHeight = 80.0;
    final double sillLip = 22.0;

    // Anime realistic white modern window relies on soft blues and crisp whites
    final Color baseWhite = const Color(0xFFF4F7FB);
    final Color shadowBlue = const Color(0xFFB5C0D0);
    final Color deepShadow = const Color(0xFF8A99AF);
    final Color highlightWhite = const Color(0xFFFFFFFF);
    final Color glassTint = const Color(0x228AC4FF);

    // 1. Outer Casing (Left, Top, Right)
    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height - sillHeight))
      ..addRect(Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, size.height - sillHeight - frameW))
      ..fillType = PathFillType.evenOdd;

    final Paint outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [highlightWhite, baseWhite, shadowBlue],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(outerPath, outerPaint);

    // Inner bevel of outer frame
    _drawBevel(canvas, Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, size.height - sillHeight - frameW), shadowBlue, highlightWhite, 2.0, true);

    // 2. Inner Sash (Left, Top, Right)
    final Rect sashRect = Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, size.height - sillHeight - frameW);
    final Path sashPath = Path()
      ..addRect(sashRect)
      ..addRect(Rect.fromLTWH(frameW + sashW, frameW + sashW, size.width - (frameW + sashW) * 2, size.height - sillHeight - frameW - sashW))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(sashPath, Paint()..color = baseWhite);
    _drawBevel(canvas, sashRect, highlightWhite, deepShadow, 3.0, false);
    _drawBevel(canvas, Rect.fromLTWH(frameW + sashW, frameW + sashW, size.width - (frameW + sashW) * 2, size.height - sillHeight - frameW - sashW), deepShadow, highlightWhite, 2.0, true);

    // 3. Central Mullion (Vertical or Horizontal)
    // Let's add a horizontal crossbar in the top half
    final double crossbarY = (size.height - sillHeight) * 0.35;
    final double crossbarH = 12.0;
    final Rect crossbarRect = Rect.fromLTWH(frameW + sashW, crossbarY, size.width - (frameW + sashW) * 2, crossbarH);
    canvas.drawRect(crossbarRect, Paint()..color = baseWhite);
    _drawBevel(canvas, crossbarRect, highlightWhite, deepShadow, 2.0, false);

    // 4. Glass Edge Tint (Anime realism often has glowing glass edges)
    final Rect topGlass = Rect.fromLTWH(frameW + sashW, frameW + sashW, size.width - (frameW + sashW) * 2, crossbarY - (frameW + sashW));
    final Rect bottomGlass = Rect.fromLTWH(frameW + sashW, crossbarY + crossbarH, size.width - (frameW + sashW) * 2, size.height - sillHeight - (crossbarY + crossbarH));
    
    _drawGlassEdge(canvas, topGlass, glassTint);
    _drawGlassEdge(canvas, bottomGlass, glassTint);

    // 5. The Sill (Bottom)
    final Rect sillTopRect = Rect.fromLTWH(0, size.height - sillHeight, size.width, sillLip);
    canvas.drawRect(
      sillTopRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [highlightWhite, baseWhite],
        ).createShader(sillTopRect),
    );
    // Sill Top Highlight
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight, size.width, 2), Paint()..color = highlightWhite);

    final Rect sillFrontRect = Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, sillHeight - sillLip);
    canvas.drawRect(
      sillFrontRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shadowBlue, deepShadow],
        ).createShader(sillFrontRect),
    );
    
    // Sill Overhang Shadow
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, 4), Paint()..color = deepShadow.withOpacity(0.8));
  }

  void _paintRural(Canvas canvas, Size size) {
    // Rich, warm anime wood
    final double frameW = 24.0;
    final double sillHeight = 85.0;
    final double sillLip = 28.0;

    final Color woodBase = const Color(0xFF8B4513); // SaddleBrown
    final Color woodLight = const Color(0xFFA0522D); // Sienna
    final Color woodHighlight = const Color(0xFFCD853F); // Peru
    final Color woodShadow = const Color(0xFF3E1F00); // Deep warm brown

    // Outer Frame
    final Path framePath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height - sillHeight))
      ..addRect(Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, size.height - sillHeight - frameW))
      ..fillType = PathFillType.evenOdd;

    // Wood texture gradient
    final Paint framePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [woodLight, woodBase, woodShadow],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(framePath, framePaint);

    // Miter joints (45 degree lines at corners)
    final Paint linePaint = Paint()
      ..color = woodShadow.withOpacity(0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, 0), Offset(frameW, frameW), linePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - frameW, frameW), linePaint);

    // Bevels
    _drawBevel(canvas, Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, size.height - sillHeight - frameW), woodShadow, woodHighlight, 3.0, true);
    _drawBevel(canvas, Rect.fromLTWH(0, 0, size.width, size.height - sillHeight), woodHighlight, woodShadow, 2.0, false);

    // Horizontal crossbar
    final double crossbarY = (size.height - sillHeight) * 0.4;
    final double crossbarH = 16.0;
    final Rect crossbarRect = Rect.fromLTWH(frameW, crossbarY, size.width - frameW * 2, crossbarH);
    canvas.drawRect(
      crossbarRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [woodLight, woodBase, woodShadow],
        ).createShader(crossbarRect),
    );
    _drawBevel(canvas, crossbarRect, woodHighlight, woodShadow, 2.0, false);

    // Glass glow (warm afternoon tint)
    final Color warmGlass = const Color(0x1AFFE4B5);
    _drawGlassEdge(canvas, Rect.fromLTWH(frameW, frameW, size.width - frameW * 2, crossbarY - frameW), warmGlass);
    _drawGlassEdge(canvas, Rect.fromLTWH(frameW, crossbarY + crossbarH, size.width - frameW * 2, size.height - sillHeight - (crossbarY + crossbarH)), warmGlass);

    // Sill Top
    final Rect sillTopRect = Rect.fromLTWH(0, size.height - sillHeight, size.width, sillLip);
    canvas.drawRect(
      sillTopRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [woodHighlight, woodBase],
        ).createShader(sillTopRect),
    );

    // Sill Front
    final Rect sillFrontRect = Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, sillHeight - sillLip);
    canvas.drawRect(
      sillFrontRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [woodShadow, const Color(0xFF1A0A00)],
        ).createShader(sillFrontRect),
    );
    
    // Sill edge highlight and overhang shadow
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight, size.width, 2), Paint()..color = const Color(0xFFFFB870).withOpacity(0.8));
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, 5), Paint()..color = const Color(0xFF1A0A00).withOpacity(0.9));
  }

  void _paintStone(Canvas canvas, Size size) {
    // Arching stone window with plaster wall
    final double sillHeight = 90.0;
    final double sillLip = 30.0;
    final double frameW = 35.0; // Thick stone

    final Color wallColor = const Color(0xFFE8E0D5); // Warm plaster
    final Color stoneLight = const Color(0xFFB0B3B8);
    final Color stoneBase = const Color(0xFF8A8D91);
    final Color stoneShadow = const Color(0xFF5A5C61);
    final Color ambientOcclusion = const Color(0xFF303236);

    // 1. The Plaster Wall (fill everything first)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = wallColor);

    // 2. The Window Arch Opening
    final double archRadius = (size.width - frameW * 2) / 2;
    final double archTopY = 40.0; // Distance from top of screen
    
    final Path windowOpening = Path();
    windowOpening.moveTo(frameW, size.height - sillHeight);
    windowOpening.lineTo(frameW, archTopY + archRadius);
    windowOpening.arcToPoint(
      Offset(size.width - frameW, archTopY + archRadius),
      radius: Radius.circular(archRadius),
      clockwise: true,
    );
    windowOpening.lineTo(size.width - frameW, size.height - sillHeight);
    windowOpening.close();

    // Clear the window opening to transparent so the background shows!
    canvas.drawPath(windowOpening, Paint()..blendMode = BlendMode.clear);

    // 3. Draw Stone Arch Frame (Extruding outwards)
    // We will draw individual stone blocks around the arch
    final Paint blockPaint = Paint()..color = stoneBase;
    
    // Left Pillar
    final Rect leftPillar = Rect.fromLTWH(0, archTopY + archRadius, frameW, size.height - sillHeight - (archTopY + archRadius));
    canvas.drawRect(leftPillar, Paint()..shader = LinearGradient(colors: [stoneLight, stoneBase]).createShader(leftPillar));
    _drawBevel(canvas, leftPillar, stoneLight, stoneShadow, 2.0, false);
    
    // Right Pillar
    final Rect rightPillar = Rect.fromLTWH(size.width - frameW, archTopY + archRadius, frameW, size.height - sillHeight - (archTopY + archRadius));
    canvas.drawRect(rightPillar, Paint()..shader = LinearGradient(colors: [stoneBase, stoneShadow]).createShader(rightPillar));
    _drawBevel(canvas, rightPillar, stoneLight, stoneShadow, 2.0, false);

    // Arch stones (Voussoirs)
    // We'll draw a thick stroked arc
    final Rect archBounds = Rect.fromLTRB(0, archTopY, size.width, archTopY + archRadius * 2);
    final Path archPath = Path()..addArc(archBounds, 3.14159, 3.14159);
    final Paint archPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = frameW
      ..color = stoneBase;
    canvas.drawPath(archPath, archPaint);
    
    // Inner shadow of the arch (depth)
    final Path innerArchShadow = Path()..addArc(Rect.fromLTRB(frameW, archTopY + frameW, size.width - frameW, archTopY + frameW + archRadius * 2), 3.14159, 3.14159);
    canvas.drawPath(innerArchShadow, Paint()..style=PaintingStyle.stroke..strokeWidth=6..color=ambientOcclusion.withOpacity(0.6));
    canvas.drawRect(Rect.fromLTWH(frameW, archTopY + archRadius, 6, size.height - sillHeight - (archTopY + archRadius)), Paint()..color = ambientOcclusion.withOpacity(0.6));
    
    // Stone Sill
    final Rect sillTopRect = Rect.fromLTWH(0, size.height - sillHeight, size.width, sillLip);
    canvas.drawRect(
      sillTopRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [stoneLight, stoneBase],
        ).createShader(sillTopRect),
    );

    final Rect sillFrontRect = Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, sillHeight - sillLip);
    canvas.drawRect(
      sillFrontRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [stoneShadow, ambientOcclusion],
        ).createShader(sillFrontRect),
    );

    // Sill Bevels
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight, size.width, 3), Paint()..color = const Color(0xFFD0D3D6));
    canvas.drawRect(Rect.fromLTWH(0, size.height - sillHeight + sillLip, size.width, 5), Paint()..color = ambientOcclusion.withOpacity(0.8));

    // Horizontal iron bars for realism
    final double barY1 = (size.height - sillHeight) * 0.5;
    final double barY2 = (size.height - sillHeight) * 0.75;
    final Paint ironPaint = Paint()..color = const Color(0xFF222222);
    canvas.drawRect(Rect.fromLTWH(frameW, barY1, size.width - frameW * 2, 6), ironPaint);
    canvas.drawRect(Rect.fromLTWH(frameW, barY2, size.width - frameW * 2, 6), ironPaint);
    
    // Iron bar highlights
    canvas.drawRect(Rect.fromLTWH(frameW, barY1, size.width - frameW * 2, 1), Paint()..color = stoneLight.withOpacity(0.5));
    canvas.drawRect(Rect.fromLTWH(frameW, barY2, size.width - frameW * 2, 1), Paint()..color = stoneLight.withOpacity(0.5));
  }

  // Helper to draw realistic 3D bevels
  void _drawBevel(Canvas canvas, Rect rect, Color topLeftColor, Color bottomRightColor, double width, bool inner) {
    final Path topPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - (inner ? -width : width), rect.top + (inner ? -width : width))
      ..lineTo(rect.left + (inner ? -width : width), rect.top + (inner ? -width : width))
      ..close();

    final Path leftPath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + (inner ? -width : width), rect.top + (inner ? -width : width))
      ..lineTo(rect.left + (inner ? -width : width), rect.bottom - (inner ? -width : width))
      ..lineTo(rect.left, rect.bottom)
      ..close();

    final Path bottomPath = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left + (inner ? -width : width), rect.bottom - (inner ? -width : width))
      ..lineTo(rect.right - (inner ? -width : width), rect.bottom - (inner ? -width : width))
      ..lineTo(rect.right, rect.bottom)
      ..close();

    final Path rightPath = Path()
      ..moveTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right - (inner ? -width : width), rect.bottom - (inner ? -width : width))
      ..lineTo(rect.right - (inner ? -width : width), rect.top + (inner ? -width : width))
      ..close();

    canvas.drawPath(topPath, Paint()..color = topLeftColor);
    canvas.drawPath(leftPath, Paint()..color = topLeftColor);
    canvas.drawPath(bottomPath, Paint()..color = bottomRightColor);
    canvas.drawPath(rightPath, Paint()..color = bottomRightColor);
  }

  // Helper to draw a glass glow/reflection on the edges of the pane
  void _drawGlassEdge(Canvas canvas, Rect rect, Color tint) {
    final Paint paint = Paint()
      ..color = tint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    
    // Draw an inner stroke
    canvas.drawRect(Rect.fromLTWH(rect.left + 3, rect.top + 3, rect.width - 6, rect.height - 6), paint);
    
    // Add a strong diagonal reflection line
    final Path reflection = Path()
      ..moveTo(rect.left + rect.width * 0.1, rect.top)
      ..lineTo(rect.left + rect.width * 0.3, rect.top)
      ..lineTo(rect.left, rect.top + rect.height * 0.4)
      ..lineTo(rect.left, rect.top + rect.height * 0.2)
      ..close();
    
    canvas.drawPath(reflection, Paint()..color = Colors.white.withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant WindowFramePainter oldDelegate) {
    return oldDelegate.frameType != frameType;
  }
}

