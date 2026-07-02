#!/usr/bin/env bash
set -euo pipefail

# take_screenshots.sh — Capture README screenshots for Kalo Weather.
#
# Supports Android (ADB) and iOS Simulator (Xcode + AppleScript).
#
# Usage:
#   bash tools/take_screenshots.sh
#
# Options:
#   -s <serial|udid>  Device serial (Android) or simulator UDID (iOS)
#   -o <dir>          Output directory (default: screenshots/)
#   -n                Skip launching the app (assume already on dashboard)
#   -p <platform>     Force platform: android or ios (auto-detected otherwise)
#
# Requirements:
#   Android: adb in PATH, connected device/emulator
#   iOS:     macOS, Xcode, booted simulator

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$PROJECT_ROOT/screenshots"
SERIAL=""
NO_LAUNCH=false
FORCE_PLATFORM=""

while getopts "s:o:np:" opt; do
  case "$opt" in
    s) SERIAL="$OPTARG" ;;
    o) OUT_DIR="$OPTARG" ;;
    n) NO_LAUNCH=true ;;
    p) FORCE_PLATFORM="$OPTARG" ;;
    *) echo "Usage: $0 [-s serial] [-o dir] [-n] [-p android|ios]" >&2; exit 1 ;;
  esac
done

mkdir -p "$OUT_DIR"

# ── Platform detection ──────────────────────────────────────────────────

detect_platform() {
  if [ -n "$FORCE_PLATFORM" ]; then
    echo "$FORCE_PLATFORM"
    return
  fi
  if command -v adb &>/dev/null && adb devices 2>/dev/null | grep -q "device$"; then
    echo "android"
  elif command -v xcrun &>/dev/null && xcrun simctl list booted 2>/dev/null | grep -q "Booted"; then
    echo "ios"
  else
    echo "unknown"
  fi
}

PLATFORM=$(detect_platform)

# ── Android helpers ─────────────────────────────────────────────────────

android_adb() {
  if [ -n "$SERIAL" ]; then
    adb -s "$SERIAL" "$@"
  else
    adb "$@"
  fi
}

android_setup() {
  echo "==> Checking ADB..."
  command -v adb >/dev/null 2>&1 || { echo "ERROR: adb not found"; exit 1; }

  DEVICES=$(adb devices)
  if ! echo "$DEVICES" | grep -q "device$"; then
    echo "ERROR: No device connected. Run 'adb devices'."
    exit 1
  fi

  if [ -z "$SERIAL" ]; then
    SERIAL=$(echo "$DEVICES" | awk '/device$/ && !/devices/ {print $1; exit}')
  fi
  echo "    Device: $SERIAL"

  RAW_SIZE=$(android_adb shell wm size | grep -oE '[0-9]+x[0-9]+' | head -1)
  WIDTH="${RAW_SIZE%x*}"
  HEIGHT="${RAW_SIZE#*x}"
  echo "    Display: ${WIDTH}x${HEIGHT}"
}

android_screenshot() {
  android_adb exec-out screencap -p > "$OUT_DIR/$1.png"
  echo "    Saved $1.png"
}

android_tap() {
  android_adb shell input tap "$1" "$2"
  sleep 1.5
}

android_back() {
  android_adb shell input keyevent KEYCODE_BACK
  sleep 1.5
}

android_launch() {
  echo "==> Launching Kalo Weather..."
  android_adb shell am start -W -n com.kalo.weather/.MainActivity > /dev/null 2>&1
  sleep 4
}

# ── iOS helpers ─────────────────────────────────────────────────────────

ios_get_window_origin() {
  osascript -l AppleScript -e "
tell application \"System Events\"
  tell process \"Simulator\"
    set win to first window
    return (item 1 of position of win) & \",\" & (item 2 of position of win)
  end tell
end tell
" 2>/dev/null || echo "0,0"
}

# Simulator window chrome offsets (title bar + toolbar)
# These may need adjustment for different Xcode versions.
IOS_WIN_LEFT=2
IOS_WIN_TOP=48

