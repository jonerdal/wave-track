# WaveTrack — Implementation Notes

Wave Track is a Garmin activity used for wave surfing.

This document is the working project board. Open it at the start of each session to see what's pending, in progress, and done. It also captures the "why it's shaped this way" for decisions that aren't obvious from the code.

For domain vocabulary, see `CONTEXT.md`. For the app spec, see `docs/SPEC.md`. For platform research, see `docs/RESEARCH.md`.

---

## Investigate / Revisit

### Stop flow: double-press direct vs. single-press confirmation step

Currently a double-press on the action button stops the session immediately and goes straight to Summary. An alternative: single press opens a "Stop session?" confirmation screen, double-press there confirms and saves, back button returns to the active recording.

Trade-off: the current flow is fast but irreversible mid-press. The confirmation step adds safety but an extra screen.

**2026-07-04 update:** Real-world sessions did terminate mid-surf, but the root cause was touch, not the double press: `ActiveDelegate` extended `BehaviorDelegate`, which maps screen taps to `onSelect` — water on the touchscreen produced phantom double-presses (user confirmed a stop with no button contact). Fixed by switching all delegates to `InputDelegate` (see Done). Confirmation step stays parked until a water re-test shows the *physical* double press also misfires. If built: note the simulator can't test long press, a 5s hold needs hand-rolled `onKeyPressed`/`onKeyReleased`, and long holds may collide with Venu OS button shortcuts.

---

## Up Next

### Revisit Summary layout — too crowded

The post-redesign Summary screen is functional but doesn't look great. Observed on device/sim:
- Fonts/text are too big overall — the `FONT_NUMBER_HOT` time hero plus divider plus the two stat columns is too much for the round face.
- The centered stat group **overlaps the save/discard hint icons** (green checkmark, red bin) on the right edge.

Not solving now — parked as good-enough. When revisited, levers (see `docs/DESIGN.md`): drop the Summary hero from `Theme.FONT_HERO` to `Theme.FONT_VALUE`; shrink the column values; and/or narrow the centered group / reserve horizontal room so it can't collide with the button icons. The icons are hardware-anchored (Venu 4S side buttons), so the stats should yield, not the icons.

**Files to change:** `SummaryView.mc` (likely `Theme.mc`/`Layout.mc` if the fix generalizes)

---

### Timer update frequency and battery usage

**Investigation needed:** Test a full-length (~2h) session on device. The Venu 4S rated GPS battery life is ~20 hours so this is likely a non-issue, but worth confirming once before closing.

**If reducing frequency is worthwhile:** change `1000` to `5000` (ms) in `_timer.start(method(:onTick), 1000, true)` in `ActiveView.onShow()`. Updates every 5 seconds instead of every second — less smooth but readable.

**Files to change:** `ActiveView.mc`

---

## Future (v2+)

### Wave detection (v2)

Use accelerometer/gyroscope via `Toybox.Sensor`. Entry point: `Sensor.setEnabledSensors()` + `Sensor.enableSensorEvents()` in `ActiveView.onShow()`. Wave count would live on `wave_trackApp` and display on the active screen. The `Sensor` permission may need to be added to `manifest.xml`.

### Heart rate on active screen (v2)

HR is already recorded by the activity. To display it: read `Activity.getActivityInfo().heartRate` inside `ActiveView.onUpdate()`. No permission changes needed.

### Gesture-based stop (v3)

Replace or supplement double press with an arm-rotation gesture. Implementation via `Toybox.Sensor` gyroscope, pattern-matching against a defined sequence.

---

## Architecture

### Screen / state split

Each screen is a View + Delegate pair. Views own drawing and timers. Delegates own button handling and navigation. All shared session state lives in `wave_trackApp` and is accessed anywhere via `getApp()`.

