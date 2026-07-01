import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/proxy_weather.dart';
import 'proxy_config.dart';
import 'location_service.dart';
import 'database_service.dart';
import 'device_service.dart';
import 'crypto_service.dart';

final isFallbackProvider = StateProvider<bool>((ref) => false);

final proxyWeatherProvider = FutureProvider.family<ProxyWeatherResponse?, String>((ref, locationKey) async {
  final locations = await ref.watch(allLocationsProvider.future);
  final baseUrl = ref.watch(proxyBaseUrlProvider);
  final loc = locations.isNotEmpty
      ? locations.firstWhere(
          (l) => '${l.latitude},${l.longitude}' == locationKey,
          orElse: () => locations.first,
        )
      : null;
  if (loc == null) return null;
  return _fetchWithFallback(ref, baseUrl, loc.latitude, loc.longitude);
});

final currentProxyWeatherProvider = FutureProvider<ProxyWeatherResponse?>((ref) async {
  final baseUrl = ref.watch(proxyBaseUrlProvider);
  var lat = 0.0;
  var lon = 0.0;
  var hasCoords = false;

  final pos = await ref.watch(currentPositionProvider.future);
  if (pos != null) {
    lat = pos.latitude;
    lon = pos.longitude;
    hasCoords = true;
  } else {
    final locations = await ref.watch(allLocationsProvider.future);
    if (locations.isNotEmpty) {
      lat = locations.first.latitude;
      lon = locations.first.longitude;
      hasCoords = true;
    }
  }

  if (!hasCoords) return null;
  return _fetchWithFallback(ref, baseUrl, lat, lon);
});

Future<ProxyWeatherResponse?> _fetchWithFallback(Ref ref, String baseUrl, double lat, double lon) async {
  final result = await _fetchProxy(ref, baseUrl, lat, lon);
  if (result != null) {
    ref.read(isFallbackProvider.notifier).state = false;
    return result;
  }
  final fallback = await _fetchDirect(ref, lat, lon);
  if (fallback != null) {
    ref.read(isFallbackProvider.notifier).state = true;
  }
  return fallback;
}

Future<ProxyWeatherResponse?> _fetchProxy(Ref ref, String baseUrl, double lat, double lon) async {
  final secret = ProxyConfig.clientSecret;
  if (secret == null || secret.isEmpty || secret == 'changeme_to_your_real_secret') return null;

  final headers = <String, String>{
    'Authorization': 'Bearer $secret',
    'X-Client-Version': ProxyConfig.clientVersion,
  };

  final decryptionSecret = dotenv.env['KALO_DECRYPTION_SECRET'];
  if (decryptionSecret != null && decryptionSecret.isNotEmpty) {
    final db = ref.read(databaseServiceProvider);
    final deviceService = ref.read(deviceServiceProvider);
    final fingerprint = await deviceService.getHardwareFingerprint();

    final weatherKey = await db.getApiKey('openweathermap');
    if (weatherKey != null) {
      try {
        final raw = decryptLocalKey(weatherKey.encryptedValue, fingerprint);
        headers['X-Encrypted-Weather-Key'] = encryptForProxy(raw, decryptionSecret);
      } catch (_) {}
    }

    final aqiKey = await db.getApiKey('waqi');
    if (aqiKey != null) {
      try {
        final raw = decryptLocalKey(aqiKey.encryptedValue, fingerprint);
        headers['X-Encrypted-Aqi-Key'] = encryptForProxy(raw, decryptionSecret);
      } catch (_) {}
    }
  }

  final uri = Uri.parse('$baseUrl/api/weather').replace(queryParameters: {
    'lat': lat.toStringAsFixed(4),
    'lon': lon.toStringAsFixed(4),
    'units': 'metric',
  });
  final res = await http.get(uri, headers: headers);
  if (res.statusCode != 200) return null;
  return ProxyWeatherResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
}

