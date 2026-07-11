import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kalo Weather'**
  String get appTitle;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @configFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Configuration file not found'**
  String get configFileNotFound;

  /// No description provided for @configFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a .env file in the project root.\nSee .env.example for the required variables.'**
  String get configFileDescription;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @addLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocationTitle;

  /// No description provided for @addLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or use your current location.'**
  String get addLocationDescription;

  /// No description provided for @cityNameHint.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get cityNameHint;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @noSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'No saved locations'**
  String get noSavedLocations;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check your connection.'**
  String get searchFailed;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @couldNotFindLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not find location'**
  String get couldNotFindLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location'**
  String get couldNotGetLocation;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get uvIndex;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get airQuality;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @realFeel.
  ///
  /// In en, this message translates to:
  /// **'Real Feel'**
  String get realFeel;

  /// No description provided for @radar.
  ///
  /// In en, this message translates to:
  /// **'Radar'**
  String get radar;

  /// No description provided for @tapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @precipitationRadar.
  ///
  /// In en, this message translates to:
  /// **'Precipitation Radar'**
  String get precipitationRadar;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly Forecast'**
  String get hourlyForecast;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @hourlyDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Hourly data unavailable'**
  String get hourlyDataUnavailable;

  /// No description provided for @sevenDayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-Day Forecast'**
  String get sevenDayForecast;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @proxyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Proxy unavailable — using direct API fallback'**
  String get proxyUnavailable;

  /// No description provided for @weatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlerts;

  /// No description provided for @alertInstruction.
  ///
  /// In en, this message translates to:
  /// **'Instruction: {instruction}'**
  String alertInstruction(Object instruction);

  /// No description provided for @unableToLoadWeather.
  ///
  /// In en, this message translates to:
  /// **'Unable to load weather'**
  String get unableToLoadWeather;

  /// No description provided for @couldNotLoadWeather.
  ///
  /// In en, this message translates to:
  /// **'Could not load weather'**
  String get couldNotLoadWeather;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report issues at github.com/Kalo-Weather/Kalo-Android/issues'**
  String get reportIssues;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @locationCarousel.
  ///
  /// In en, this message translates to:
  /// **'Location Carousel'**
  String get locationCarousel;

  /// No description provided for @locationCarouselSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right to switch locations'**
  String get locationCarouselSubtitle;

  /// No description provided for @stackView.
  ///
  /// In en, this message translates to:
  /// **'Stack View'**
  String get stackView;

  /// No description provided for @stackViewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe up/down to switch locations'**
  String get stackViewSubtitle;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit'**
  String get fahrenheit;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormat;

  /// No description provided for @timeFormat24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get timeFormat24h;

  /// No description provided for @timeFormat12h.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get timeFormat12h;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @animatedBackground.
  ///
  /// In en, this message translates to:
  /// **'Animated Background'**
  String get animatedBackground;

  /// No description provided for @animatedBackgroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weather animations on dashboard (disable if laggy)'**
  String get animatedBackgroundSubtitle;

  /// No description provided for @customizeWidgets.
  ///
  /// In en, this message translates to:
  /// **'Customize Widgets'**
  String get customizeWidgets;

  /// No description provided for @customizeWidgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag, reorder, and toggle blocks per widget size'**
  String get customizeWidgetsSubtitle;

  /// No description provided for @autoRefreshWidgets.
  ///
  /// In en, this message translates to:
  /// **'Auto-Refresh Widgets'**
  String get autoRefreshWidgets;

  /// No description provided for @autoRefreshWidgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update widgets when weather refreshes'**
  String get autoRefreshWidgetsSubtitle;

  /// No description provided for @nowBar.
  ///
  /// In en, this message translates to:
  /// **'Now Bar (One UI 6+)'**
  String get nowBar;

  /// No description provided for @nowBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show weather on Samsung lock screen Now Bar'**
  String get nowBarSubtitle;

  /// No description provided for @apiKeys.
  ///
  /// In en, this message translates to:
  /// **'API Keys'**
  String get apiKeys;

  /// No description provided for @openWeatherMap.
  ///
  /// In en, this message translates to:
  /// **'OpenWeatherMap'**
  String get openWeatherMap;

  /// No description provided for @openWeatherMapKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenWeatherMap API Key'**
  String get openWeatherMapKeyTitle;

  /// No description provided for @waqiAirQuality.
  ///
  /// In en, this message translates to:
  /// **'WAQI (Air Quality)'**
  String get waqiAirQuality;

  /// No description provided for @waqiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'WAQI API Key'**
  String get waqiKeyTitle;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get enterApiKey;

  /// No description provided for @keyEncryptedInfo.
  ///
  /// In en, this message translates to:
  /// **'Stored encrypted on-device and sent securely to the proxy.'**
  String get keyEncryptedInfo;

  /// No description provided for @proxyServer.
  ///
  /// In en, this message translates to:
  /// **'Proxy Server'**
  String get proxyServer;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @usePublicProxy.
  ///
  /// In en, this message translates to:
  /// **'Use Public Proxy'**
  String get usePublicProxy;

  /// No description provided for @proxyDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the public Kalo proxy or your own Vercel deployment.'**
  String get proxyDescription;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @proxyHintUrl.
  ///
  /// In en, this message translates to:
  /// **'https://kalo-vercel.vercel.app'**
  String get proxyHintUrl;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @savedLocationsSection.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocationsSection;

  /// No description provided for @addLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search city or use current location'**
  String get addLocationSubtitle;

  /// No description provided for @apiKeyStatusSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get apiKeyStatusSet;

  /// No description provided for @apiKeyStatusNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get apiKeyStatusNotSet;

  /// No description provided for @couldNotCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get couldNotCheckUpdates;

  /// No description provided for @alreadyUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Already up to date (v{current})'**
  String alreadyUpToDate(Object current);

  /// No description provided for @renameLocation.
  ///
  /// In en, this message translates to:
  /// **'Rename Location'**
  String get renameLocation;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Location name'**
  String get locationNameHint;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @kaloWeather.
  ///
  /// In en, this message translates to:
  /// **'Kalo Weather'**
  String get kaloWeather;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful weather tracking with privacy at its core.\nNo ads. No trackers. Just weather.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get yourPrivacyMatters;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Kalo has zero telemetry, no ads, and no trackers.\nYour data stays on your device.'**
  String get privacyDescription;

  /// No description provided for @grantLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Location Access'**
  String get grantLocationAccess;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @yourPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'Your Private Key'**
  String get yourPrivateKey;

  /// No description provided for @keyDescription.
  ///
  /// In en, this message translates to:
  /// **'Kalo generates a unique encryption key tied to your device.\nYour API keys are encrypted locally and never leave your phone.'**
  String get keyDescription;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @weatherDataSource.
  ///
  /// In en, this message translates to:
  /// **'Weather Data Source'**
  String get weatherDataSource;

  /// No description provided for @dataSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the free Open-Meteo API with no key needed, or add your own API keys for additional providers.'**
  String get dataSourceDescription;

  /// No description provided for @useFreeApi.
  ///
  /// In en, this message translates to:
  /// **'Use Free API'**
  String get useFreeApi;

  /// No description provided for @configureLater.
  ///
  /// In en, this message translates to:
  /// **'Configure Later'**
  String get configureLater;

  /// No description provided for @chooseYourNavigation.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Navigation'**
  String get chooseYourNavigation;

  /// No description provided for @navigationDescription.
  ///
  /// In en, this message translates to:
  /// **'How would you like to navigate through locations and weather data?'**
  String get navigationDescription;

  /// No description provided for @locationCarouselDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right to switch locations\nScroll up/down for weather details'**
  String get locationCarouselDescription;

  /// No description provided for @stackViewDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right for weather cards\nScroll up/down to switch locations'**
  String get stackViewDescription;

  /// No description provided for @startUsingKalo.
  ///
  /// In en, this message translates to:
  /// **'Start Using Kalo'**
  String get startUsingKalo;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(Object error);

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @downloadAndInstall.
  ///
  /// In en, this message translates to:
  /// **'Download & Install'**
  String get downloadAndInstall;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