```
wave_trackApp  ← session state (recordingSession, sessionStartTime, sessionEndTime, sessionDistanceMeters, sessionName)
    │
    ├── PreSessionView   + PreSessionDelegate    (pre-session screen)
    ├── ActiveView       + ActiveDelegate         (active recording screen)
    └── SummaryView      + SummaryDelegate        (post-session summary)
```

### View transitions

| From | To | Method | Reason |
|---|---|---|---|
| Pre-session | Active | `switchToView` | No going back after starting |
| Active | Summary | `switchToView` | Double press stops session and goes directly to Summary |
| Summary | Discard confirmation | `switchToView` | Back button triggers discard flow |
| Discard confirmation (cancel) | Summary | `switchToView` | User changed their mind |
| Discard confirmation (confirm) | Exit | `System.exit()` | Terminates app after discard |
| Summary | Exit | `System.exit()` | Terminates app after save |

---

## Key Decisions

### Double press to stop

The stop trigger is a double press of the action button (400ms window), not a long press. Long press was the original design but the simulator has no reliable way to test it. On device, revisit whether long press (`onMenu()`) would feel more natural — `onMenu()` is already stubbed in `ActiveDelegate`.

Double press goes directly to Summary — there is no intermediate confirmation screen. The double press itself is considered sufficient confirmation.

To change the window: `_doublePressTimer.start(method(:onWindowExpired), 400, false)` in `ActiveDelegate.mc`.

### Distance captured at stop time

`Activity.getActivityInfo().elapsedDistance` is read inside `stopSession()` and stored in `sessionDistanceMeters`. Not re-read on the summary screen — snapshotted at the moment recording stops so the value is stable regardless of when the screen renders.

### Session name from start time, not stop time

`buildSessionName()` reads `System.getClockTime().hour` inside `startSession()`. The name reflects when you paddled out, not when you finished.

### Activity recording requires no permission declaration

`ActivityRecording` is available to all `watch-app` type apps by default. No `<iq:uses-permission>` entry is needed in `manifest.xml`. The `Fit` permission (currently declared) was added by the VS Code extension automatically.

---

## Connect IQ Constraints Discovered During Build

### GPS quality API: use `Toybox.Position`, not `Toybox.Positioning`

The correct module is **`Toybox.Position`** (no `-ing`). `Toybox.Positioning` does not compile for `venu441mm`.

The following do **not** work on this device:
- `Toybox.Positioning` — does not compile
- `ActivityRecording.Session.pause()` / `.resume()` — not available
- `Activity.getActivityInfo().gpsAccuracy` — field does not exist
- `Activity.GPS_QUALITY_*` constants — not defined

What **does** work:
- `Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition))` — starts GPS updates
- `Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition))` — stops GPS
- Callback receives `Position.Info`; read `.accuracy` for: `QUALITY_NOT_AVAILABLE`, `QUALITY_LAST_KNOWN`, `QUALITY_POOR`, `QUALITY_USABLE`, `QUALITY_GOOD`
- Requires `<iq:uses-permission id="Positioning"/>` in `manifest.xml`

### `ActivityRecording` does not automatically enable GPS

`ActivityRecording.Session.start()` records data to the FIT file but does **not** turn on GPS. GPS must be explicitly enabled via `Position.enableLocationEvents` for track data to appear. If GPS events are disabled during the session, the FIT file is saved with no track — no map in Garmin Connect, distance reads as 0.

See ADR 0002 for the GPS lifecycle decision.

### Valid `manifest.xml` permission IDs

Trial-and-error results for `venu441mm` with SDK 9.1.0:

| Permission ID | Valid |
|---|---|
| `Activity` | No — rejected by manifest parser |
| `HeartRate` | No — rejected by manifest parser |
| `Sensor` | Not tested |
| `Positioning` | Yes — required for `Toybox.Position` |
| `Fit` | Yes — added by VS Code extension |

### `import Toybox.Lang` is required everywhere