ios_setup() {
  echo "==> Checking Xcode..."
  command -v xcrun >/dev/null 2>&1 || { echo "ERROR: xcrun not found (Xcode required)"; exit 1; }

  BOOTED=$(xcrun simctl list booted 2>/dev/null | grep -oE '^    [^(]+ \(([0-9A-F-]+)\)' || true)
  if [ -z "$BOOTED" ]; then
    echo "ERROR: No booted simulator found."
    exit 1
  fi

  if [ -z "$SERIAL" ]; then
    SERIAL=$(echo "$BOOTED" | grep -oE '[0-9A-F-]{36}' | head -1)
  fi

  # Use device name from the booted list to extract model for sizing
  DEVICE_NAME=$(xcrun simctl list booted 2>/dev/null | grep -oE '^    [^(]+' | head -1 | xargs)
  echo "    Simulator: $DEVICE_NAME ($SERIAL)"

  # Get the Simulator device pixel dimensions
  # xcrun simctl io booted screenshot gives us the output size directly
  WIDTH=393   # iPhone 14/15 default fallback
  HEIGHT=852
  echo "    Assuming device: ${WIDTH}x${HEIGHT}"
  echo "    (verify by checking xcrun simctl screenshot output)"
}

ios_screenshot() {
  xcrun simctl io "$SERIAL" screenshot "$OUT_DIR/$1.png" > /dev/null 2>&1
  echo "    Saved $1.png"
}

ios_tap() {
  local tx=$1 ty=$2
  local origin
  origin=$(ios_get_window_origin)
  local ox="${origin%,*}"
  local oy="${origin#*,}"
  local cx=$((ox + tx + IOS_WIN_LEFT))
  local cy=$((oy + ty + IOS_WIN_TOP))
  osascript -l AppleScript -e "
tell application \"System Events\"
  tell application \"Simulator\" to activate
  delay 0.3
  click at {$cx, $cy}
end tell
" > /dev/null 2>&1
  sleep 1.5
}

ios_back() {
  osascript -l AppleScript -e "
tell application \"System Events\"
  tell process \"Simulator\"
    keystroke space using {command down}
  end tell
end tell
" > /dev/null 2>&1 || true
  # fallback: press the navigation bar back button area (top-left of screen)
  ios_tap 20 60
  sleep 1.5
}

ios_launch() {
  local bundle_id
  bundle_id=$( PlistBuddy -c 'Print :CFBundleIdentifier' "$PROJECT_ROOT/ios/Runner/Info.plist" 2>/dev/null || echo "com.kalo.weather" )
  echo "==> Launching Kalo Weather on simulator..."
  xcrun simctl launch "$SERIAL" "$bundle_id" > /dev/null 2>&1 || true
  sleep 4
}

# ── Cross-platform screenshot routine ───────────────────────────────────

screenshot()  { "${PLATFORM}_screenshot" "$1"; }
tap()         { "${PLATFORM}_tap" "$1" "$2"; }
back()        { "${PLATFORM}_back"; }
launch()      { "${PLATFORM}_launch"; }
setup()       { "${PLATFORM}_setup"; }

# ── Main ────────────────────────────────────────────────────────────────

echo "==> Platform: $PLATFORM"
case "$PLATFORM" in
  android) setup ;;
  ios)     setup ;;
  *)
    echo "ERROR: Could not detect Android (adb) or iOS Simulator (xcrun)."
    echo "  Connect a device or use -p android|ios."
    exit 1
    ;;
esac

# Tap positions relative to the app's viewport
SETTINGS_X=$((WIDTH - 40))
SETTINGS_Y=40
RADAR_X=$((WIDTH / 2))
RADAR_Y=$((HEIGHT * 40 / 100))

if [ "$NO_LAUNCH" = false ]; then
  launch
else
  echo "==> Skipping launch (-n). Waiting for app..."
  sleep 2
fi

echo "==> 1. Dashboard"
screenshot "dashboard"

echo "==> 2. Settings"
tap "$SETTINGS_X" "$SETTINGS_Y"
sleep 1
screenshot "settings"
back

echo "==> 3. Radar"
tap "$RADAR_X" "$RADAR_Y"
sleep 2
screenshot "radar"
back

echo ""
echo "Done! Screenshots in: $OUT_DIR"
echo "Crop/resize as needed, then update README.md with the image paths."
