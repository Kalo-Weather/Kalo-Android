import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/weather_service.dart';
import '../../services/radar_service.dart';
import '../../services/location_service.dart';
import '../../services/navigation_provider.dart';
import '../../services/database_service.dart';
import '../../services/proxy_service.dart';
import '../../models/weather_location.dart';
import '../../models/weather_condition.dart';
import '../widgets/weather_illustration.dart';
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

    return Container(
      decoration: const BoxDecoration(gradient: SkyGradients.clearDay),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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

    return SafeArea(
      child: Column(
          children: [
            _buildLocationBar(locationName, allLocations),
            if (isFallback) _buildFallbackBanner(),
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
                  const Icon(Icons.location_on, color: KaloColors.primaryText, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      locationName,
                      style: const TextStyle(
                        color: KaloColors.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: KaloColors.primaryText, size: 20),
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
            icon: const Icon(Icons.settings, color: KaloColors.primaryText, size: 20),
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
          const Text('Saved Locations', style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: locations.asMap().entries.map((e) => ListTile(
                leading: const Icon(Icons.location_city, color: KaloColors.secondaryText, size: 20),
                title: Text(e.value.name, style: const TextStyle(color: KaloColors.primaryText)),
                trailing: e.key == _currentLocationIndex ? const Icon(Icons.check, color: Colors.blue, size: 18) : null,
                onTap: () {
                  setState(() => _currentLocationIndex = e.key);
                  Navigator.pop(ctx);
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
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
        WeatherIllustration(
          condition: weather.condition,
          isDay: isDay,
          size: 100,
        ),
        const SizedBox(height: 8),
        Text(
          '${temp.toStringAsFixed(0)}°$unit',
          style: const TextStyle(
            color: KaloColors.primaryText,
            fontSize: 72,
            fontWeight: FontWeight.w200,
            shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weather.condition.label,
          style: const TextStyle(
            color: KaloColors.primaryText,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'H: ${hi.toStringAsFixed(0)}°$unit  L: ${lo.toStringAsFixed(0)}°$unit',
          style: const TextStyle(
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
          const Text('Hourly Forecast', style: TextStyle(color: KaloColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
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
                    Text('$hour:00', style: const TextStyle(color: KaloColors.secondaryText, fontSize: 11)),
                    const SizedBox(height: 6),
                    BoxedIcon(
                      _iconForCode(f.weatherCode),
                      color: KaloColors.primaryText,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${temp.toStringAsFixed(0)}°${tempUnit(unitPref)}',
                      style: const TextStyle(color: KaloColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
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

  IconData _iconForCode(int code) {
    if (code == 0) return WeatherIcons.day_sunny;
    if (code <= 48) return WeatherIcons.cloudy;
    if (code <= 67) return WeatherIcons.rain;
    if (code <= 77) return WeatherIcons.snow;
    if (code <= 86) return WeatherIcons.showers;
    return WeatherIcons.thunderstorm;
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

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: KaloColors.secondaryText, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather',
              style: const TextStyle(color: KaloColors.primaryText, fontSize: 18),
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
              style: const TextStyle(color: KaloColors.secondaryText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