`String`, `Number`, `Float`, `Boolean` all live in `Toybox.Lang`. Any file that uses type annotations must import it. The compiler error is `Cannot resolve type 'String'` which is not obviously a missing import.

---

## Done

### Summary screen — SVG bitmap button-hint icons, enlarged

Replaced the programmatically drawn checkmark/bin hint icons on Summary with the existing SVG bitmaps (`check_icon.svg`, `bin_icon.svg`), bumped from 30×30 to 40×40 (vs ~25px for the old glyphs). The earlier type blocker resolved: cast `WatchUi.loadResource()` to `Graphics.BitmapType` (not `BitmapResource?`) — SVG-sourced bitmaps may load as `BitmapReference` on newer devices, and `dc.drawBitmap()` accepts the union type. Bitmaps are centered where the old glyphs' visual centers were, so they still point at the physical buttons. Known trade-off: the extra ~15px width slightly worsens the stat-group overlap tracked under "Revisit Summary layout".

**Files changed:** `SummaryView.mc`, `check_icon.svg`, `bin_icon.svg`

---

### Disable touch on all screens (root cause of mid-session terminations)

Sessions were terminating mid-surf with no button press. Cause: `ActiveDelegate`, `PreSessionDelegate`, and `DiscardConfirmationDelegate` all extended `BehaviorDelegate`, which maps screen taps to `onSelect` — water on the touchscreen generated phantom taps, and two within 400ms stopped the session. Same bug class as the earlier Summary-screen fix. All three switched to `InputDelegate` with physical buttons wired via `onKey` (`KEY_ENTER` / `KEY_ESC`); `onTap`/`onHold`/`onSwipe` consumed. Also dropped `DiscardConfirmationDelegate.onMenu()` → discard (a long-press discard was another accidental-trigger vector). Back button still exits the app from Pre-session, is blocked on Active, and returns to Summary from Discard Confirmation. Enforces ADR 0001 app-wide.

**Files changed:** `ActiveDelegate.mc`, `wave-trackDelegate.mc`, `DiscardConfirmationDelegate.mc`

---

### Align all views with the design reference

