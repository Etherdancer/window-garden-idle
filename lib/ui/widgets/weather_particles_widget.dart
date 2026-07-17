import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/weather.dart';
import '../../services/weather_service.dart';

class WeatherParticlesWidget extends StatefulWidget {
  const WeatherParticlesWidget({super.key});

  @override
  State<WeatherParticlesWidget> createState() => _WeatherParticlesWidgetState();
}

class _WeatherParticlesWidgetState extends State<WeatherParticlesWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  WeatherState _currentWeather = WeatherState.sunny;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(_updateParticles)
      ..repeat();
  }

  void _updateParticles() {
    final weather = WeatherService.getWeatherForTime(DateTime.now());
    
    // If weather changes, clear particles to reset
    if (weather != _currentWeather) {
      _particles.clear();
      _currentWeather = weather;
    }

    if (weather == WeatherState.cloudy) return;

    final int targetCount = weather == WeatherState.rainy ? 80 : 25;

    // Remove dead particles
    _particles.removeWhere((p) => p.life <= 0 || p.y > 1.1 || p.y < -0.1 || p.x > 1.1 || p.x < -0.1);

    // Add new particles
    while (_particles.length < targetCount) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: weather == WeatherState.rainy ? -0.1 : _random.nextDouble(),
        speed: weather == WeatherState.rainy ? 0.02 + _random.nextDouble() * 0.02 : 0.001 + _random.nextDouble() * 0.002,
        size: weather == WeatherState.rainy ? 1.0 + _random.nextDouble() * 1.5 : 2.0 + _random.nextDouble() * 3.0,
        life: 1.0,
        seed: _random.nextDouble() * pi * 2, // For oscillating movement
      ));
    }

    // Update positions
    for (var p in _particles) {
      if (weather == WeatherState.rainy) {
        p.y += p.speed;
        p.x += 0.005; // slight wind angle
      } else if (weather == WeatherState.sunny) {
        // Dust motes for sunny light beams
        p.y -= p.speed * 0.2;
        p.x += sin(p.seed + p.y * 10) * 0.001; // gentle swaying
        p.life -= 0.002;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentWeather == WeatherState.cloudy && _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: ParticlePainter(particles: _particles, weather: _currentWeather),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double life;
  double seed;
  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.life,
    required this.seed,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final WeatherState weather;

  ParticlePainter({required this.particles, required this.weather});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    if (weather == WeatherState.rainy) {
      paint.color = Colors.white.withValues(alpha: 0.4);
      paint.strokeWidth = 1.5;
      for (var p in particles) {
        final screenX = p.x * size.width;
        final screenY = p.y * size.height;
        final lengthY = p.speed * size.height * 1.5;
        final lengthX = 0.005 * size.width * 1.5;
        canvas.drawLine(
          Offset(screenX, screenY),
          Offset(screenX + lengthX, screenY + lengthY),
          paint,
        );
      }
    } else if (weather == WeatherState.sunny) {
      for (var p in particles) {
        // Dust motes glowing in the light
        paint.color = const Color(0xFFFFE0B2).withValues(alpha: (0.4 * p.life).clamp(0.0, 1.0));
        canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
