enum BuffType {
  moistureRetention, // Slower water loss (flat % bonus)
  lightAbsorption,   // Faster photosynthesis energy gain (flat % bonus)
  growthSpeed,       // Faster growth progress (flat % bonus)
  resilience,        // Slower health drain in bad conditions (flat % bonus)
}

class PlantBuff {
  final BuffType type;
  /// Small flat percentage value, e.g., 0.01 for 1%, 0.02 for 2%.
  final double value;

  const PlantBuff({
    required this.type,
    required this.value,
  });

  String get description {
    final percentString = '${(value * 100).toStringAsFixed(1)}%';
    switch (type) {
      case BuffType.moistureRetention:
        return 'All plants lose water $percentString slower.';
      case BuffType.lightAbsorption:
        return 'All plants gain energy $percentString faster.';
      case BuffType.growthSpeed:
        return 'All plants grow $percentString faster.';
      case BuffType.resilience:
        return 'All plants lose health $percentString slower in poor conditions.';
    }
  }

  String get shortName {
    switch (type) {
      case BuffType.moistureRetention:
        return 'Moisture Retention';
      case BuffType.lightAbsorption:
        return 'Light Absorption';
      case BuffType.growthSpeed:
        return 'Growth Speed';
      case BuffType.resilience:
        return 'Resilience';
    }
  }
}
