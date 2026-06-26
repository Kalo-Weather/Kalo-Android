# Home Screen — Design Plan
**Weather app · Apple × Overdrop · built on `liquid_glass_widgets`**

## Subject & job
Daily-glance iOS-style weather app. Job: tell the person the temperature and whether to grab a jacket in 5 seconds; reward a longer look with detail.

## 1. Color tokens (sky gradients, not flat colors)
| Token | Gradient |
|---|---|
| `skyClearDay` | #4FA8F0 → #8FD0F2 → #EAF6FB |
| `skyClearNight` | #0B1026 → #1B2A4A → #2E3A59 |
| `skyCloudy` | #6E7C91 → #9AA7B8 → #C7CFDA |
| `skyRain` | #2C3A4A → #44566B → #6B7C8E |
| `skyStorm` | #1A1F2C → #2C3142 → #3D4255 |
| `ink` | white (primary text on every sky) |

## 2. Type
- SF Pro (Flutter's default system font on iOS) — no second decorative face.
- Hero temperature: Display weight 100/200, ultralight, ~96pt, tight tracking — the one place size carries personality.
- Body/labels: weight 400/600, standard tracking.

## 3. Layout
```
GlassAppBar (premium) — location, sentence case
        ☀ animated icon
         72°            ← ultralight hero
        Sunny
      H:78°  L:61°
╭─ hourly strip ─────────╮  GlassCard, quality: standard
│ scrolls horizontally    │  (inside ListView → must stay standard, not premium)
╰─────────────────────────╯
╭─ 7-day forecast ───────╮  GlassCard, quality: standard
│ row · row · row ...     │
╰─────────────────────────╯
╭ UV ╮ ╭ Wind ╮            GlassCard grid, quality: minimal
╭ Humidity ╮ ╭ Pressure ╮  (background tiles, zero shader cost)
```

## 4. The signature element
The sky itself is the refraction source, not a static wallpaper. Using
`LiquidGlassScope.stack(background: <animated sky>, content: <Scaffold with all glass widgets>)`,
every glass surface bends and tints based on the *live, animating* sky behind it — clouds
drifting, gradient slowly shifting with time/condition. This fuses the Overdrop atmosphere
with literal Apple Liquid Glass refraction, rather than faking a blur.

## 5. Glass quality mapping
| Surface | Quality | Why |
|---|---|---|
| App bar (location) | `premium` | static, fixed |
| Hero card (temp) | `premium` | static, focal — full shader treatment |
| Hourly strip | `standard` | inside a scroll view — premium misbehaves there |
| 7-day list | `standard` | same reason |
| Detail tiles (UV / wind / humidity / pressure) | `minimal` | background-ish, saves GPU budget for the hero |

## 6. Glass tuning
- Specular sharpness: `soft` on most cards (calmer, frosted read); `medium` only on the hero
  card, where the eye actually lands.
- Theme: one `GlassThemeData` with day vs. night `GlassThemeVariant` — thicker/more opaque
  glass at night, lighter by day — driven automatically by the active sky token.

## 7. Motion
- Slow, looping ambient sky animation (gradient position drift + translucent cloud shapes) —
  the only animation that's always running.
- Everything else (icon transitions, card entrances) stays calm and Apple-quiet; no scattered
  micro-animations competing with the sky.
