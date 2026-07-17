import 'dart:math';

class SunlightService {
  /// Calculates the raw solar intensity (0.0 to 1.0) given a UTC time and coordinates.
  static double calculateSunlight(DateTime utcTime, double lat, double lon) {
    final n = _dayOfYear(utcTime);

    // Declination angle of the Earth (axial tilt ~23.44 degrees)
    final delta = -23.44 * cos(2 * pi / 365 * (n + 10));
    final deltaRad = delta * pi / 180.0;
    final latRad = lat * pi / 180.0;

    // Solar time in hours
    final solarTime = (utcTime.hour + utcTime.minute / 60.0 + utcTime.second / 3600.0) + (lon / 15.0);

    // Hour angle
    final h = (solarTime - 12.0) * 15.0;
    final hRad = h * pi / 180.0;

    // Solar elevation angle (alpha)
    final sinAlpha = sin(latRad) * sin(deltaRad) + cos(latRad) * cos(deltaRad) * cos(hRad);
    final alpha = asin(sinAlpha);
    final alphaDeg = alpha * 180.0 / pi;

    // Map elevation to light level.
    // 0 degrees is 0.0 (sunset/sunrise).
    // Let's cap max light at 40 degrees elevation so it reaches 1.0 even in spring/fall
    // for most mid-latitudes, but winter in the far north will be heavily penalized.
    if (alphaDeg <= 0) return 0.0;

    return (alphaDeg / 40.0).clamp(0.0, 1.0);
  }

  static int _dayOfYear(DateTime date) {
    final firstJan = DateTime.utc(date.year, 1, 1);
    return date.difference(firstJan).inDays + 1;
  }
}
