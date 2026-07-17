import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CompanionWidget extends StatefulWidget {
  const CompanionWidget({super.key});

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget> {
  bool _isVisible = true;
  bool _isWaking = false;

  void _interact() {
    if (_isWaking) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isWaking = true;
    });
    
    // Simulate playing a purr or buzz sound here
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        
        // Come back randomly later
        Future.delayed(Duration(seconds: 15 + Random().nextInt(30)), () {
          if (mounted) {
            setState(() {
              _isVisible = true;
              _isWaking = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _interact,
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFCC5500), // Bug/cat color placeholder
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Eyes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            if (_isWaking)
              const Positioned(
                top: -15,
                child: Icon(Icons.favorite, size: 14, color: Colors.red),
              ).animate().fadeIn().moveY(begin: 0, end: -10),
          ],
        ),
      ).animate(target: _isWaking ? 1 : 0).shake(hz: 4),
    );
  }
}