Future<ProxyWeatherResponse?> _fetchDirect(Ref ref, double lat, double lon) async {
  final db = ref.read(databaseServiceProvider);
  final deviceService = ref.read(deviceServiceProvider);
  final fingerprint = await deviceService.getHardwareFingerprint();

  final weatherKey = await db.getApiKey('openweathermap');
  if (weatherKey == null) return null;

  String apiKey;
  try {
    apiKey = decryptLocalKey(weatherKey.encryptedValue, fingerprint);
  } catch (_) {
    return null;
  }

  final currentUri = Uri.parse('https://api.openweathermap.org/data/2.5/weather').replace(queryParameters: {
    'lat': lat.toStringAsFixed(4),
    'lon': lon.toStringAsFixed(4),
    'units': 'metric',
    'appid': apiKey,
  });
  final currentRes = await http.get(currentUri);
  if (currentRes.statusCode != 200) return null;
  final currentJson = jsonDecode(currentRes.body) as Map<String, dynamic>;
  final main = currentJson['main'] as Map<String, dynamic>;
  final weatherList = currentJson['weather'] as List<dynamic>;
  final weather = weatherList.first as Map<String, dynamic>;
  final windJson = currentJson['wind'] as Map<String, dynamic>;

  final forecastUri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast').replace(queryParameters: {
    'lat': lat.toStringAsFixed(4),
    'lon': lon.toStringAsFixed(4),
    'units': 'metric',
    'appid': apiKey,
  });
  final forecastRes = await http.get(forecastUri);

  double uvIndex = 0;
  try {
    final uvUri = Uri.parse('https://api.open-meteo.com/v1/forecast').replace(queryParameters: {
      'latitude': lat.toStringAsFixed(4),
      'longitude': lon.toStringAsFixed(4),
      'daily': 'uv_index_max',
      'timezone': 'auto',
    });
    final uvRes = await http.get(uvUri);
    if (uvRes.statusCode == 200) {
      final uvJson = jsonDecode(uvRes.body) as Map<String, dynamic>;
      final daily = uvJson['daily'] as Map<String, dynamic>;
      final values = daily['uv_index_max'] as List<dynamic>;
      if (values.isNotEmpty) uvIndex = (values.first as num).toDouble();
    }
  } catch (_) {}

  int aqiValue = 0;
  final aqiKeyData = await db.getApiKey('waqi');
  if (aqiKeyData != null) {
    try {
      final rawAqi = decryptLocalKey(aqiKeyData.encryptedValue, fingerprint);
      final aqiUri = Uri.parse('https://api.waqi.info/feed/geo:$lat;$lon/').replace(queryParameters: {
        'token': rawAqi,
      });
      final aqiRes = await http.get(aqiUri);
      if (aqiRes.statusCode == 200) {
        final aqiJson = jsonDecode(aqiRes.body) as Map<String, dynamic>;
        if (aqiJson['status'] == 'ok') {
          final data = aqiJson['data'] as Map<String, dynamic>;
          final aqi = data['aqi'];
          if (aqi != null) aqiValue = (aqi as num).toInt();
        }
      }
    } catch (_) {}
  }

  final condition = weather['main'] as String;
  final icon = weather['icon'] as String;
  final dt = currentJson['dt'] as int;

  return ProxyWeatherResponse(
    meta: ProxyMeta(serverVersion: 'direct', clientCompatibilityMin: '1.0.0', engine: 'Direct API Fallback'),
    coordinates: ProxyCoordinates(lat: lat, lon: lon),
    current: ProxyCurrent(
      temp: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: condition,
      illustrationCode: _owmIconToIllustration(icon),
      timestamp: dt,
    ),
    uv: ProxyUV(index: uvIndex, level: _uvLevel(uvIndex), msg: _uvMessage(uvIndex)),
    aqi: ProxyAQI(value: aqiValue.toDouble(), level: _aqiLevel(aqiValue), msg: _aqiMessage(aqiValue)),
    wind: ProxyWind(
      speed: (windJson['speed'] as num).toDouble(),
      deg: (windJson['deg'] as num?)?.toDouble() ?? 0,
      gust: (windJson['gust'] as num?)?.toDouble(),
    ),
    humidity: ProxyHumidity(
      value: (main['humidity'] as num).toDouble(),
      dewPoint: _calculateDewPoint((main['temp'] as num).toDouble(), (main['humidity'] as num).toDouble()),
      msg: _humidityMessage((main['humidity'] as num).toDouble()),
    ),
    forecast: _buildDirectForecast(forecastRes.statusCode == 200 ? jsonDecode(forecastRes.body) as Map<String, dynamic> : null),
  );
}

