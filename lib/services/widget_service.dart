import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../models/weather_condition.dart';
import '../models/widget_config.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import 'weather_service.dart';

const _kAndroidProviders = [
  'com.kalo.mobile.KaloWidgetSmallProvider',
  'com.kalo.mobile.KaloWidgetMediumProvider',
  'com.kalo.mobile.KaloWidgetLargeProvider',
];

class WidgetKeys {
  static const temp = 'widget_temp';
  static const feelsLike = 'widget_feels_like';
  static const condition = 'widget_condition';
  static const conditionEmoji = 'widget_condition_emoji';
  static const location = 'widget_location';
  static const unit = 'widget_unit';
  static const hourlyJson = 'widget_hourly_json';
  static const dailyJson = 'widget_daily_json';
  static const lastUpdated = 'widget_last_updated';
  static const isDay = 'widget_is_day';
  static const configJson = 'widget_config_json';
  static const humidity = 'widget_humidity';
  static const wind = 'widget_wind';
  static const uv = 'widget_uv';
  static const aqi = 'widget_aqi';
}

final widgetRefreshEnabledProvider = StateProvider<bool>((ref) => true);
final nowBarEnabledProvider = StateProvider<bool>((ref) => false);

class WidgetService {
  static Future<void> updateWeatherWidget({
    required double temperatureCelsius,
    required double feelsLikeCelsius,
    required WeatherCondition condition,
    required String locationName,
    required String unitPref,
    required List<HourlyForecast> hourlyForecast,
    required List<DailyForecast> dailyForecast,
    double? humidity,
    double? windSpeed,
    double? uvIndex,
    int? aqi,
  }) async {
    final unit = unitPref == 'Fahrenheit' ? 'F' : 'C';
    final tempStr = '${convertTemp(temperatureCelsius, unitPref).toStringAsFixed(0)}°$unit';
    final feelsStr = '${convertTemp(feelsLikeCelsius, unitPref).toStringAsFixed(0)}°$unit';
    final emoji = _conditionEnumToEmoji(condition);
    final isDay = true;

    final now = DateTime.now();
    final limitedHourly = hourlyForecast.take(5).toList();
    final humidityStr = humidity != null ? '${humidity.toStringAsFixed(0)}%' : null;

    try {
      await Future.wait([
        HomeWidget.saveWidgetData(WidgetKeys.temp, tempStr),
        HomeWidget.saveWidgetData(WidgetKeys.feelsLike, feelsStr),
        HomeWidget.saveWidgetData(WidgetKeys.condition, condition.label),
        HomeWidget.saveWidgetData(WidgetKeys.conditionEmoji, emoji),
        HomeWidget.saveWidgetData(WidgetKeys.location, locationName),
        HomeWidget.saveWidgetData(WidgetKeys.unit, unit),
        HomeWidget.saveWidgetData(
          WidgetKeys.hourlyJson,
          jsonEncode(limitedHourly.map((h) => {
            'time': h.time.millisecondsSinceEpoch ~/ 1000,
            'temp': h.temperature,
            'code': h.weatherCode,
          }).toList()),
        ),
        HomeWidget.saveWidgetData(
          WidgetKeys.dailyJson,
          jsonEncode(dailyForecast.take(4).map((d) => {
            'day': d.time.weekday,
            'min': d.min,
            'max': d.max,
            'code': d.weatherCode,
          }).toList()),
        ),
        HomeWidget.saveWidgetData(WidgetKeys.lastUpdated, now.toIso8601String()),
        HomeWidget.saveWidgetData(WidgetKeys.isDay, isDay.toString()),
        if (humidityStr != null) HomeWidget.saveWidgetData(WidgetKeys.humidity, humidityStr),
        if (windSpeed != null) HomeWidget.saveWidgetData(WidgetKeys.wind, '${windSpeed.toStringAsFixed(0)} mph'),
        if (uvIndex != null) HomeWidget.saveWidgetData(WidgetKeys.uv, uvIndex.toStringAsFixed(1)),
        if (aqi != null) HomeWidget.saveWidgetData(WidgetKeys.aqi, aqi.toString()),
      ]);

      await _updateWidgets();
    } catch (e) {
      debugPrint('WidgetService: failed to update widget data: $e');
    }
  }

  static Future<void> _updateWidgets() async {
    for (final provider in _kAndroidProviders) {
      try {
        await HomeWidget.updateWidget(
          androidName: provider.split('.').last,
          qualifiedAndroidName: provider,
        );
      } catch (e) {
        debugPrint('WidgetService: failed to update $provider: $e');
      }
    }
  }

  @pragma("vm:entry-point")
  static Future<void> widgetCallback(Uri? uri) async {
    if (uri == null) return;
    if (uri.host == 'refresh') {
      final temp = await HomeWidget.getWidgetData<String>(WidgetKeys.temp);
      if (temp != null) {
        await _updateWidgets();
      }
    }
  }

  static Future<void> saveWidgetConfig(WidgetConfig config) async {
    try {
      await HomeWidget.saveWidgetData(WidgetKeys.configJson, jsonEncode(config.toJson()));
      await _updateWidgets();
    } catch (e) {
      debugPrint('WidgetService: failed to save widget config: $e');
    }
  }

  static String _conditionEnumToEmoji(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.clearSky:
        return '\u2600\uFE0F';
      case WeatherCondition.cloudy:
        return '\u2601\uFE0F';
      case WeatherCondition.rainy:
        return '\uD83C\uDF27\uFE0F';
      case WeatherCondition.stormy:
        return '\u26C8\uFE0F';
      case WeatherCondition.snowy:
        return '\u2744\uFE0F';
      case WeatherCondition.foggy:
        return '\uD83C\uDF2B\uFE0F';
    }
  }
}
