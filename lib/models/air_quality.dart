class AirQuality {
  final double index;
  final String dominantPollutant;

  AirQuality({
    required this.index,
    required this.dominantPollutant,
  });

  String get label {
    if (index <= 50) return 'Good';
    if (index <= 100) return 'Moderate';
    if (index <= 150) return 'Unhealthy for Sensitive';
    if (index <= 200) return 'Unhealthy';
    if (index <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  double get progress => (index / 500).clamp(0.0, 1.0);
}