Introduced `source/Theme.mc` (color + font-role tokens) and `source/Layout.mc` (font-metric-driven, round-only layout helpers: safe inset, top caption / bottom hint, value/stat blocks, half-width columns, divider, plus matching measurement helpers for centering). All four views (`PreSessionView`, `ActiveView`, `SummaryView`, `DiscardConfirmationView`) were rebuilt on a single shared skeleton — top caption / centered stack / bottom hint — with no hardcoded pixel coordinates. The teal-blue accent (`0x00B5C2`) is applied only to the elapsed-time hero on Active and Summary; decorative/accent arcs were deliberately deferred. Summary now shows Max Speed (km/h) beside Distance as half-width columns; `stopSession()` snapshots both `maxSpeed` and `averageSpeed` (avg stored but not shown — it's noise for surf sessions). Decisions captured in `docs/DESIGN.md`; `docs/DESIGN-RESEARCH.md` trimmed to stay generic.

**Files changed:** `source/Theme.mc` (new), `source/Layout.mc` (new), `source/wave-trackView.mc`, `source/ActiveView.mc`, `source/SummaryView.mc`, `source/DiscardConfirmationView.mc`, `source/wave-trackApp.mc`, `docs/DESIGN.md` (new), `docs/DESIGN-RESEARCH.md`, `AGENTS.md`, `CONTEXT.md`

This supersedes the earlier "Summary screen layout redesign" below. The two overlapping Up Next items folded in: "More stats on summary screen" (done) and "replace drawn icons with SVG bitmaps" (still separate/blocked).

---

### Research Garmin watch face / activity screen layout patterns

Researched how Connect IQ apps handle dynamic, multi-field layouts and what makes Garmin's native activity screens look "anchored" vs. stacked text boxes: font-metric-driven spacing (`getFontHeight`/`getFontAscent`/`getTextDimensions`) instead of hardcoded percentages, circular safe-zone insets, `drawArc` accents/dividers that follow the bezel, half/full-width field rule, three-tier visual hierarchy, and AMOLED light-on-dark color with a single accent. Captured as a standing reference in `docs/DESIGN-RESEARCH.md` (device-adaptive, round-first, Venu 4S target), linked from `AGENTS.md`. Accent color seeded as teal-blue `0x00B5C2`.

**Files changed:** `docs/DESIGN-RESEARCH.md` (new), `AGENTS.md`

---

### Summary screen layout redesign

Two-section layout: "Session Complete" header separated from stats by a horizontal divider line. Time value downsized from `FONT_NUMBER_HOT` to `FONT_MEDIUM`; distance from `FONT_NUMBER_MEDIUM` to `FONT_SMALL`. All positions use `dc.getWidth()` / `dc.getHeight()` percentages — no hardcoded pixel coords. Button-hint icons (green checkmark for save, red bin for discard) drawn programmatically on the right edge, tuned for Venu 4S button positions. "Press to save" hint text removed.

**Files changed:** `SummaryView.mc`

---

### Disable touch on summary screen

Tapping the summary screen was triggering `onSelect()` and saving the session unintentionally. `BehaviorDelegate` automatically maps screen taps to `onSelect` on touch-capable devices — overriding `onTap` does not prevent this. Fix: switched `SummaryDelegate` to extend `WatchUi.InputDelegate` instead of `WatchUi.BehaviorDelegate`. Physical buttons are wired manually via `onKey` (`KEY_ENTER` → save, `KEY_ESC` → discard confirmation). Touch events are never mapped to actions. Consistent with ADR 0001 (button-only interaction).

**Files changed:** `SummaryDelegate.mc`

---

### Show app version on pre-session screen (v0.3.0)

`source/constants.mc` holds `VERSION as String`. `wave-trackView.mc` draws it as `"v" + VERSION` in `FONT_TINY`, `COLOR_DK_GRAY` at the bottom of the pre-session screen. When bumping the version, update `constants.mc` and `manifest.xml`.

---

### "Double press to stop" hint on single press

On the first press, `ActiveDelegate` sets `showStopHint = true` on `ActiveView` and starts a 2000ms hint timer (separate from the 400ms double-press window). `ActiveView.onUpdate()` draws "Double press to stop" in `COLOR_DK_GRAY` at the bottom of the screen while the flag is set. The hint timer clears the flag after 1.5s. If the second press fires first, `cancelHint()` clears it immediately before transitioning. `ActiveView` is constructed first at each callsite and passed into `ActiveDelegate` so the delegate can reach the flag directly.

---

### Discard activity from summary screen

Back button on the Summary screen navigates to a new `DiscardConfirmationView`. Single press confirms discard (`recordingSession.discard()`) and exits. Back on the confirmation screen returns to Summary. No touch — button-only throughout.

---

### GPS track recording + Garmin Connect map (v0.2.1)

GPS was disabled at session start — `PreSessionView.onHide()` called `LOCATION_DISABLE` before `ActiveView` appeared, and nothing re-enabled it. All sessions were saved with no track data. Fixed by enabling GPS in `ActiveView.onShow()` and disabling in `stopSession()`. Distance on the summary screen (which was always 0.0 km) also fixed as a side effect.

### GPS lock display on pre-session screen (v0.2.0)

Pre-session screen shows GPS status — **Searching** (gray), **Weak** (yellow), or **Good** (green) — updated live via `Position.enableLocationEvents`. Start is always available regardless of GPS state.

### Custom launcher icon (v0.2.0)

`resources/drawables/launcher_icon.svg` replaced with a surf man with surfboard icon.

### App name in Garmin Connect (v0.2.0)

App appeared as "wave-track" in Garmin Connect. Fixed by updating `AppName` in `resources/strings/strings.xml` to `"Wave Track"`.
