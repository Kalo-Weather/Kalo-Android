// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kalo Weather';

  @override
  String get myLocation => 'My Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get configFileNotFound => 'Configuration file not found';

  @override
  String get configFileDescription =>
      'Create a .env file in the project root.\nSee .env.example for the required variables.';

  @override
  String get savedLocations => 'Saved Locations';

  @override
  String get addLocation => 'Add Location';

  @override
  String get addLocationTitle => 'Add Location';

  @override
  String get addLocationDescription =>
      'Search for a city or use your current location.';

  @override
  String get cityNameHint => 'City name';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get noLocationsFound => 'No locations found';

  @override
  String get noSavedLocations => 'No saved locations';

  @override
  String get searchFailed => 'Search failed. Check your connection.';

  @override
  String get locationNotFound => 'Location not found';

  @override
  String get couldNotFindLocation => 'Could not find location';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get couldNotGetLocation => 'Could not get current location';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get wind => 'Wind';

  @override
  String get humidity => 'Humidity';

  @override
  String get realFeel => 'Real Feel';

  @override
  String get radar => 'Radar';

  @override
  String get tapToView => 'Tap to view';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get precipitationRadar => 'Precipitation Radar';

  @override
  String get hourlyForecast => 'Hourly Forecast';

  @override
  String get now => 'Now';

  @override
  String get hourlyDataUnavailable => 'Hourly data unavailable';

  @override
  String get sevenDayForecast => '7-Day Forecast';

  @override
  String get today => 'Today';

  @override
  String get proxyUnavailable =>
      'Proxy unavailable — using direct API fallback';

  @override
  String get weatherAlerts => 'Weather Alerts';

  @override
  String alertInstruction(Object instruction) {
    return 'Instruction: $instruction';
  }

  @override
  String get unableToLoadWeather => 'Unable to load weather';

  @override
  String get couldNotLoadWeather => 'Could not load weather';

  @override
  String get reportIssues =>
      'Report issues at github.com/Kalo-Weather/Kalo-Android/issues';

  @override
  String get settings => 'Settings';

  @override
  String get navigation => 'Navigation';

  @override
  String get locationCarousel => 'Location Carousel';

  @override
  String get locationCarouselSubtitle => 'Swipe left/right to switch locations';

  @override
  String get stackView => 'Stack View';

  @override
  String get stackViewSubtitle => 'Swipe up/down to switch locations';

  @override
  String get units => 'Units';

  @override
  String get temperature => 'Temperature';

  @override
  String get celsius => 'Celsius';

  @override
  String get fahrenheit => 'Fahrenheit';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get timeFormat24h => '24-hour';

  @override
  String get timeFormat12h => '12-hour';

  @override
  String get display => 'Display';

  @override
  String get animatedBackground => 'Animated Background';

  @override
  String get animatedBackgroundSubtitle =>
      'Weather animations on dashboard (disable if laggy)';

  @override
  String get customizeWidgets => 'Customize Widgets';

  @override
  String get customizeWidgetsSubtitle =>
      'Drag, reorder, and toggle blocks per widget size';

  @override
  String get autoRefreshWidgets => 'Auto-Refresh Widgets';

  @override
  String get autoRefreshWidgetsSubtitle =>
      'Update widgets when weather refreshes';

  @override
  String get nowBar => 'Now Bar (One UI 6+)';

  @override
  String get nowBarSubtitle => 'Show weather on Samsung lock screen Now Bar';

  @override
  String get apiKeys => 'API Keys';

  @override
  String get openWeatherMap => 'OpenWeatherMap';

  @override
  String get openWeatherMapKeyTitle => 'OpenWeatherMap API Key';

  @override
  String get waqiAirQuality => 'WAQI (Air Quality)';

  @override
  String get waqiKeyTitle => 'WAQI API Key';

  @override
  String get enterApiKey => 'Enter your API key';

  @override
  String get keyEncryptedInfo =>
      'Stored encrypted on-device and sent securely to the proxy.';

  @override
  String get proxyServer => 'Proxy Server';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get usePublicProxy => 'Use Public Proxy';

  @override
  String get proxyDescription =>
      'Use the public Kalo proxy or your own Vercel deployment.';

  @override
  String get or => 'OR';

  @override
  String get proxyHintUrl => 'https://kalo-vercel.vercel.app';

  @override
  String get updates => 'Updates';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get savedLocationsSection => 'Saved Locations';

  @override
  String get addLocationSubtitle => 'Search city or use current location';

  @override
  String get apiKeyStatusSet => 'Set';

  @override
  String get apiKeyStatusNotSet => 'Not set';

  @override
  String get couldNotCheckUpdates => 'Could not check for updates';

  @override
  String alreadyUpToDate(Object current) {
    return 'Already up to date (v$current)';
  }

  @override
  String get renameLocation => 'Rename Location';

  @override
  String get locationNameHint => 'Location name';

  @override
  String get skip => 'Skip';

  @override
  String get kaloWeather => 'Kalo Weather';

  @override
  String get onboardingWelcomeSubtitle =>
      'Beautiful weather tracking with privacy at its core.\nNo ads. No trackers. Just weather.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get yourPrivacyMatters => 'Your Privacy Matters';

  @override
  String get privacyDescription =>
      'Kalo has zero telemetry, no ads, and no trackers.\nYour data stays on your device.';

  @override
  String get grantLocationAccess => 'Grant Location Access';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get yourPrivateKey => 'Your Private Key';

  @override
  String get keyDescription =>
      'Kalo generates a unique encryption key tied to your device.\nYour API keys are encrypted locally and never leave your phone.';

  @override
  String get continueAction => 'Continue';

  @override
  String get weatherDataSource => 'Weather Data Source';

  @override
  String get dataSourceDescription =>
      'Use the free Open-Meteo API with no key needed, or add your own API keys for additional providers.';

  @override
  String get useFreeApi => 'Use Free API';

  @override
  String get configureLater => 'Configure Later';

  @override
  String get chooseYourNavigation => 'Choose Your Navigation';

  @override
  String get navigationDescription =>
      'How would you like to navigate through locations and weather data?';

  @override
  String get locationCarouselDescription =>
      'Swipe left/right to switch locations\nScroll up/down for weather details';

  @override
  String get stackViewDescription =>
      'Swipe left/right for weather cards\nScroll up/down to switch locations';

  @override
  String get startUsingKalo => 'Start Using Kalo';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get downloadComplete => 'Download complete';

  @override
  String downloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get later => 'Later';

  @override
  String get downloadAndInstall => 'Download & Install';

  @override
  String get install => 'Install';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';
}
