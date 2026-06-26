import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/database_service.dart';
import 'services/device_service.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/navigation_provider.dart';
import 'models/weather_condition.dart';
import 'weather_icons/weather_icons.dart';
import 'weather_icons/boxed_icon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  final dbService = await DatabaseService.init();

  final deviceService = DeviceService();
  await deviceService.ensureFingerprintEntropy();

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
        deviceServiceProvider.overrideWithValue(deviceService),
      ],
      child: const KaloWearApp(),
    ),
  );
}

class KaloWearApp extends StatelessWidget {
  const KaloWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalo Wear',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(primary: Colors.white),
      ),
      home: const WearDashboard(),
    );
  }
}

class WearDashboard extends ConsumerWidget {
  const WearDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final localityAsync = ref.watch(currentLocalityProvider);
    final unitPref = ref.watch(unitPreferenceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: weatherAsync.when(
          data: (weather) {
            if (weather == null) return _buildError();
            final locationName = localityAsync.asData?.value ?? 'Current Location';
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _timeString(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Icon(Icons.watch_later_outlined, color: Colors.white70, size: 14),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          locationName,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${convertTemp(weather.temperature, unitPref).toStringAsFixed(0)}°${tempUnit(unitPref)}',
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BoxedIcon(
                              _iconForCondition(weather.weatherCode),
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              weather.condition.label,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _WearInfoRow(
                    icon: Icons.wb_sunny_outlined,
                    label: 'UV',
                    value: '${weather.uvIndex.value.toStringAsFixed(0)} (${weather.uvIndex.label})',
                    color: Colors.yellow,
                  ),
                  const SizedBox(height: 8),
                  _WearInfoRow(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${weather.wind.speed.toStringAsFixed(0)} mph ${weather.wind.directionLabel}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _WearInfoRow(
                    icon: Icons.water_drop_outlined,
                    label: 'Humid',
                    value: '${weather.humidity.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _WearInfoRow(
                    icon: Icons.radar,
                    label: 'AQI',
                    value: '${weather.aqi.index.toStringAsFixed(0)} (${weather.aqi.label})',
                    color: Colors.green,
                  ),
                ],
              ),
            );
          },
          error: (_, __) => _buildError(),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white30, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Unable to load weather',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _timeString() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _iconForCondition(int code) {
    if (code == 0) return WeatherIcons.day_sunny;
    if (code <= 48) return WeatherIcons.cloudy;
    if (code <= 67) return WeatherIcons.rain;
    if (code <= 77) return WeatherIcons.snow;
    if (code <= 86) return WeatherIcons.showers;
    return WeatherIcons.thunderstorm;
  }
}

class _WearInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WearInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
