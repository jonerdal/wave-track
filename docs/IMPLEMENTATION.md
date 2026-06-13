# WaveTrack — Implementation Notes

Wave Track is a Garmin activity used for wave surfing.

This document is the working project board. Open it at the start of each session to see what's pending, in progress, and done. It also captures the "why it's shaped this way" for decisions that aren't obvious from the code.

For domain vocabulary, see `CONTEXT.md`. For the app spec, see `docs/SPEC.md`. For platform research, see `docs/RESEARCH.md`.

---

## Investigate / Revisit

### Stop flow: double-press direct vs. single-press confirmation step

Currently a double-press on the action button stops the session immediately and goes straight to Summary. An alternative: single press opens a "Stop session?" confirmation screen, double-press there confirms and saves, back button returns to the active recording.

Trade-off: the current flow is fast but irreversible mid-press. The confirmation step adds safety but an extra screen. Worth revisiting once there's more real-world usage to know whether accidental stops are actually a problem.

---

## Up Next

### Fix summary screen layout

**Problem:** Label text (e.g. "TOTAL TIME", "DISTANCE") is too small and the data values are too large, making the screen feel unbalanced.

**What to do:** Adjust font sizes in `SummaryView.onUpdate()` — bump the label font up and reduce the data field font down until the hierarchy feels readable.

**Files to change:** `SummaryView.mc`

---

### More stats on summary screen

**Problem:** Summary screen shows total time and distance. Max speed and other session stats are in the FIT file but not displayed.

**What's available:** `Activity.getActivityInfo()` exposes these fields during an active session. Snapshot them in `stopSession()` alongside `elapsedDistance`, store on `wave_trackApp`, then display in `SummaryView.onUpdate()`.

Useful candidates:
- `maxSpeed` — peak speed in m/s; convert to km/h for display (`* 3.6`)
- `averageSpeed` — average speed in m/s

**Files to change:** `wave_trackApp.mc` (snapshot fields in `stopSession()`), `SummaryView.mc` (display them)

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
