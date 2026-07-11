import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
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
                        child: Text(AppLocalizations.of(context).skip, style: TextStyle(color: KaloColors.secondaryText)),
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
            AppLocalizations.of(context).kaloWeather,
            style: TextStyle(
              color: KaloColors.primaryText,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).onboardingWelcomeSubtitle,
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
              child: Text(AppLocalizations.of(context).getStarted, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            AppLocalizations.of(context).yourPrivacyMatters,
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).privacyDescription,
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
                  : Text(AppLocalizations.of(context).grantLocationAccess, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onNext,
            child: Text(AppLocalizations.of(context).maybeLater, style: TextStyle(color: KaloColors.secondaryText)),
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
            AppLocalizations.of(context).yourPrivateKey,
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).keyDescription,
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
              child: Text(AppLocalizations.of(context).continueAction, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            AppLocalizations.of(context).weatherDataSource,
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).dataSourceDescription,
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
              child: Text(AppLocalizations.of(context).useFreeApi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onNext,
            child: Text(AppLocalizations.of(context).configureLater, style: TextStyle(color: KaloColors.secondaryText)),
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
            AppLocalizations.of(context).chooseYourNavigation,
            style: TextStyle(color: KaloColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).navigationDescription,
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _ParadigmOption(
            title: AppLocalizations.of(context).locationCarousel,
            description: AppLocalizations.of(context).locationCarouselDescription,
            icon: Icons.swap_horiz,
            selected: currentParadigm == NavigationParadigm.locationCarousel,
            onTap: () => ref.read(navigationParadigmProvider.notifier).state = NavigationParadigm.locationCarousel,
          ),
          const SizedBox(height: 16),
          _ParadigmOption(
            title: AppLocalizations.of(context).stackView,
            description: AppLocalizations.of(context).stackViewDescription,
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
              child: Text(AppLocalizations.of(context).startUsingKalo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
