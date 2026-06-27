class DailyForecast {
  final DateTime time;
  final double min;
  final double max;
  final int weatherCode;

  DailyForecast({
    required this.time,
    required this.min,
    required this.max,
    required this.weatherCode,
  });
}
