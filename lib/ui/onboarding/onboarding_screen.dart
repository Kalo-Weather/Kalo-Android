import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../services/navigation_provider.dart';
import '../../services/database_service.dart';
import '../../weather_icons/weather_icons.dart';
import '../../weather_icons/boxed_icon.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: SkyGradients.clearNight),
        child: SafeArea(
          child: Column(
            children: [
              if (_currentStep < 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: KaloColors.primaryText),
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text('Skip', style: TextStyle(color: KaloColors.secondaryText)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    _WelcomeStep(onNext: _next),
                    _PrivacyStep(onNext: _next),
                    _KeyCreationStep(onNext: _next),
                    _ApiSelectionStep(onNext: _next),
                    _GestureCustomizationStep(onComplete: _completeOnboarding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BoxedIcon(WeatherIcons.day_sunny, size: 150, color: Colors.white),
          const SizedBox(height: 32),
          Text(
            'Kalo Weather',
            style: TextStyle(
              color: KaloColors.primaryText,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Beautiful weather tracking with privacy at its core.\nNo ads. No trackers. Just weather.',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 16, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const _PrivacyStep({required this.onNext});

  @override
  ConsumerState<_PrivacyStep> createState() => _PrivacyStepState();
}

class _PrivacyStepState extends ConsumerState<_PrivacyStep> {
  bool _saving = false;

  Future<void> _requestLocation(BuildContext context) async {
    final status = await Geolocator.requestPermission();
    if (status == LocationPermission.always || status == LocationPermission.whileInUse) {
      setState(() => _saving = true);
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        );
        await ref.read(databaseServiceProvider).addLocation('My Location', pos.latitude, pos.longitude);
      } catch (_) {}
    }
    if (mounted) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.privacy_tip_outlined, color: KaloColors.primaryText, size: 80),
          const SizedBox(height: 24),
          Text(
            'Your Privacy Matters',
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Kalo has zero telemetry, no ads, and no trackers.\nYour data stays on your device.',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : () => _requestLocation(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Grant Location Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onNext,
            child: Text('Maybe Later', style: TextStyle(color: KaloColors.secondaryText)),
          ),
        ],
      ),
    );
  }
}

class _KeyCreationStep extends ConsumerWidget {
  final VoidCallback onNext;

  const _KeyCreationStep({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key_outlined, color: KaloColors.primaryText, size: 80),
          const SizedBox(height: 24),
          Text(
            'Your Private Key',
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Kalo generates a unique encryption key tied to your device.\nYour API keys are encrypted locally and never leave your phone.',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiSelectionStep extends StatelessWidget {
  final VoidCallback onNext;

  const _ApiSelectionStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.api_outlined, color: KaloColors.primaryText, size: 80),
          const SizedBox(height: 24),
          Text(
            'Weather Data Source',
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Use the free Open-Meteo API with no key needed, or add your own API keys for additional providers.',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: const Text('Use Free API', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onNext,
            child: Text('Configure Later', style: TextStyle(color: KaloColors.secondaryText)),
          ),
        ],
      ),
    );
  }
}

class _GestureCustomizationStep extends ConsumerWidget {
  final VoidCallback onComplete;

  const _GestureCustomizationStep({required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentParadigm = ref.watch(navigationParadigmProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Navigation',
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'How would you like to navigate through locations and weather data?',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _ParadigmOption(
            title: 'Location Carousel',
            description: 'Swipe left/right to switch locations\nScroll up/down for weather details',
            icon: Icons.swap_horiz,
            selected: currentParadigm == NavigationParadigm.locationCarousel,
            onTap: () => ref.read(navigationParadigmProvider.notifier).state = NavigationParadigm.locationCarousel,
          ),
          const SizedBox(height: 16),
          _ParadigmOption(
            title: 'Stack View',
            description: 'Swipe left/right for weather cards\nScroll up/down to switch locations',
            icon: Icons.view_carousel,
            selected: currentParadigm == NavigationParadigm.stackView,
            onTap: () => ref.read(navigationParadigmProvider.notifier).state = NavigationParadigm.stackView,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              child: const Text('Start Using Kalo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParadigmOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ParadigmOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.15) : KaloColors.frostWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white : KaloColors.frostBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: KaloColors.primaryText, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: KaloColors.secondaryText, fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
