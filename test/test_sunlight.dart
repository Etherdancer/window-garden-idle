import 'dart:math';

double calculateSunlight(DateTime utcTime, double lat, double lon) {
  final N = _dayOfYear(utcTime);
  
  // Declination
  final delta = -23.44 * cos(2 * pi / 365 * (N + 10));
  final deltaRad = delta * pi / 180.0;
  final latRad = lat * pi / 180.0;

  // Solar time in hours
  final solarTime = (utcTime.hour + utcTime.minute / 60.0 + utcTime.second / 3600.0) + (lon / 15.0);
  
  // Hour angle
  final h = (solarTime - 12.0) * 15.0;
  final hRad = h * pi / 180.0;

  // Elevation
  final sinAlpha = sin(latRad) * sin(deltaRad) + cos(latRad) * cos(deltaRad) * cos(hRad);
  final alpha = asin(sinAlpha);
  final alphaDeg = alpha * 180.0 / pi;

  // Map elevation to light level. 
  // Let's say 40 degrees and above is 1.0 (full sun for a window).
  // 0 degrees is 0.0 (sunset/sunrise).
  if (alphaDeg <= 0) return 0.0;
  
  return (alphaDeg / 40.0).clamp(0.0, 1.0);
}

int _dayOfYear(DateTime date) {
  final firstJan = DateTime.utc(date.year, 1, 1);
  return date.difference(firstJan).inDays + 1;
}

void main() {
  final locations = {
    'Reykjavik (Winter)': [64.14, -21.94, DateTime.utc(2024, 12, 21, 12)], // Noon winter
    'Reykjavik (Summer)': [64.14, -21.94, DateTime.utc(2024, 6, 21, 12)],  // Noon summer
    'Equator (Spring)': [0.0, 0.0, DateTime.utc(2024, 3, 21, 12)],
  };

  for (var entry in locations.entries) {
    final name = entry.key;
    final lat = entry.value[0] as double;
    final lon = entry.value[1] as double;
    final time = entry.value[2] as DateTime;

    print('$name: ${calculateSunlight(time, lat, lon)}');
  }
}
