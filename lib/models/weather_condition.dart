enum WeatherCondition {
  clearSky,
  rainy,
  snowy,
  foggy,
  cloudy,
  stormy,
}

extension WeatherConditionExtension on WeatherCondition {
  bool get isSevere => this == WeatherCondition.stormy;

  String get label {
    switch (this) {
      case WeatherCondition.clearSky:
        return 'Clear Sky';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.foggy:
        return 'Foggy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.stormy:
        return 'Stormy';
    }
  }
}

WeatherCondition weatherCodeToCondition(int code) {
  if (code == 0) return WeatherCondition.clearSky;
  if (code <= 3) return WeatherCondition.cloudy;
  if (code <= 48) return WeatherCondition.foggy;
  if (code <= 57) return WeatherCondition.rainy;
  if (code <= 67) return WeatherCondition.stormy;
  if (code <= 77) return WeatherCondition.snowy;
  if (code <= 82) return WeatherCondition.rainy;
  if (code <= 86) return WeatherCondition.snowy;
  return WeatherCondition.stormy;
}
