import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hourly_forecast.dart';
import '../models/weather_condition.dart';
import '../models/uv_index.dart';
import '../models/wind_data.dart';
import '../models/air_quality.dart';
import '../models/proxy_weather.dart';
import 'proxy_service.dart';

class WeatherData {
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final WeatherCondition condition;
  final double humidity;
  final double pressure;
  final WindData wind;
  final UVIndex uvIndex;
  final AirQuality aqi;
  final List<HourlyForecast> hourlyForecast;

  WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.condition,
    required this.humidity,
    required this.pressure,
    required this.wind,
    required this.uvIndex,
    required this.aqi,
    required this.hourlyForecast,
  });
}

final weatherDataProvider = FutureProvider.family<WeatherData?, String>((ref, locationKey) async {
  final proxy = await ref.watch(proxyWeatherProvider(locationKey).future);
  if (proxy == null) return null;
  return _proxyToWeatherData(proxy);
});

final currentWeatherProvider = FutureProvider<WeatherData?>((ref) async {
  final proxy = await ref.watch(currentProxyWeatherProvider.future);
  if (proxy == null) return null;
  return _proxyToWeatherData(proxy);
});

WeatherData _proxyToWeatherData(ProxyWeatherResponse proxy) {
  final condition = _conditionStringToEnum(proxy.current.illustrationCode);
  final weatherCode = _conditionToWmoCode(proxy.current.illustrationCode);
  final forecast = proxy.forecast.hourly.map((h) => HourlyForecast(
    time: DateTime.fromMillisecondsSinceEpoch(h.time * 1000),
    temperature: h.temp,
    weatherCode: _labelToWmoCode(h.condition),
  )).toList();

  return WeatherData(
    temperature: proxy.current.temp,
    apparentTemperature: proxy.current.feelsLike,
    weatherCode: weatherCode,
    condition: condition,
    humidity: proxy.humidity.value,
    pressure: 1013,
    wind: WindData(
      speed: proxy.wind.speed,
      direction: proxy.wind.deg,
      gust: proxy.wind.gust,
    ),
    uvIndex: UVIndex.fromDouble(proxy.uv.index),
    aqi: AirQuality(
      index: proxy.aqi.value,
      dominantPollutant: 'PM2.5',
    ),
    hourlyForecast: forecast,
  );
}

double convertTemp(double celsius, String unitPref) {
  return unitPref == 'Fahrenheit' ? celsius * 9 / 5 + 32 : celsius;
}

String tempUnit(String unitPref) {
  return unitPref == 'Fahrenheit' ? 'F' : 'C';
}

WeatherCondition _conditionStringToEnum(String code) {
  switch (code) {
    case 'sun':
    case 'clear-day':
      return WeatherCondition.clearSky;
    case 'cloud-sun':
    case 'partly-cloudy':
    case 'cloud':
    case 'overcast':
      return WeatherCondition.cloudy;
    case 'rain':
    case 'drizzle':
      return WeatherCondition.rainy;
    case 'storm':
    case 'thunder':
      return WeatherCondition.stormy;
    case 'snow':
      return WeatherCondition.snowy;
    case 'fog':
      return WeatherCondition.foggy;
    default:
      return WeatherCondition.cloudy;
  }
}

int _conditionToWmoCode(String code) {
  switch (code) {
    case 'sun':
    case 'clear-day':
      return 0;
    case 'cloud-sun':
    case 'partly-cloudy':
      return 2;
    case 'cloud':
    case 'overcast':
      return 3;
    case 'fog':
      return 45;
    case 'drizzle':
      return 51;
    case 'rain':
      return 61;
    case 'storm':
    case 'thunder':
      return 95;
    case 'snow':
      return 71;
    default:
      return 3;
  }
}

int _labelToWmoCode(String label) {
  final l = label.toLowerCase();
  if (l.contains('sun') || l.contains('clear')) return 0;
  if (l.contains('partly') || l.contains('cloud-sun')) return 2;
  if (l.contains('cloud') || l.contains('overcast')) return 3;
  if (l.contains('fog') || l.contains('mist')) return 45;
  if (l.contains('drizzle')) return 51;
  if (l.contains('rain') || l.contains('shower')) return 61;
  if (l.contains('storm') || l.contains('thunder')) return 95;
  if (l.contains('snow') || l.contains('sleet')) return 71;
  return 3;
}
