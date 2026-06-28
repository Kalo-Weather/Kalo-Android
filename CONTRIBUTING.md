# Contributing to Kalo Weather

Thank you for considering contributing to Kalo Weather! This project is open-source and community-driven.

## Code of Conduct

Please be respectful and constructive in all interactions. This project follows a standard open-source code of conduct.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/Kalo-Weather/Kalo-Android/issues).
2. If not, open a new issue with:
   - A clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Device/OS version and Flutter version
   - Screenshots if applicable

### Suggesting Features

Open an issue with the `enhancement` label describing:
- The problem your feature solves
- How the feature should work
- Any alternatives you've considered

### Pull Requests

1. **Fork** the repository.
2. **Create a branch**: `git checkout -b feature/my-feature` or `fix/my-fix`.
3. **Make your changes** following the project conventions:
   - No comments in code (follow existing style)
   - Use Riverpod for state management
   - Use `FrostedGlass` for card surfaces
   - Use `SkyGradients` for backgrounds
   - Use `BoxedIcon` + `WeatherIcons` for weather icons
4. **Run analysis**: `flutter analyze` (must pass with no errors).
5. **Run tests**: `flutter test` (must pass).
6. **Commit** with a clear message describing the change.
7. **Push** and open a Pull Request.

### Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/Kalo-Android.git
cd Kalo-Android

# Install dependencies
flutter pub get

# Create .env (see .env.example)
cp .env.example .env

# Run the app
flutter run
```

### Project Structure

```
lib/
├── main.dart                # App entry point
├── main_wear.dart           # Wear OS companion
├── models/                  # Data models
├── services/                # Business logic + Riverpod providers
├── theme/                   # Colors, gradients, glass widgets
├── ui/
│   ├── dashboard/           # Main weather screen
│   ├── onboarding/          # First-launch walkthrough
│   ├── radar/               # Interactive weather radar
│   ├── settings/            # Settings screen
│   └── widgets/             # Reusable card components
└── weather_icons/           # Custom icon font + helper
```

### Style Guide

- **State management**: Riverpod (`Provider`, `FutureProvider`, `StateNotifierProvider`)
- **No comments** in production code (follow existing convention)
- **Theming**: Use `KaloColors`, `SkyGradients`, `FrostedGlass` from `app_theme.dart`
- **Weather data**: Always go through `ProxyWeatherResponse` model — it's the central data contract
- **API keys**: Encrypt with `encryptLocalKey`/`decryptLocalKey` before storage; use `encryptForProxy` for proxy transmission

### Good First Issues

Look for issues labeled `good-first-issue` in the [issue tracker](https://github.com/Kalo-Weather/Kalo-Android/issues). These are great starting points:

1. Improve error handling when location permission is denied
2. Add loading shimmer effects to weather cards
3. Implement proper 7-day forecast from Open-Meteo
4. Add haptic feedback to interactive elements
5. Improve accessibility (screen reader labels)
6. Add portrait/landscape layout adaptation
7. Implement pull-to-refresh on dashboard
8. Add weather alert notification scheduling
