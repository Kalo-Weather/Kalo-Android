# AGENTS.md — Kalo Weather (Flutter)

## Entry points

- Phone app: `lib/main.dart` — loads `.env`, checks onboarding, routes to Dashboard or Onboarding
- Wear OS: `lib/main_wear.dart` — separate entry, run with `flutter run -t lib/main_wear.dart`

## Project architecture

- **State**: Riverpod `Provider`/`FutureProvider`/`StateProvider`/`StateNotifierProvider` — providers live in the same files as their services
- **Service layer** (`lib/services/`): no repository pattern — services are plain Dart classes exposed via Riverpod providers
- **Theme**: `lib/theme/app_theme.dart` — `KaloColors`, `SkyGradients`, `FrostedGlass` reusable widget
- **Models**: `proxy_weather.dart` is the central model mirroring the proxy server JSON response; other models (`UVIndex`, `WindData`, `AirQuality`, etc.) are derived from it
- **Illustrations**: `CustomPainter` in `lib/ui/widgets/weather_illustration.dart` — no PNG/SVG assets for weather icons

## Data flow

1. Proxy server (`/api/weather`) fetched first with encrypted API keys in headers
2. Falls back to direct OpenWeatherMap + Open-Meteo UV + WAQI calls if proxy is unreachable
3. `isFallbackProvider` signals which path is active (shown as orange banner in UI)
4. Default proxy: `https://kalo-vercel.vercel.app` (configurable via `.env` or Settings)

## Environment (`lib/services/proxy_config.dart:48`)

`.env` file at project root with these vars:

```
KALO_CLIENT_SECRET=your_proxy_client_secret_here
KALO_PROXY_BASE_URL=https://your-vercel-app.vercel.app
KALO_DECRYPTION_SECRET=64_character_hex_string_matching_server
```

App won't start without `.env` — shows a config error screen if missing.

**Gotchas:**
- `KALO_DECRYPTION_SECRET` must be exactly 64 hex chars (32 bytes) if set — AES-256-GCM key
- `KALO_CLIENT_SECRET` must differ from `'changeme_to_your_real_secret'` for proxy to work (checked in `proxy_service.dart:50`)

## Dev commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Run phone app | `flutter run` |
| Run Wear OS | `flutter run -t lib/main_wear.dart` |
| Analyze | `flutter analyze` |
| Run tests | `flutter test` |

- Analysis uses `package:flutter_lints/flutter.yaml` defaults — no custom rules
- No CI workflows, no pre-commit hooks, no codegen, no build_runner
- Two tests: `test/crypto_test.dart` (doesn't need `.env`) and `test/widget_test.dart` (needs `.env` present)
- `flutter test` passes if `.env` exists (can be minimal, just `KALO_CLIENT_SECRET=test`)

## Conventions

- No comments in code (follow existing style)
- Widget previews via `@Preview()` annotation from `package:flutter/widget_previews.dart` — scattered across widgets for dev hot-reload
- Frosted glass cards use `FrostedGlass` wrapper with `BackdropFilter` blur
- Sky background: `Container` with `BoxDecoration(gradient: SkyGradients.*)` — not a stack layer
- `convertTemp()` / `tempUnit()` helpers in `weather_service.dart:78-84` for Celsius↔Fahrenheit
- `WeatherCondition` enum with extension `.label` and `.isSevere` in `models/weather_condition.dart`

## Notable absences

- **No `config_service.dart`** exists despite README saying so — that file was removed
- No ConfigCat integration in current codebase
- No `home_widget` iOS widget integration implemented (package is a dep but unused)
- No `flutter pub run build_runner` needed — no codegen

## API key encryption

- Keys encrypted with AES-256-GCM using device hardware fingerprint (SHA-256 of HW properties + random install ID)
- `encryptLocalKey()` / `decryptLocalKey()` in `lib/services/crypto_service.dart`
- Proxy transmission: `encryptForProxy()` uses the shared `KALO_DECRYPTION_SECRET` (not the same key as local storage)
- Storage: `FlutterSecureStorage` (platform keychain) for encrypted key JSON blob
- Test in `test/crypto_test.dart` validates cross-device rejection

## Server API (`serverside.md`)

Proxy API at `/api/weather?lat=&lon=&units=`: Bearer token auth, requires `X-Client-Version: 1.2.0` header. Response shape matches `ProxyWeatherResponse` model exactly.
