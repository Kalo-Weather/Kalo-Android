# Kalo Weather — UI

## Entry points & routing

- `lib/main.dart` — loads `.env`, checks onboarding, routes to **Dashboard** or **Onboarding**
- `lib/main_wear.dart` — Wear OS entry point (`flutter run -t lib/main_wear.dart`)

## Directory structure

```
lib/ui/
├── dashboard/
│   └── dashboard_screen.dart
├── onboarding/
│   └── onboarding_screen.dart
├── radar/
│   └── radar_screen.dart
├── settings/
│   └── settings_screen.dart
└── widgets/
    ├── aqi_card.dart
    ├── humidity_card.dart
    ├── radar_card.dart
    ├── uvi_card.dart
    ├── weather_card.dart
    ├── weather_illustration.dart
    └── wind_card.dart
```

## Theme

`lib/theme/app_theme.dart` — `KaloColors`, `SkyGradients`, `FrostedGlass` reusable widget.

- **Frosted glass cards**: `FrostedGlass` wrapper with `BackdropFilter` blur
- **Sky background**: `Container` with `BoxDecoration(gradient: SkyGradients.*)` — not a stack layer

## Weather illustrations

`lib/ui/widgets/weather_illustration.dart` — `CustomPainter`-based, **no PNG/SVG assets** for weather icons.

## Data-flow UI signals

- `isFallbackProvider` signals which API path is active → shown as orange banner in UI

## Widget cards

Each metric has its own card widget in `lib/ui/widgets/`:
- `aqi_card.dart`, `humidity_card.dart`, `uvi_card.dart`, `wind_card.dart`
- `weather_card.dart` — main current-conditions card
- `radar_card.dart` — radar map card

## Conventions

- Widget previews via `@Preview()` annotation from `package:flutter/widget_previews.dart` — scattered across widgets for dev hot-reload
- `convertTemp()` / `tempUnit()` helpers in `weather_service.dart:78-84` for Celsius↔Fahrenheit
- `WeatherCondition` enum (`lib/models/weather_condition.dart`) with extension `.label` and `.isSevere`
