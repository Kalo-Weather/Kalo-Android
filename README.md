# Kalo Weather

[![Flutter](https://img.shields.io/badge/Flutter-3.12-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Custom-blue.svg)](LICENSE.md)
[![CI](https://github.com/Kalo-Weather/Kalo-Android/actions/workflows/build.yml/badge.svg)](https://github.com/Kalo-Weather/Kalo-Android/actions/workflows/build.yml)

**Kalo Weather** is a beautiful, privacy-focused weather app for Android (with a Wear OS companion) built with Flutter. It uses Material You dynamic theming, custom weather illustrations, and supports both a proxy backend and direct API fallback.

> No ads. No trackers. Just weather.

---

## Features

- **Current Conditions** — Temperature, feels-like, condition, humidity, wind, UV index, and air quality
- **24-Hour Forecast** — Hourly temperature and weather condition preview
- **7-Day Forecast** — Daily highs/lows with temperature range bars
- **Interactive Radar** — RainViewer precipitation overlay on a dark CartoDB map
- **Multiple Locations** — Search, save, and swipe between locations
- **Weather Alerts** — NWS-based severe weather alerts (US only)
- **Wear OS App** — Companion wearable app (`lib/main_wear.dart`)
- **Material You Design** — Dynamic color theming with frosted glass cards
- **Animated Background** — Optional weather-condition-based animations
- **Secure Key Storage** — AES-256-GCM encryption with device-binding
- **Proxy Support** — Optional proxy backend (Vercel) for keyless operation
- **Direct Fallback** — Falls back to OpenWeatherMap + Open-Meteo + WAQI if proxy is down
- **Home Screen Widgets** — Small, medium, and large Android widgets with live weather data
- **Widget Editor** — Customize widget blocks (temp, feels-like, condition, location, wind, humidity, UV, AQI) via drag-and-drop reordering in-app

## Screenshots

| Dashboard | Radar | Settings |
|-----------|-------|----------|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

*Screenshots coming soon. Run the app to see it in action!*

## Tech Stack

| Layer | Library |
|-------|---------|
| UI Framework | [Flutter](https://flutter.dev) 3.12+ |
| State Management | [Riverpod](https://riverpod.dev) 2.x |
| Weather API | [Open-Meteo](https://open-meteo.com) (free, no key required) |
| Weather Proxy | [Vercel](https://vercel.com) (optional, [source](https://github.com/Kalo-Weather/kalo-proxy)) |
| Radar | [RainViewer](https://www.rainviewer.com) |
| Map | [Flutter Map](https://pub.dev/packages/flutter_map) + CartoDB |
| Alerts | [NWS API](https://www.weather.gov/documentation/services-web-api) (US only) |
| Location | [geolocator](https://pub.dev/packages/geolocator) + [geocoding](https://pub.dev/packages/geocoding) |
| Secure Storage | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Encryption | [encrypt](https://pub.dev/packages/encrypt) (AES-256-GCM) + [crypto](https://pub.dev/packages/crypto) |
| Theming | [dynamic_color](https://pub.dev/packages/dynamic_color) (Material You) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| Icons | [Weather Icons](https://erikflowers.github.io/weather-icons/) font |

## Quick Start

### Prerequisites

- Flutter SDK ^3.12.2
- Android Studio / VS Code with Flutter extension

### Setup

```bash
# Clone
git clone https://github.com/Kalo-Weather/Kalo-Android.git
cd Kalo-Android

# Install dependencies
flutter pub get

# Create environment file
cp .env.example .env
# Edit .env with your config (see below)

# Run
flutter run
```

### Wear OS

```bash
flutter run -t lib/main_wear.dart
```

### Environment Variables

Copy `.env.example` to `.env` and configure:

| Variable | Required | Description |
|----------|----------|-------------|
| `KALO_CLIENT_SECRET` | Yes | Proxy auth secret (must differ from `changeme_to_your_real_secret`) |
| `KALO_PROXY_BASE_URL` | No | Proxy server URL (defaults to `https://kalo-vercel.vercel.app`) |
| `KALO_DECRYPTION_SECRET` | No | 64-char hex key for AES-256-GCM encrypted transmission |

The app shows a configuration error screen if `.env` is missing.

## Architecture

```
lib/
├── main.dart                # Entry point — loads .env, inits services, routes app
├── main_wear.dart           # Wear OS companion entry
├── models/                  # Data models mirroring the proxy JSON contract
│   └── proxy_weather.dart   # Central model — all UI derives from this
├── services/                # Business logic + Riverpod providers
│   ├── proxy_service.dart   # Proxy fetch + direct API fallback
│   ├── weather_service.dart # Transforms ProxyWeatherResponse → WeatherData
│   ├── crypto_service.dart  # AES-256-GCM encrypt/decrypt helpers
│   ├── device_service.dart  # Hardware fingerprint for key binding
│   ├── database_service.dart# SharedPreferences + secure storage
│   ├── radar_service.dart   # RainViewer tile URL provider
│   └── ...
├── theme/
│   └── app_theme.dart       # KaloColors, SkyGradients, FrostedGlass
├── ui/
│   ├── dashboard/           # Main weather screen with location carousel
│   ├── onboarding/          # First-launch walkthrough (5 steps)
│   ├── radar/               # Full-screen FlutterMap with rain overlay
│   ├── settings/            # Temperature, proxy, API keys, locations
│   ├── widget_editor/       # Drag-and-drop widget block customization
│   └── widgets/             # UV, AQI, wind, humidity, radar cards
└── weather_icons/           # Custom icon font mapping + BoxedIcon widget
```

### Data Flow

1. **Proxy path**: App fetches `/api/weather?lat=&lon=` from the proxy server with encrypted API keys in headers
2. **Fallback path**: If proxy is unreachable, app falls back to direct OpenWeatherMap + Open-Meteo UV + WAQI calls
3. `isFallbackProvider` signals which path is active (shown as orange banner in UI)
4. API keys are encrypted at rest using a device-derived AES-256-GCM key

## Proxy Backend

The proxy backend (optional) is a Vercel serverless function that aggregates weather data so the client doesn't need API keys. See the [kalo-proxy](https://github.com/Kalo-Weather/kalo-proxy) repository.

### Running without a proxy

The app works without any proxy by setting dummy values in `.env`. It will attempt the proxy first and fall back to direct API calls. For full functionality without the proxy, you can enter OpenWeatherMap and WAQI API keys in Settings.

## Home Screen Widgets

Kalo Weather provides three Android widget sizes via the `home_widget` package:

| Size | Dimensions | Default Blocks |
|------|-----------|---------------|
| Small | 2×1 | Location, Temperature, Condition icon |
| Medium | 4×2 | Small + Feels-like + hourly forecast strip |
| Large | 4×4 | Medium + Humidity, Wind, UV Index, AQI |

Widgets update automatically after each weather fetch and support tap-to-open the app.

### Widget Editor

Customize widget blocks from **Settings → Customize Widgets**:

- **Drag-and-drop reorder** blocks per size
- **Toggle blocks** on/off (Temperature, Feels Like, Condition Icon, Location, Time, Humidity, Wind, UV Index, AQI)
- **Live preview** shows how the widget will look on your home screen
- **Save per size** — each widget size has its own layout configuration
- **Reset to default** restores the factory block order

Blocks respect size constraints — large-only blocks (Humidity, Wind, UV, AQI) don't appear in smaller layouts.

### Implementation

- Config stored in `SharedPreferences` via `widgetConfigProvider`
- Pushed to the Android widget via `HomeWidget.saveWidgetData()` as JSON
- Native `KaloWidgetProvider` (`KaloWidgetSmallProvider`, `KaloWidgetMediumProvider`, `KaloWidgetLargeProvider`) reads the config and renders only the selected blocks using `RemoteViews.setViewVisibility`
- XML layouts include all possible blocks per size (hidden ones are `View.GONE`)

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Good first issues:**
- Improve error handling for denied location permissions
- Add loading shimmer effects to weather cards
- Implement pull-to-refresh on dashboard
- Improve accessibility (screen reader labels)
- Add portrait/landscape layout adaptation

## License

This project is licensed under the Custom Source-Available License — see [LICENSE.md](LICENSE.md) for details.
