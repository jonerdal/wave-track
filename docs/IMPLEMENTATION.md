# WaveTrack — Implementation Notes

Wave Track is a Garmin activity used for wave surfing.

This document is the working project board. Open it at the start of each session to see what's pending, in progress, and done. It also captures the "why it's shaped this way" for decisions that aren't obvious from the code.

For domain vocabulary, see `CONTEXT.md`. For the app spec, see `docs/SPEC.md`. For platform research, see `docs/RESEARCH.md`.

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

### "Double tap to stop" hint on single press

**Problem:** A single press on the active screen does nothing and gives no feedback. Easy to forget the double press gesture mid-session.

**Proposed behaviour:** On the first press of a potential double press (inside `ActiveDelegate.onSelect()` when `_waitingForSecondPress` is false), briefly show a hint. It disappears after the 400ms window expires.

**Implementation sketch:**
- Add a `showStopHint as Boolean` field to `ActiveView`
- In `ActiveDelegate.onSelect()` (first press path), set the flag and call `WatchUi.requestUpdate()`
- In `ActiveView.onUpdate()`, if the flag is set, draw a small hint label (e.g. "Double press to stop") in a subtle colour
- In `ActiveDelegate.onWindowExpired()`, clear the flag and call `WatchUi.requestUpdate()`

**Files to change:** `ActiveDelegate.mc`, `ActiveView.mc`

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
    ├── StopConfirmationView + StopConfirmationDelegate  (stop flow)
    └── SummaryView      + SummaryDelegate        (post-session summary)
```

### View transitions

| From | To | Method | Reason |
|---|---|---|---|
| Pre-session | Active | `switchToView` | No going back after starting |
| Active | Stop confirmation | `switchToView` | Prevents ActiveView sitting under Summary with no clean removal path |
| Stop confirmation (cancel) | Active | `switchToView` | Recreates ActiveView; safe because elapsed time recalculates from stored `sessionStartTime` |
| Stop confirmation (confirm) | Summary | `switchToView` | Clean stack, no path back to a stopped session |
| Summary | Discard confirmation | `switchToView` | Back button triggers discard flow |
| Discard confirmation (cancel) | Summary | `switchToView` | User changed their mind |
| Discard confirmation (confirm) | Exit | `System.exit()` | Terminates app after discard |
| Summary | Exit | `System.exit()` | Terminates app after save |

`pushView` was considered for Active → Stop confirmation (free back-button cancel) but rejected — the Venu 4S back button exits the app by default, and the view stack cleanup on confirm was non-trivial.

---

## Key Decisions

### Double press to stop

The stop trigger is a double press of the action button (400ms window), not a long press. Long press was the original design but the simulator has no reliable way to test it. On device, revisit whether long press (`onMenu()`) would feel more natural — the infrastructure is already stubbed in both delegates.

To change the window: `_doublePressTimer.start(method(:onWindowExpired), 400, false)` in `ActiveDelegate.mc` and `StopConfirmationDelegate.mc`.

### Stop confirmation auto-cancel: 5 seconds

The countdown starts in `StopConfirmationView.onShow()`. Change `secondsRemaining = 5` at the top of `StopConfirmationView.mc` to tune this.

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
