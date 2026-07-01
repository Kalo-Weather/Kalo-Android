# Kalo Weather — UI Reference

## 1 Navigation

Three screens pushed via `MaterialPageRoute` with no named routes:

| From | To | Trigger |
|------|----|---------|
| Dashboard → Settings | `SettingsScreen` | Nav bar gear icon |
| Dashboard → Radar | `RadarScreen` | Tap radar card |
| Settings → Widget Editor | `WidgetEditorScreen` | "Customize Widgets" tile |

Onboarding → Dashboard uses `pushReplacement` once completed.

Location switching within the dashboard uses a page-based carousel controlled by `NavigationParadigm` (`locationCarousel` / `stackView` — currently identical).

---

## 2 Screens

### 2.1 Dashboard (`dashboard_screen.dart`)

```
Stack
  ├── SkyGradient background (determined by WeatherCondition + time of day)
  ├── Weather animation overlay (optional, toggleable)
  └── SafeArea
      ├── Location bar: name (tap to pick), nav arrows, settings icon
      ├── Fallback banner (orange, shown when proxy is unreachable)
      ├── Alert banner (red/orange for severe weather)
      └── ScrollView
          ├── Hero section: large icon, temperature (72px), condition label, hi/lo
          ├── Card grid (2-col LayoutBuilder)
          │   ├── UV Index + Air Quality
          │   ├── Wind (full-width compass)
          │   ├── Humidity + Real Feel
          │   ├── Radar (full-width, navigates to RadarScreen)
          │   ├── Hourly Forecast (horizontal scroll, 8 items)
          │   └── 7-Day Forecast (expandable rows with temp bars + hourly details)
```

Day/night detection uses `DateTime.now().hour` (6 AM — 8 PM = day).

### 2.2 Onboarding (`onboarding_screen.dart`)

5-step `PageView`:

| # | Step | Action |
|---|------|--------|
| 0 | Welcome | "Get Started" |
| 1 | Privacy | Request location permission |
| 2 | Key Creation | Device-bound encryption setup |
| 3 | API Selection | Free Open-Meteo or custom keys |
| 4 | Navigation Choice | Carousel vs Stack View |

### 2.3 Settings (`settings_screen.dart`)

| Section | Controls |
|---------|----------|
| Navigation | Choice chips: Location Carousel / Stack View |
| Units | Dropdowns: Temperature, Time Format |
| Display | Toggles: Animated Background, Auto-Refresh Widgets, Now Bar |
| API Keys | Set/Not set badges for OpenWeatherMap, WAQI |
| Proxy Server | Custom URL dialog |
| Updates | "Check for Updates" → tap shows UpdateDialog |
| Saved Locations | Add/edit/delete saved weather locations |

### 2.4 Radar (`radar_screen.dart`)

Full-screen `FlutterMap` with CartoDB dark basemap + RainViewer tile overlay. Centers on GPS position.

### 2.5 Update Dialog (`update_dialog.dart`)

States: `available → downloading → ready → installed`. Linear progress bar with percentage, real streaming download with cancel support, Install button calls native MethodChannel `com.kalo.mobile/apk_install`.

### 2.6 Widget Editor (`widget_editor_screen.dart`)

Segmented size selector (Small / Medium / Large) + block palette to add/remove/reorder widget blocks. Preview renders a mock widget matching the real Android widget dimensions.

---

## 3 Animated Background

Behind the dashboard content, an optional `WrapperScene` from the `weather_animation` package overlays the sky gradient. Togglable via Settings → Display → Animated Background (persisted to `SharedPreferences` via `animatedBackgroundProvider`).

### Scene mapping (`_sceneForCondition`)

| Condition | Scene |
|-----------|-------|
| `clearSky` | `WeatherScene.scorchingSun` |
| `cloudy`, `foggy` | `WeatherScene.rainyOvercast` |
| `rainy` | `WeatherScene.rainyOvercast` |
| `snowy` | `WeatherScene.snowfall` |
| `stormy` | `WeatherScene.stormy` |

The animation layer sits between the sky gradient `Container` and the `SafeArea` in the `Stack`. It's wrapped in `TickerMode` / `Opacity` / `IgnorePointer` / `RepaintBoundary` — fully interactive elements below are never blocked. Disabling the toggle hides the layer with 0 opacity but keeps `TickerMode` off to save resources.

---

## 4 Card Widgets

All cards are wrapped in `WeatherCard` (frosted glass container with icon + title row).

| Card | File | Visual | Data Source |
|------|------|--------|-------------|
| UV Index | `uvi_card.dart` | Semi-circle arc gauge (green→purple) + numeric value + protection tip | `UVIndex` model |
| Air Quality | `aqi_card.dart` | Large number + gradient progress bar + pollutant label | `AirQuality` model |
| Wind | `wind_card.dart` | Compass ring with directional arrow + speed + gusts | `WindData` model |
| Humidity | `humidity_card.dart` | Droplet shape fill (proportional) + dew point | `humidity` double |
| Real Feel | `real_feel_card.dart` | Circular thermometer gauge + temp + ±diff badge | `apparentTemperature` |
| Radar | `radar_card.dart` | Icon + "Tap to view" placeholder (dark container) | `radarFrameProvider` |

---

## 5 Theme (`app_theme.dart`)

