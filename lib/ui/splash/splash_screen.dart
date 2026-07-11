import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:home_widget/home_widget.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../../services/background_service.dart';
import '../../services/proxy_config.dart';
import '../../services/update_service.dart';
import '../../services/widget_service.dart';
import '../../services/navigation_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../update/update_dialog.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _initNotifications(),
      _initBackground(),
      _detectUnit(),
      _loadProxyUrl(),
      _checkUpdates(),
    ]);

    if (!mounted) return;

    try {
      HomeWidget.registerInteractivityCallback(WidgetService.widgetCallback);
    } catch (_) {}

    if (!mounted) return;

    final onboardingCompleted = ref.read(onboardingCompletedProvider);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => onboardingCompleted ? const DashboardScreen() : const OnboardingScreen(),
      ),
    );
  }

  Future<void> _initNotifications() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.init();
    } catch (_) {}
  }

  Future<void> _initBackground() async {
    try {
      await BackgroundService.initialize();
      await BackgroundService.schedulePeriodicRefresh();
    } catch (_) {}
  }

  Future<void> _detectUnit() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 8)),
        );
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          const fahrenheitCountries = {'US', 'BS', 'BZ', 'KY', 'PW', 'MH', 'FM', 'LR', 'MM'};
          if (fahrenheitCountries.contains(placemarks.first.isoCountryCode)) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('unit_preference', 'Fahrenheit');
            ref.read(unitPreferenceProvider.notifier).state = 'Fahrenheit';
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadProxyUrl() async {
    try {
      await ref.read(proxyBaseUrlProvider.notifier).load();
    } catch (_) {}
  }

  Future<void> _checkUpdates() async {
    try {
      final update = await ref.read(updateInfoProvider.future);
      if (update == null || !mounted) return;
      final current = await ref.read(currentVersionProvider.future);
      if (!mounted) return;
      if (isNewerVersion(update.version, current)) {
        UpdateDialog.show(context, update, current);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaloColors.amoledDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny, color: Colors.white, size: 120),
            const SizedBox(height: 32),
            Text(
              'Kalo Weather',
              style: TextStyle(
                color: KaloColors.primaryText,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
