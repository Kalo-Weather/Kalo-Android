import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/air_quality.dart';
import 'proxy_service.dart';

final aqiProvider = FutureProvider<AirQuality?>((ref) async {
  final proxy = await ref.watch(currentProxyWeatherProvider.future);
  if (proxy == null) return null;
  return AirQuality(
    index: proxy.aqi.value,
    dominantPollutant: 'PM2.5',
  );
});
