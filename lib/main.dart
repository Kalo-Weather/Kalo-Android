import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:home_widget/home_widget.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/dashboard/dashboard_screen.dart';
import 'services/database_service.dart';
import 'services/device_service.dart';
import 'services/navigation_provider.dart';
import 'services/proxy_config.dart';
import 'services/config_status.dart';

import 'services/notification_service.dart';
import 'services/update_service.dart';
import 'services/widget_service.dart';
import 'services/weather_service.dart';
import 'services/background_service.dart';
import 'ui/update/update_dialog.dart';
import 'models/weather_condition.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ConfigStatus envStatus = ConfigStatus.ok;
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    envStatus = ConfigStatus.missingEnv;
  }

  final dbService = await DatabaseService.init();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  final deviceService = DeviceService();
  await deviceService.ensureFingerprintEntropy();

  final notificationService = NotificationService();
  await notificationService.init();

  await BackgroundService.initialize();
  await BackgroundService.schedulePeriodicRefresh();

  final initialUnit = await _detectInitialUnit();
  await prefs.setString('unit_preference', initialUnit);

  final initialNowBar = prefs.getBool('nowBarEnabled') ?? false;
  final initialWidgetRefresh = prefs.getBool('widgetRefreshEnabled') ?? true;

  HomeWidget.registerInteractivityCallback(WidgetService.widgetCallback);

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompletedProvider.overrideWith((ref) => onboardingCompleted),
        databaseServiceProvider.overrideWithValue(dbService),
        deviceServiceProvider.overrideWithValue(deviceService),
        notificationServiceProvider.overrideWithValue(notificationService),
        configStatusProvider.overrideWith((ref) => envStatus),
        unitPreferenceProvider.overrideWith((ref) => initialUnit),
        nowBarEnabledProvider.overrideWith((ref) => initialNowBar),
        widgetRefreshEnabledProvider.overrideWith((ref) => initialWidgetRefresh),
      ],
      child: const KaloApp(),
    ),
  );
}

const _fahrenheitCountries = {'US', 'BS', 'BZ', 'KY', 'PW', 'MH', 'FM', 'LR', 'MM'};

Future<String> _detectInitialUnit() async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty && _fahrenheitCountries.contains(placemarks.first.isoCountryCode)) {
        return 'Fahrenheit';
      }
    }
  } catch (_) {}
  return 'Celsius';
}

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

class KaloApp extends ConsumerStatefulWidget {
  const KaloApp({super.key});

  @override
  ConsumerState<KaloApp> createState() => _KaloAppState();
}

class _KaloAppState extends ConsumerState<KaloApp> {
  @override
  void initState() {
    super.initState();
    ref.read(proxyBaseUrlProvider.notifier).load();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final update = await ref.read(updateInfoProvider.future);
    if (update == null || !mounted) return;
    final current = await ref.read(currentVersionProvider.future);
    if (!mounted) return;
    if (isNewerVersion(update.version, current)) {
      UpdateDialog.show(context, update, current);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentWeatherProvider, (prev, next) {
      next.whenData((weather) async {
        if (weather == null) return;
        final unitPref = ref.read(unitPreferenceProvider);
        final widgetEnabled = ref.read(widgetRefreshEnabledProvider);
        if (widgetEnabled) {
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
        }
        final nowBarEnabled = ref.read(nowBarEnabledProvider);
        if (nowBarEnabled) {
          final temp = convertTemp(weather.temperature, unitPref);
          final label = tempUnit(unitPref);
          final notificationService = ref.read(notificationServiceProvider);
          await notificationService.showNowBarWeather(
            temp: '$temp°$label',
            emoji: weather.condition.emoji,
            location: 'My Location',
            condition: weather.condition.label,
          );
        }
      });
    });

    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final configStatus = ref.watch(configStatusProvider);
    if (configStatus == ConfigStatus.missingEnv) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: _ConfigErrorScreen(),
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Kalo Weather',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue),
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: KaloColors.amoledDark,
          ),
          themeMode: ThemeMode.dark,
          home: onboardingCompleted ? const DashboardScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}

class _ConfigErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaloColors.amoledDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
              const SizedBox(height: 24),
              Text(
                'Configuration file not found',
                style: TextStyle(color: KaloColors.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create a .env file in the project root.\nSee .env.example for the required variables.',
                style: TextStyle(color: KaloColors.secondaryText, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
