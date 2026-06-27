import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/weather_service.dart';
import '../../services/radar_service.dart';
import '../../services/location_service.dart';
import '../../services/navigation_provider.dart';
import '../../services/database_service.dart';
import '../../services/proxy_service.dart';
import '../../services/animated_background_provider.dart';
import '../../services/weather_alert_service.dart';
import '../../services/notification_service.dart';
import '../../models/weather_location.dart';
import '../../models/weather_condition.dart';
import '../widgets/weather_card.dart';
import '../widgets/uvi_card.dart';
import '../widgets/aqi_card.dart';
import '../widgets/wind_card.dart';
import '../widgets/humidity_card.dart';
import '../widgets/radar_card.dart';
import '../radar/radar_screen.dart';
import '../settings/settings_screen.dart';
import '../../weather_icons/weather_icons.dart';
import '../../weather_icons/boxed_icon.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:weather_animation/weather_animation.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentLocationIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paradigm = ref.watch(navigationParadigmProvider);
    final locationsAsync = ref.watch(allLocationsProvider);
    final localityAsync = ref.watch(currentLocalityProvider);

    return Scaffold(
      backgroundColor: KaloColors.amoledDark,
      body: locationsAsync.when(
        data: (locations) {
          final activeLocations = locations.isNotEmpty ? locations : null;
          final locationName = activeLocations != null && _currentLocationIndex < activeLocations.length
              ? activeLocations[_currentLocationIndex].name
              : localityAsync.asData?.value ?? 'Current Location';

          if (paradigm == NavigationParadigm.locationCarousel) {
            return _buildCarousel(locationName, activeLocations, locations);
          } else {
            return _buildStackView(locationName, activeLocations, locations);
          }
        },
        error: (e, _) => _buildError(e),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildCarousel(String locationName, List<WeatherLocation>? activeLocations, List<WeatherLocation> allLocations) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (activeLocations == null || activeLocations.length <= 1) return;
        if (details.primaryVelocity! < 0 && _currentLocationIndex < activeLocations.length - 1) {
          setState(() => _currentLocationIndex++);
        } else if (details.primaryVelocity! > 0 && _currentLocationIndex > 0) {
          setState(() => _currentLocationIndex--);
        }
      },
      child: _buildDashboard(locationName, activeLocations, allLocations),
    );
  }

  Widget _buildStackView(String locationName, List<WeatherLocation>? activeLocations, List<WeatherLocation> allLocations) {
    return _buildDashboard(locationName, activeLocations, allLocations);
  }

  Widget _buildDashboard(String locationName, List<WeatherLocation>? activeLocations, List<WeatherLocation> allLocations) {
    final hasLocations = activeLocations != null && _currentLocationIndex < activeLocations.length;
    final weatherAsync = hasLocations
        ? ref.watch(weatherDataProvider('${activeLocations[_currentLocationIndex].latitude},${activeLocations[_currentLocationIndex].longitude}'))
        : ref.watch(currentWeatherProvider);
    final radarAsync = ref.watch(radarFrameProvider);
    final isFallback = ref.watch(isFallbackProvider);
    final unitPref = ref.watch(unitPreferenceProvider);

    final weather = weatherAsync.valueOrNull;
    final alerts = ref.watch(weatherAlertsProvider).valueOrNull ?? [];

    ref.listen(weatherAlertsProvider, (_, next) {
      final currentAlerts = next.valueOrNull ?? [];
      final notif = ref.read(notificationServiceProvider);
      for (final alert in currentAlerts) {
        final alertId = alert.event.hashCode ^ alert.headline.hashCode;
        if (!notif.hasNotified(alertId)) {
          notif.showWeatherAlert(
            id: alertId,
            title: alert.event,
            body: alert.headline.isNotEmpty ? alert.headline : alert.event,
          );
          notif.markNotified(alertId);
        }
      }
    });

    final animatedBg = ref.watch(animatedBackgroundProvider);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: weather != null
                ? SkyGradients.forCondition(weather.condition.name, weather.weatherCode == 0)
                : SkyGradients.clearDay,
          ),
        ),
        TickerMode(
          enabled: animatedBg && weather != null,
          child: Opacity(
            opacity: animatedBg && weather != null ? 1 : 0,
            child: IgnorePointer(
              ignoring: !(animatedBg && weather != null),
              child: RepaintBoundary(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: WrapperScene.weather(
                      scene: weather != null
                          ? _sceneForCondition(weather.condition)
                          : WeatherScene.scorchingSun,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildLocationBar(locationName, allLocations),
              if (isFallback) _buildFallbackBanner(),
              if (alerts.isNotEmpty) _buildAlertBanner(alerts),
              Expanded(
                child: weatherAsync.when(
                  data: (weather) {
                    if (weather == null) return _buildError('Could not load weather');
                    return RawScrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            _buildHeroSection(weather, locationName, unitPref),
                            const SizedBox(height: 16),
                            _buildCardGrid(weather, radarAsync.asData?.value, unitPref),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  },
                  error: (e, _) => _buildError(e.toString()),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBar(String locationName, List<WeatherLocation> locations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showLocationPicker(locations),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: KaloColors.primaryText, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      locationName,
                      style: TextStyle(
                        color: KaloColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: KaloColors.primaryText, size: 20),
                ],
              ),
            ),
          ),
          if (locations.length > 1)
            Row(
              children: [
                _navButton(Icons.chevron_left, () {
                  if (_currentLocationIndex > 0) {
                    setState(() => _currentLocationIndex--);
                  }
                }),
                const SizedBox(width: 4),
                _navButton(Icons.chevron_right, () {
                  if (_currentLocationIndex < locations.length - 1) {
                    setState(() => _currentLocationIndex++);
                  }
                }),
              ],
            ),
          IconButton(
            icon: Icon(Icons.settings, color: KaloColors.primaryText, size: 20),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: KaloColors.frostWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: KaloColors.primaryText, size: 18),
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showLocationPicker(List<WeatherLocation> locations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: KaloColors.secondaryText, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Saved Locations', style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: locations.asMap().entries.map((e) => ListTile(
                leading: Icon(Icons.location_city, color: KaloColors.secondaryText, size: 20),
                title: Text(e.value.name, style: TextStyle(color: KaloColors.primaryText)),
                trailing: e.key == _currentLocationIndex ? const Icon(Icons.check, color: Colors.blue, size: 18) : null,
                onTap: () {
                  setState(() => _currentLocationIndex = e.key);
                  Navigator.pop(ctx);
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.add_location, color: Colors.blue, size: 20),
            title: const Text('Add Location', style: TextStyle(color: Colors.blue)),
            onTap: () {
              Navigator.pop(ctx);
              _addLocation();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _addLocation() async {
    final result = await showDialog<(String name, double lat, double lng, bool isCurrent)?>(
      context: context,
      builder: (_) => const _LocationSearchDialog(),
    );

    if (result == null) return;
    final (rName, rLat, rLng, rIsCurrent) = result;

    final ctx = context;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final service = ref.read(locationServiceProvider);
      late final double lat;
      late final double lng;
      late final String name;

      if (rIsCurrent) {
        final hasPermission = await service.requestPermission();
        if (!hasPermission) {
          if (mounted) Navigator.pop(context);
          _showLocationError('Location permission denied');
          return;
        }
        final position = await service.getCurrentLocation();
        if (position == null) {
          if (mounted) Navigator.pop(context);
          _showLocationError('Could not get current location');
          return;
        }
        lat = position.latitude;
        lng = position.longitude;
        final placemarks = await geo.placemarkFromCoordinates(lat, lng);
        name = placemarks.isNotEmpty
            ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? 'Current Location')
            : 'Current Location';
      } else {
        name = rName;
        lat = rLat;
        lng = rLng;
      }

      final db = ref.read(databaseServiceProvider);
      await db.addLocation(name, lat, lng);
      ref.invalidate(allLocationsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showLocationError('Error: $e');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  Widget _buildHeroSection(WeatherData weather, String locationName, String unitPref) {
    final isDay = weather.weatherCode == 0;
    final temp = convertTemp(weather.temperature, unitPref);
    final unit = tempUnit(unitPref);
    final hi = convertTemp(weather.temperature + 3, unitPref);
    final lo = convertTemp(weather.temperature - 4, unitPref);
    return Column(
      children: [
        BoxedIcon(
          _heroIcon(weather.condition, isDay),
          size: 100,
          color: KaloColors.primaryText,
        ),
        const SizedBox(height: 8),
        Text(
          '${temp.toStringAsFixed(0)}°$unit',
          style: TextStyle(
            color: KaloColors.primaryText,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weather.condition.label,
          style: TextStyle(
            color: KaloColors.primaryText,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'H: ${hi.toStringAsFixed(0)}°$unit  L: ${lo.toStringAsFixed(0)}°$unit',
          style: TextStyle(
            color: KaloColors.secondaryText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(WeatherData weather, String? radarFrame, String unitPref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: WeatherCard(
                    title: 'UV Index',
                    icon: Icons.wb_sunny_outlined,
                    content: UVICard(uvIndex: weather.uvIndex),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: cardWidth,
                  child: WeatherCard(
                    title: 'Air Quality',
                    icon: Icons.air_outlined,
                    content: AQICard(airQuality: weather.aqi),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: constraints.maxWidth,
              child: WeatherCard(
                title: 'Wind',
                icon: Icons.air,
                size: CardSize.wide,
                content: WindCompassCard(wind: weather.wind),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: WeatherCard(
                    title: 'Humidity',
                    icon: Icons.water_drop_outlined,
                    content: HumidityCard(
                      humidity: weather.humidity,
                      dewPoint: convertTemp(weather.temperature - ((100 - weather.humidity) / 5), unitPref),
                      dewPointUnit: tempUnit(unitPref),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: cardWidth,
                  child: WeatherCard(
                    title: 'Precipitation',
                    icon: Icons.radar,
                    content: RadarCard(
                      frameUrl: radarFrame,
                      onTap: () {
                        if (radarFrame != null) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => RadarScreen(frameUrl: radarFrame),
                          ));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHourlyForecast(weather, unitPref),
            const SizedBox(height: 12),
            _buildDailyForecast(weather, unitPref),
          ],
        );
      },
    );
  }

  Widget _buildHourlyForecast(WeatherData weather, String unitPref) {
    final forecasts = weather.hourlyForecast.take(8).toList();
    return FrostedGlass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hourly Forecast', style: TextStyle(color: KaloColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecasts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final f = forecasts[i];
                final hour = f.time.hour.toString().padLeft(2, '0');
                final temp = convertTemp(f.temperature, unitPref);
                return Column(
                  children: [
                    Text('$hour:00', style: TextStyle(color: KaloColors.secondaryText, fontSize: 11)),
                    const SizedBox(height: 6),
                    BoxedIcon(
                      _iconForCode(f.weatherCode),
                      color: KaloColors.primaryText,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${temp.toStringAsFixed(0)}°${tempUnit(unitPref)}',
                      style: TextStyle(color: KaloColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(WeatherData weather, String unitPref) {
    final days = weather.dailyForecast.take(7).toList();
    if (days.isEmpty) return const SizedBox.shrink();

    final globalMin = days.map((d) => d.min).reduce((a, b) => a < b ? a : b);
    final globalMax = days.map((d) => d.max).reduce((a, b) => a > b ? a : b);
    final range = (globalMax - globalMin).abs().clamp(1, double.infinity);

    return FrostedGlass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-Day Forecast', style: TextStyle(color: KaloColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...days.map((d) {
            final dayLabel = _dayAbbreviation(d.time.weekday);
            final low = convertTemp(d.min, unitPref);
            final high = convertTemp(d.max, unitPref);
            final lowPos = ((d.min - globalMin) / range);
            final highPos = ((d.max - globalMin) / range);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(dayLabel, style: TextStyle(color: KaloColors.secondaryText, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 22,
                    child: BoxedIcon(_iconForCode(d.weatherCode), color: KaloColors.primaryText, size: 16),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${low.toStringAsFixed(0)}°',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 6,
                        color: KaloColors.frostWhite,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: (highPos - lowPos).clamp(0.05, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A90D9), Color(0xFFFF6B35)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${high.toStringAsFixed(0)}°',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: KaloColors.primaryText, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _dayAbbreviation(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }

  IconData _iconForCode(int code) {
    if (code == 0) return WeatherIcons.day_sunny;
    if (code <= 48) return WeatherIcons.cloudy;
    if (code <= 67) return WeatherIcons.rain;
    if (code <= 77) return WeatherIcons.snow;
    if (code <= 86) return WeatherIcons.showers;
    return WeatherIcons.thunderstorm;
  }

  IconData _heroIcon(WeatherCondition condition, bool isDay) {
    switch (condition) {
      case WeatherCondition.clearSky:
        return isDay ? WeatherIcons.day_sunny : WeatherIcons.night_clear;
      case WeatherCondition.cloudy:
        return WeatherIcons.cloudy;
      case WeatherCondition.foggy:
        return WeatherIcons.fog;
      case WeatherCondition.rainy:
        return WeatherIcons.rain;
      case WeatherCondition.snowy:
        return WeatherIcons.snow;
      case WeatherCondition.stormy:
        return WeatherIcons.thunderstorm;
    }
  }

  WeatherScene _sceneForCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clearSky:
        return WeatherScene.scorchingSun;
      case WeatherCondition.cloudy:
      case WeatherCondition.foggy:
        return WeatherScene.rainyOvercast;
      case WeatherCondition.rainy:
        return WeatherScene.rainyOvercast;
      case WeatherCondition.snowy:
        return WeatherScene.snowfall;
      case WeatherCondition.stormy:
        return WeatherScene.stormy;
    }
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade900,
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Proxy unavailable — contact ngbcoder@gmail.com',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(List<WeatherAlert> alerts) {
    final sorted = List<WeatherAlert>.from(alerts)
      ..sort((a, b) => _severityWeight(b.severity).compareTo(_severityWeight(a.severity)));
    final top = sorted.first;
    final color = _severityColor(top.severity);

    return GestureDetector(
      onTap: () => _showAlertDetails(alerts),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: color.withValues(alpha: 0.85),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                top.headline.isNotEmpty ? top.headline : top.event,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (alerts.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${alerts.length - 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(List<WeatherAlert> alerts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: KaloColors.secondaryText, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Weather Alerts', style: TextStyle(color: KaloColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const Divider(color: Color(0x33FFFFFF)),
                itemBuilder: (_, i) {
                  final a = alerts[i];
                  final color = _severityColor(a.severity);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(a.severity, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(a.event, style: TextStyle(color: KaloColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (a.headline.isNotEmpty)
                        Text(a.headline, style: TextStyle(color: KaloColors.secondaryText, fontSize: 12)),
                      if (a.instruction != null && a.instruction!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Instruction: ${a.instruction}', style: TextStyle(color: Colors.orange.shade200, fontSize: 12)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme':
        return const Color(0xFF880000);
      case 'severe':
        return const Color(0xFFCC0000);
      case 'moderate':
        return Colors.orange.shade800;
      case 'minor':
        return Colors.amber.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  int _severityWeight(String severity) {
    switch (severity.toLowerCase()) {
      case 'extreme': return 5;
      case 'severe': return 4;
      case 'moderate': return 3;
      case 'minor': return 2;
      default: return 1;
    }
  }

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: KaloColors.secondaryText, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather',
              style: TextStyle(color: KaloColors.primaryText, fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (e.toString() == 'Could not load weather')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Contact ngbcoder@gmail.com for support',
                  style: TextStyle(color: Colors.orange.shade300, fontSize: 13),
                ),
              ),
            Text(
              e.toString(),
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchDialog extends StatefulWidget {
  const _LocationSearchDialog();

  @override
  State<_LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<_LocationSearchDialog> {
  final _controller = TextEditingController();
  final _results = <({String name, double lat, double lng})>[];
  Timer? _debounce;
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() { _results.clear(); _loading = false; _searched = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() { _loading = true; _searched = true; });
      try {
        final locations = await geo.locationFromAddress(query);
        final list = <({String name, double lat, double lng})>[];
        for (int i = 0; i < locations.length && i < 5; i++) {
          final loc = locations[i];
          try {
            final placemarks = await geo.placemarkFromCoordinates(loc.latitude, loc.longitude);
            final name = placemarks.isNotEmpty
                ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}')
                : '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}';
            list.add((name: name, lat: loc.latitude, lng: loc.longitude));
          } catch (_) {
            list.add((name: '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}', lat: loc.latitude, lng: loc.longitude));
          }
        }
        if (mounted) setState(() { _results..clear()..addAll(list); _loading = false; });
      } catch (_) {
        if (mounted) setState(() { _results.clear(); _loading = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Location', style: TextStyle(color: KaloColors.primaryText)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            onChanged: _search,
            autofocus: true,
            style: TextStyle(color: KaloColors.primaryText),
            decoration: InputDecoration(
              hintText: 'City name',
              hintStyle: TextStyle(color: KaloColors.secondaryText),
              filled: true,
              fillColor: KaloColors.frostWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: KaloColors.frostBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: KaloColors.frostBorder),
              ),
              suffixIcon: _loading
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: KaloColors.secondaryText)),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, (name: '', lat: 0, lng: 0, isCurrent: true)),
              icon: const Icon(Icons.gps_fixed, size: 18),
              label: const Text('Use Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: KaloColors.frostBorder),
                itemBuilder: (ctx, i) {
                  final item = _results[i];
                  return ListTile(
                    dense: true,
                    title: Text(item.name, style: TextStyle(color: KaloColors.primaryText, fontSize: 14)),
                    subtitle: Text('${item.lat.toStringAsFixed(2)}, ${item.lng.toStringAsFixed(2)}', style: TextStyle(color: KaloColors.secondaryText, fontSize: 11)),
                    trailing: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                    onTap: () => Navigator.pop(context, (name: item.name, lat: item.lat, lng: item.lng, isCurrent: false)),
                  );
                },
              ),
            ),
          ],
          if (_searched && !_loading && _results.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('No locations found', style: TextStyle(color: KaloColors.secondaryText, fontSize: 13)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
        ),
      ],
    );
  }
}