### SkyGradients

| Gradient | Colors | Used for |
|----------|--------|----------|
| `clearDay` | `#4A90D9` → `#1A3A6B` | clearSky (day) |
| `cloudy` | `#6B7B8D` → `#3A4A5C` | cloudy (day), fallback |
| `stormy` | `#2C2C2C` → `#1A1A2E` | stormy, rainy |
| `clearNight` | `#0D0D1A` → `#1A0A2E` | Nighttime |
| `snowy` | `#B0C4DE` → `#778899` | snowy |
| `foggy` | `#8B8B8B` → `#5A5A5A` | foggy |

### KaloColors

| Token | Hex | Use |
|-------|-----|-----|
| `amoledDark` | `#000000` | Scaffold background |
| `frostWhite` | `#1AFFFFFF` | Translucent card fill |
| `frostBorder` | `#26FFFFFF` | Card borders |
| `primaryText` | `#FFFFFF` | Main text |
| `secondaryText` | `#99FFFFFF` | Dimmed text |
| `frostFill` | `#1AFFFFFF` | Settings tile fill |

### FrostedGlass

Wrapper widget: dark translucent background (`#40000000`), 20px radius, white border at 15% opacity. Used by all cards, the hourly forecast, and daily forecast.

---

## 6 Weather Conditions (`weather_condition.dart`)

| Enum | Emoji | Label | Severe |
|------|-------|-------|--------|
| `clearSky` | ☀️ | Clear Sky | No |
| `cloudy` | ☁️ | Cloudy | No |
| `foggy` | 🌫️ | Foggy | No |
| `rainy` | 🌧️ | Rainy | No |
| `snowy` | ❄️ | Snowy | No |
| `stormy` | ⛈️ | Stormy | **Yes** |

Mapped from proxy `illustrationCode` strings (`sun`, `cloud-sun`, `cloud`, `rain`, etc.) via `_conditionStringToEnum()`. Also derived from WMO weather codes via `weatherCodeToCondition()`.

---

## 7 Custom Painters

All weather visuals are `CustomPainter` subclasses — no PNG/SVG assets:

| Painter | File | Shape | Used in |
|---------|------|-------|---------|
| `_UVSemiCirclePainter` | `uvi_card.dart` | Semi-circular arc, gradient stroke | UV Index card |
| `_DropletPainter` | `humidity_card.dart` | Water droplet outline + fill | Humidity card |
| `_CompassPainter` | `wind_card.dart` | Circle ring + directional arrow | Wind card |
| `_ThermometerPainter` | `real_feel_card.dart` | Circle arc (orange/blue sweep) | Real Feel card |

---

## 8 Provider Tree (key overrides at app root)

```
ProviderScope (main.dart)
  ├── onboardingCompletedProvider → bool
  ├── databaseServiceProvider → DatabaseService
  ├── deviceServiceProvider → DeviceService  
  ├── notificationServiceProvider → NotificationService
  ├── configStatusProvider → ConfigStatus
  ├── unitPreferenceProvider → 'Celsius' | 'Fahrenheit'
  ├── timeFormatProvider → '24h' | '12h'
  ├── nowBarEnabledProvider → bool
  └── widgetRefreshEnabledProvider → bool
```

All providers are flat (no repository pattern). Services exposed via `Provider`/`FutureProvider`/`StateProvider`/`StateNotifierProvider`.

---

## 9 Wear OS (`main_wear.dart`)

Separate entry point (`flutter run -t lib/main_wear.dart`). `WearDashboard` shows:

- Current time (24h format)
- Location name
- Large temperature (48px) + condition icon + label
- 4 info rows: UV Index (yellow), Wind (blue), Humidity (green), AQI (green)

Each row is a `_WearInfoRow`: rounded container with thin border, colored icon, label + value.

---

## 10 Weather Icons

Custom icon font in `lib/weather_icons/` — uses `WeatherIcons` class with mapped constants (`day_sunny`, `cloudy`, `rain`, `snow`, etc.) rendered via `BoxedIcon` widget (centered `RichText` with `TextSpan`).

---

## 11 File Map

```
lib/
├── main.dart                          # Phone entry
├── main_wear.dart                     # Wear OS entry
├── theme/app_theme.dart               # KaloColors, SkyGradients, FrostedGlass
├── weather_icons/
│   ├── weather_icons.dart             # Icon constants
│   └── boxed_icon.dart                # Icon renderer
├── models/                            # ProxyWeather, WeatherCondition, WindData, etc.
├── services/                          # All providers + data fetching + background
└── ui/
    ├── dashboard/dashboard_screen.dart
    ├── onboarding/onboarding_screen.dart
    ├── settings/settings_screen.dart
    ├── radar/radar_screen.dart
    ├── update/update_dialog.dart
    ├── widget_editor/
    │   ├── widget_editor_screen.dart
    │   └── widget_preview.dart
    └── widgets/
        ├── weather_card.dart          # Card container
        ├── uvi_card.dart              # UV Index arc gauge
        ├── aqi_card.dart              # Air Quality bar
        ├── wind_card.dart             # Wind compass
        ├── humidity_card.dart         # Humidity droplet
        ├── real_feel_card.dart        # Feels-like thermometer
        └── radar_card.dart            # Radar placeholder
```
