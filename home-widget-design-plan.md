# Home Screen Widget — Design Plan
**Weather app · Apple × Overdrop · data piped via `home_widget`**

## Platform constraint
`liquid_glass_widgets` renders inside the running Flutter app/engine; OS home-screen widgets
render outside it (SwiftUI/WidgetKit on iOS, Glance/RemoteViews on Android). `home_widget`
doesn't draw the widget — it ferries data from Flutter to native widget code and tells the
OS to refresh it. So this plan splits into a shared data contract and two native visual
implementations.

## 1. Data contract (Flutter → native, via `HomeWidget.saveWidgetData`)
| Key | Notes |
|---|---|
| `temp` | e.g. `"72°"` |
| `condition` | e.g. `"Sunny"` |
| `conditionCode` | enum-like string: `clearDay`, `clearNight`, `cloudy`, `rain`, `storm` — picks the gradient |
| `high`, `low` | |
| `location` | |
| `hourly` | small JSON array, capped at 6 entries (time, temp, conditionCode) — medium/large only |
| `lastUpdated` | optional caption, e.g. "as of 2:14 PM" |

Flutter calls `HomeWidget.updateWidget(...)` after each fetch (or on a background refresh
schedule) to trigger the native redraw.

## 2. Sizes & content hierarchy

**Small (2×2)**
```
╭──────────────╮
│ ☀  72°        │   icon + temp, top-aligned
│ Bangor        │   location, small caption
│ Sunny         │   condition, small caption
╰──────────────╯
```
One glass-style panel, no nested elements.

**Medium (4×2)**
```
╭──────────────────────────────╮
│ Bangor                  ☀     │
│ 72°  Sunny                   │
│ H:78° L:61°  ·  hourly strip  │  4-6 small hour pills, static (no scroll)
╰──────────────────────────────╯
```

**Large (4×4)**
```
╭──────────────────────────────╮
│ Bangor                  ☀     │
│ 72°                           │
│ Sunny · H:78° L:61°           │
│ ── hourly row (6 pills) ──    │
│ ── 3-day mini list ──         │
╰──────────────────────────────╯
```

## 3. Visual treatment, translated to native constraints
- **Background:** gradient picked from `conditionCode`, rendered natively —
  `LinearGradient`/`RadialGradient` in SwiftUI; a `GradientDrawable` in Android Glance.
- **Glass panel:** neither widget surface supports a live blur shader, so approximate per
  platform:
  - **iOS:** SwiftUI `.background(.ultraThinMaterial)` over the gradient — Apple's own
    native frosted glass, arguably more "correct" here than porting the Flutter shader.
  - **Android:** semi-transparent white overlay (~14% alpha) with a 1px hairline border —
    Glance has no native blur, but flat translucency reads close enough at widget scale.
- **Type:** ultralight numeral style — SF Pro on iOS widgets is automatic; on Android
  Glance, pick a comparably thin system font weight.
- **Corner radius:** match each OS's own widget convention rather than the in-app radius
  (iOS ~22pt continuous corner, Android adaptive per launcher) — "feels native" matters more
  here than internal consistency with the app.

## 4. What stays unified across platforms
Only the tokens — gradient colors per `conditionCode`, type scale, and the small/medium/large
content hierarchy. The rendering code is necessarily two separate native implementations,
tied together by the same Flutter-side data contract.

## 5. No live animation
Home-screen widgets render static snapshots (WidgetKit / Glance both re-render periodically,
not continuously). The "alive sky" stays inside the app; the widget gets a fresh static
gradient + cloud illustration baked in at each refresh, so it still feels like a still frame
of the same living sky.