String _owmIconToIllustration(String icon) {
  final code = icon.substring(0, 2);
  switch (code) {
    case '01': return 'sun';
    case '02': return 'cloud-sun';
    case '03': return 'cloud';
    case '04': return 'overcast';
    case '09': return 'rain';
    case '10': return 'rain';
    case '11': return 'storm';
    case '13': return 'snow';
    case '50': return 'fog';
    default: return 'cloud';
  }
}

String _uvLevel(double index) {
  if (index <= 2) return 'Low';
  if (index <= 5) return 'Moderate';
  if (index <= 7) return 'High';
  if (index <= 10) return 'Very High';
  return 'Extreme';
}

String _uvMessage(double index) {
  if (index <= 2) return 'Safe to spend time outdoors.';
  if (index <= 5) return 'Seek shade during midday hours.';
  if (index <= 7) return 'Protection required.';
  if (index <= 10) return 'Extra protection needed.';
  return 'Avoid being outdoors.';
}

String _aqiLevel(int aqi) {
  if (aqi <= 0) return 'N/A';
  if (aqi <= 50) return 'Good';
  if (aqi <= 100) return 'Moderate';
  if (aqi <= 150) return 'Unhealthy for Sensitive';
  if (aqi <= 200) return 'Unhealthy';
  if (aqi <= 300) return 'Very Unhealthy';
  return 'Hazardous';
}

String _aqiMessage(int aqi) {
  if (aqi <= 0) return 'AQI data unavailable';
  if (aqi <= 50) return 'Air quality is satisfactory.';
  if (aqi <= 100) return 'Air quality is acceptable.';
  if (aqi <= 150) return 'Sensitive groups should limit outdoor activity.';
  if (aqi <= 200) return 'Everyone should limit outdoor activity.';
  return 'Health alert.';
}

double? _calculateDewPoint(double temp, double humidity) {
  const a = 17.27;
  const b = 237.7;
  final alpha = (a * temp) / (b + temp) + log(humidity / 100.0);
  return (b * alpha) / (a - alpha);
}

String _humidityMessage(double humidity) {
  if (humidity < 30) return 'Dry / Comfortable';
  if (humidity <= 60) return 'Comfortable';
  if (humidity <= 70) return 'Slightly Humid';
  return 'Sticky / Humid';
}

ProxyForecast _buildDirectForecast(Map<String, dynamic>? forecastJson) {
  final hourly = <ProxyHourly>[];
  final daily = <ProxyDaily>[];

  if (forecastJson != null) {
    final list = forecastJson['list'] as List<dynamic>;
    final seenDays = <String>{};
    for (final entry in list) {
      final item = entry as Map<String, dynamic>;
      final dt = item['dt'] as int;
      final main = item['main'] as Map<String, dynamic>;
      final temp = (main['temp'] as num).toDouble();
      final weatherList = item['weather'] as List<dynamic>;
      final weather = weatherList.first as Map<String, dynamic>;
      final condition = weather['description'] as String;

      hourly.add(ProxyHourly(time: dt, temp: temp, condition: condition));

      final date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
      final dayKey = '${date.year}-${date.month}-${date.day}';
      if (seenDays.add(dayKey)) {
        daily.add(ProxyDaily(time: dt, min: temp, max: temp, condition: condition));
      }
    }
  }

  return ProxyForecast(hourly: hourly, daily: daily);
}
