import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/proxy_weather.dart';
import '../models/weather_condition.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import '../models/wind_data.dart';
import '../models/uv_index.dart';
import '../models/air_quality.dart';
import 'crypto_service.dart';
import 'database_service.dart';
import 'device_service.dart';
import 'proxy_config.dart';
import 'weather_service.dart';
import 'widget_service.dart';

const String _backgroundTaskName = 'com.kalo.mobile.weather_refresh';
const String _defaultProxyUrl = 'https://kalo-vercel.vercel.app';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await BackgroundService._execute();
      return true;
    } catch (e) {
      return false;
    }
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> schedulePeriodicRefresh() async {
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      'weatherRefresh',
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      initialDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_backgroundTaskName);
  }

  static Future<void> _execute() async {
    await dotenv.load(fileName: '.env');
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService(prefs);
    final deviceService = DeviceService();
    final unitPref = prefs.getString('unit_preference') ?? 'Celsius';
    final notificationPlugin = FlutterLocalNotificationsPlugin();

    await _initNotificationPlugin(notificationPlugin);

    final position = await _getPosition(db);
    if (position == null) return;

    final weather = await _fetchWeather(deviceService, db, position.$1, position.$2);
    if (weather == null) return;

    await _updateWidgets(weather, unitPref);
    await _showNowBar(notificationPlugin, weather, unitPref);
  }

  static Future<void> _initNotificationPlugin(FlutterLocalNotificationsPlugin plugin) async {
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await plugin.initialize(settings: initSettings);

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'weather_now_bar',
          'Now Bar',
          description: 'Weather info on lock screen Now Bar',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }
  }

  static Future<(double, double)?> _getPosition(DatabaseService db) async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) return (pos.latitude, pos.longitude);
      }
    } catch (_) {}

    try {
      final locations = await db.getAllLocations();
      if (locations.isNotEmpty) {
        return (locations.first.latitude, locations.first.longitude);
      }
    } catch (_) {}

    return null;
  }

  static Future<WeatherData?> _fetchWeather(
    DeviceService deviceService,
    DatabaseService db,
    double lat,
    double lon,
  ) async {
    final result = await _fetchProxy(deviceService, db, lat, lon);
    if (result != null) return _proxyToWeatherData(result);

    final fallback = await _fetchDirect(deviceService, db, lat, lon);
    if (fallback != null) return _proxyToWeatherData(fallback);

    return null;
  }

  static Future<ProxyWeatherResponse?> _fetchProxy(
    DeviceService deviceService,
    DatabaseService db,
    double lat,
    double lon,
  ) async {
    final secret = ProxyConfig.clientSecret;
    if (secret == null || secret.isEmpty || secret == 'changeme_to_your_real_secret') return null;

    final baseUrl = await _getProxyBaseUrl();
    final headers = <String, String>{
      'Authorization': 'Bearer $secret',
      'X-Client-Version': ProxyConfig.clientVersion,
    };

    final decryptionSecret = dotenv.env['KALO_DECRYPTION_SECRET'];
    if (decryptionSecret != null && decryptionSecret.isNotEmpty) {
      try {
        final fingerprint = await deviceService.getHardwareFingerprint();
        final weatherKey = await db.getApiKey('openweathermap');
        if (weatherKey != null) {
          final raw = decryptLocalKey(weatherKey.encryptedValue, fingerprint);
          headers['X-Encrypted-Weather-Key'] = encryptForProxy(raw, decryptionSecret);
        }

        final aqiKey = await db.getApiKey('waqi');
        if (aqiKey != null) {
          final raw = decryptLocalKey(aqiKey.encryptedValue, fingerprint);
          headers['X-Encrypted-Aqi-Key'] = encryptForProxy(raw, decryptionSecret);
        }
      } catch (_) {}
    }

    try {
      final uri = Uri.parse('$baseUrl/api/weather').replace(queryParameters: {
        'lat': lat.toStringAsFixed(4),
        'lon': lon.toStringAsFixed(4),
        'units': 'metric',
      });
      final res = await http.get(uri, headers: headers);
      if (res.statusCode != 200) return null;
      return ProxyWeatherResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<String> _getProxyBaseUrl() async {
    const storage = FlutterSecureStorage();
    try {
      final stored = await storage.read(key: 'kalo_proxy_base_url');
      if (stored != null && stored.isNotEmpty) return stored;
    } catch (_) {}
    return dotenv.env['KALO_PROXY_BASE_URL'] ?? _defaultProxyUrl;
  }

  static Future<ProxyWeatherResponse?> _fetchDirect(
    DeviceService deviceService,
    DatabaseService db,
    double lat,
    double lon,
  ) async {
    String fingerprint;
    try {
      fingerprint = await deviceService.getHardwareFingerprint();
    } catch (_) {
      return null;
    }

    final weatherKey = await db.getApiKey('openweathermap');
    if (weatherKey == null) return null;

    String apiKey;
    try {
      apiKey = decryptLocalKey(weatherKey.encryptedValue, fingerprint);
    } catch (_) {
      return null;
    }

    try {
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
        forecast: _buildDirectForecast(
          forecastRes.statusCode == 200 ? jsonDecode(forecastRes.body) as Map<String, dynamic> : null,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static String _owmIconToIllustration(String icon) {
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

  static String _uvLevel(double index) {
    if (index <= 2) return 'Low';
    if (index <= 5) return 'Moderate';
    if (index <= 7) return 'High';
    if (index <= 10) return 'Very High';
    return 'Extreme';
  }

  static String _uvMessage(double index) {
    if (index <= 2) return 'Safe to spend time outdoors.';
    if (index <= 5) return 'Seek shade during midday hours.';
    if (index <= 7) return 'Protection required.';
    if (index <= 10) return 'Extra protection needed.';
    return 'Avoid being outdoors.';
  }

  static String _aqiLevel(int aqi) {
    if (aqi <= 0) return 'N/A';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static String _aqiMessage(int aqi) {
    if (aqi <= 0) return 'AQI data unavailable';
    if (aqi <= 50) return 'Air quality is satisfactory.';
    if (aqi <= 100) return 'Air quality is acceptable.';
    if (aqi <= 150) return 'Sensitive groups should limit outdoor activity.';
    if (aqi <= 200) return 'Everyone should limit outdoor activity.';
    return 'Health alert.';
  }

  static double? _calculateDewPoint(double temp, double humidity) {
    const a = 17.27;
    const b = 237.7;
    final alpha = (a * temp) / (b + temp) + log(humidity / 100.0);
    return (b * alpha) / (a - alpha);
  }

  static String _humidityMessage(double humidity) {
    if (humidity < 30) return 'Dry / Comfortable';
    if (humidity <= 60) return 'Comfortable';
    if (humidity <= 70) return 'Slightly Humid';
    return 'Sticky / Humid';
  }

  static ProxyForecast _buildDirectForecast(Map<String, dynamic>? forecastJson) {
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
        final weatherItem = weatherList.first as Map<String, dynamic>;
        final condition = weatherItem['description'] as String;
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

  static WeatherData _proxyToWeatherData(ProxyWeatherResponse proxy) {
    final condition = _conditionStringToEnum(proxy.current.illustrationCode);
    final forecast = proxy.forecast.hourly.map((h) => HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(h.time * 1000),
      temperature: h.temp,
      weatherCode: _labelToWmoCode(h.condition),
    )).toList();

    final daily = proxy.forecast.daily.map((d) => DailyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(d.time * 1000),
      min: d.min,
      max: d.max,
      weatherCode: _labelToWmoCode(d.condition),
    )).toList();

    return WeatherData(
      temperature: proxy.current.temp,
      apparentTemperature: proxy.current.feelsLike,
      weatherCode: 0,
      condition: condition,
      humidity: proxy.humidity.value,
      pressure: 1013,
      wind: WindData(speed: proxy.wind.speed, direction: proxy.wind.deg, gust: proxy.wind.gust),
      uvIndex: UVIndex.fromDouble(proxy.uv.index),
      aqi: AirQuality(index: proxy.aqi.value, dominantPollutant: 'PM2.5'),
      hourlyForecast: forecast,
      dailyForecast: daily,
    );
  }

  static WeatherCondition _conditionStringToEnum(String code) {
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

  static int _labelToWmoCode(String label) {
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

  static Future<void> _updateWidgets(WeatherData weather, String unitPref) async {
    try {
      WidgetService.updateWeatherWidget(
        temperatureCelsius: weather.temperature,
        feelsLikeCelsius: weather.apparentTemperature,
        condition: weather.condition,
        locationName: 'My Location',
        unitPref: unitPref,
        hourlyForecast: weather.hourlyForecast,
        dailyForecast: weather.dailyForecast,
        humidity: weather.humidity,
        windSpeed: weather.wind.speed,
        uvIndex: weather.uvIndex.value,
        aqi: weather.aqi.index.toInt(),
      );
    } catch (_) {}
  }

  static Future<void> _showNowBar(FlutterLocalNotificationsPlugin plugin, WeatherData weather, String unitPref) async {
    final prefs = await SharedPreferences.getInstance();
    final nowBarEnabled = prefs.getBool('nowBarEnabled') ?? false;
    if (!nowBarEnabled) return;

    final temp = convertTemp(weather.temperature, unitPref);
    final label = tempUnit(unitPref);

    const androidDetails = AndroidNotificationDetails(
      'weather_now_bar',
      'Now Bar',
      channelDescription: 'Weather info on lock screen Now Bar',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: false,
      color: Color(0xFFFF6B35),
      icon: '@drawable/ic_notification',
      category: AndroidNotificationCategory.status,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await plugin.show(
      id: 9999,
      title: '$temp°$label ${weather.condition.emoji}',
      body: 'My Location — ${weather.condition.label}',
      notificationDetails: details,
    );
  }
}
