import '../models/weather.dart';

class WeatherService {
  /// Gets the deterministic weather state for any given DateTime.
  /// Changes every 3 hours.
  static WeatherState getWeatherForTime(DateTime time) {
    // 3 hours interval = 10800 seconds
    final int blockIndex = time.millisecondsSinceEpoch ~/ (3 * 3600 * 1000);
    
    // Simple LCG pseudo-random hash
    final int hash = (blockIndex * 1103515245 + 12345) & 0x7fffffff;
    final int r = hash % 100;
    
    if (r < 50) {
      return WeatherState.sunny;
    } else if (r < 80) {
      return WeatherState.cloudy;
    } else {
      return WeatherState.rainy;
    }
  }

  /// Returns a display name for the weather state.
  static String getWeatherLabel(WeatherState state) {
    switch (state) {
      case WeatherState.sunny:
        return 'Sunny';
      case WeatherState.cloudy:
        return 'Cloudy';
      case WeatherState.rainy:
        return 'Rainy';
    }
  }
}
