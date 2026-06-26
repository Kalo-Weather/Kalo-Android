Kalo Weather: Frontend Design DocumentThis document represents the complete visual, interface, and layout specifications for the Kalo Weather mobile app and Wear OS companion. It defines the design language, gesture mechanics, system themes, and screen flows.Table of ContentsDesign System & Aesthetic TokensModular Dashboard LayoutsDynamic Illustration SpecificationsCustomizable Gesture & Navigation ParadigmsOnboarding & Setup Interface FlowWear OS Smartwatch Interface Specs1. Design System & Aesthetic TokensKalo’s primary aesthetic goal is a hybrid of Overdrop’s clean, illustrative typography and Apple Weather’s content-rich, layered glassmorphic grids.┌────────────────────────────────────────────────────────┐
│                      VISUAL DEPTH                      │
├────────────────────────────────────────────────────────┤
│ Layer 1: Sky Gradient (Dynamic, based on time/weather) │
│   └─ Layer 2: Frosted Glass Cards (White/10% opacity)  │
│        └─ Layer 3: High-Contrast Minimalist Typography │
└────────────────────────────────────────────────────────┘
1.1 Palette & Color ArchetypesAmoled Dark (System & Watch): #000000 (Enforced absolute black) to save screen battery on Wear OS and OLED phones.Frosted Glass Fill: White at 10% opacity (rgba(255,255,255,0.1)) with a 20px background blur filter and a 1px thin border at 15% opacity.Typography Base: High-contrast pure white (#FFFFFF) for primary content, and muted slate-gray/silver (rgba(255,255,255,0.6)) for labels.1.2 Dynamic Ambient BackgroundsThe mobile app’s background is a smooth vertical gradient that shifts dynamically:Clear Sunny Day: Sky-blue to deep cobalt.Stormy Weather: Dark ash-gray to twilight slate.Clear Night: Ink-black to midnight purple.Golden Hour: Deep amber to soft violet.2. Modular Dashboard LayoutsThe weather metrics are organized inside an adaptive grid of card widgets with standard sizes (1x1, 2x1, or 2x2) based on content priority.┌────────────────────────────────────────────────────────┐
│                 [ Location Dropdown ▼ ]                │
├────────────────────────────────────────────────────────┤
│                      Hero Section                      │
│                  Dynamic Illustration                  │
│                         72°                            │
│                    Partly Cloudy                       │
├────────────────────────────┬───────────────────────────┤
│ [☼ UV Index Card] (1x1)    │ [⚏ AQI Progress Card] (1x1)│
├────────────────────────────┴───────────────────────────┤
│ [༄ Wind Radar & Compass Card] (2x1)                    │
├────────────────────────────┬───────────────────────────┤
│ [💧 Humidity Scale] (1x1)  │ [☁ Precipitation Map] (1x1)│
└────────────────────────────┴───────────────────────────┘
2.1 Hero Panel (Header)Title: Large, bold location label accompanied by a subtle drop-down indicator.Temperature Display: Expressive, ultra-large text weight with a soft drop-shadow.Status Label: Current weather condition description and a simple high/low temperature display.2.2 Core Utility CardsUV Index Card (1x1): Features a glowing semi-circular scale that visually maps the current threat level (Low to Extreme) and displays a quick sun-protection tip.Air Quality Card (1x1): Features a horizontal color-gradient progress bar (from green to dark red) pointing to the current local air index, with a sub-label highlighting dominant pollutants.Wind Compass Card (2x1): Displays a visual circular compass with a dynamic wind-pointer. It shows current speed, direction, and gust values in the center.Humidity Card (1x1): Uses an animated water-droplet meter that fills dynamically based on humidity levels, showing the localized dew point below.Precipitation Radar Card (2x2 / Full Screen): An interactive, embedded map card. Tapping it expands the card into a full-screen viewport where users can pinch-to-zoom, pan, and play looping animated rain/snow radar timelines.3. Dynamic Illustration SpecificationsWeather illustrations update dynamically to reflect the current weather, time of day, and severity of the conditions.Weather ConditionDay VariantNight VariantExtra Severity ElementClear SkyWarm golden sun with soft radiating haloSilver crescent moon with glowing starsNoneRainySoft white cloud with falling diagonal raindropsDark blue cloud with stylized rainLightning bolts for heavy stormsSnowyWhite cloud with drifting, soft hexagonal flakesDark cloud with bright, crystalline starsDrifting wind lines for blizzard statesFoggyStylized horizontal white mist bandsGray mist bands obscuring a dim moonThick, dense layered haze vectors4. Customizable Gesture & Navigation ParadigmsKalo offers two navigation styles. Users can select their preferred direction layout in the Settings Hub.PARADIGM A: Location Carousel (Default)
[Swipe Left / Right]  ───> Switches Cities / Locations
[Scroll Up / Down]    ───> Reveals Detailed Weather Cards

PARADIGM B: Stack View (Data Carousel)
[Swipe Left / Right]  ───> Switches Weather Cards (Detail Pages)
[Scroll Up / Down]    ───> Switches Cities / Locations
Anchor Point: The persistent Top Dropdown Menu acts as a global navigational anchor. Regardless of the active paradigm, tapping the top dropdown instantly opens a neat list of saved locations, allowing users to jump directly to any city.5. Onboarding & Setup Interface FlowBecause Kalo runs on a privacy-first, zero-telemetry architecture, the onboarding process is designed to be informative, friendly, and visually stunning.Step 1: Welcome Screen
└─ Step 2: Privacy Agreement & Location Permission
└─ Step 3: Local Cryptographic Key Creation Info
└─ Step 4: Proxy Connection & API Selection
└─ Step 5: Interface Gesture Customization
Welcome & Style Pitch: Displays a beautiful loop of weather animations showing off the app's clean vector graphics.Privacy & Location Choice: Clearly explains why Kalo has no ads or trackers, then lets the user grant location permission (Coarse for general area, or Fine for exact weather).Key Creation Explanation: Displays a fun, graphic illustration explaining how Kalo generates a private encryption key bound strictly to their phone's hardware model and serial ID.Proxy & API Selection: Allows users to sign in with their Google or email account to connect to the secure proxy. They can choose to add their private API keys or use the free, open fallback option.Interactive Navigation Toggle: Shows two small interactive animations demonstrating Paradigm A and Paradigm B, letting users pick their layout preference before they start using the app.6. Wear OS Smartwatch Interface SpecsThe smartwatch application is optimized for low-battery consumption, clear visibility on small round watch faces, and quick glanceability.┌────────────────────────┐
│      12:00 PM  ⌚      │
├────────────────────────┤
│      New York          │
│        72°             │
│   Partly Cloudy        │
├────────────────────────┤
│  ☼ UV: 6 (High)        │
│  ༄ Wind: 12 mph NW     │
│  💧 Humid: 45%         │
└────────────────────────┘
6.1 Layout & Visual HierarchyAMOLED True Black: Absolute black backgrounds (#000000) are used globally to save battery.Single-Column Scroll: All elements are organized in a clean, vertically-scrolling list with generous margins to prevent text clipping on round screens.High-Contrast Text: Primary weather info is written in large, high-visibility white text, paired with neon-colored icons (yellow for sun, blue for rain, green for AQI).6.2 Watch Face Tiles & ComplicationsGlanceable Tiles: Horizontal swipable watch face tiles displaying current temperatures, visual forecast graphs, and quick weather updates.Custom Complications: Standard circular and modular complications showing real-time UV indexes, current temperature readouts, and weather icon states.