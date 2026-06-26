# Kalo Weather

A Flutter weather app with location-based forecasts, interactive radar, and a Wear OS companion.

## Features

- **Weather Dashboard** — Current conditions and 24-hour hourly forecast powered by [Open-Meteo](https://open-meteo.com/)
- **Interactive Radar** — Weather radar overlay via [RainViewer](https://www.rainviewer.com/), gated by a ConfigCat feature flag
- **Multiple Locations** — Save and manage weather locations with persistent storage
- **Onboarding Flow** — First-launch walkthrough before entering the dashboard
- **Wear OS App** — Companion wearable app (`lib/main_wear.dart`)
- **Feature Flags** — Remote configuration via ConfigCat
- **Secure API Key Storage** — AES-256-GCM encryption tied to a device hardware fingerprint
- **Material 3** — Dynamic color theming (Material You) with light/dark mode support
- **Riverpod** — State management throughout the app

## Tech Stack

| Layer | Library |
|-------|---------|
| State Management | [Riverpod](https://riverpod.dev/) |
| Weather API | Open-Meteo (free, no key required) |
| Radar API | RainViewer |
| Feature Flags | [ConfigCat](https://configcat.com/) |
| Location | [geolocator](https://pub.dev/packages/geolocator) + [geocoding](https://pub.dev/packages/geocoding) |
| Persistence | [SharedPreferences](https://pub.dev/packages/shared_preferences) |
| Encryption | [encrypt](https://pub.dev/packages/encrypt) (AES-GCM) + [crypto](https://pub.dev/packages/crypto) |
| Device Info | [device_info_plus](https://pub.dev/packages/device_info_plus) |
| Theming | [dynamic_color](https://pub.dev/packages/dynamic_color) (Material You) |

## Project Structure

```
lib/
├── main.dart                # App entry point
├── main_wear.dart           # Wear OS companion entry point
├── models/
│   ├── api_key.dart         # API key model
│   ├── hourly_forecast.dart # Hourly forecast model
│   └── weather_location.dart# Saved location model
├── services/
│   ├── config_service.dart  # ConfigCat feature flag client
│   ├── crypto_service.dart  # AES-256-GCM encryption/decryption
│   ├── database_service.dart# SharedPreferences persistence layer
│   ├── device_service.dart  # Device hardware fingerprint
│   ├── location_service.dart# GPS & reverse geocoding
│   ├── navigation_provider.dart# UI state providers
│   ├── radar_service.dart   # RainViewer radar tile fetching
│   └── weather_service.dart # Open-Meteo forecast fetching
└── ui/
    ├── dashboard/           # Main weather dashboard
    ├── onboarding/          # First-launch onboarding
    ├── radar/               # Interactive radar screen
    └── settings/            # Settings screen
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.12.2
- A [ConfigCat](https://configcat.com/) account (optional, for feature flags)

### Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure ConfigCat** (optional)
   Replace `YOUR-CONFIGCAT-SDK-KEY` in `lib/services/config_service.dart` with your actual SDK key, or pass it via `--dart-define`.

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Run the Wear OS app**
   ```bash
   flutter run -t lib/main_wear.dart
   ```

## Configuration

- The weather forecast uses the free [Open-Meteo API](https://open-meteo.com/) — no API key required.
- Radar data comes from the free [RainViewer API](https://www.rainviewer.com/api.html).
- The interactive radar screen is controlled by the ConfigCat flag `enable_interactive_radar`.
- API keys for third-party services are encrypted at rest using AES-256-GCM with a device-derived hardware key.
