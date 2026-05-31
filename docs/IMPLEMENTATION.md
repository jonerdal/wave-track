# WaveTrack — Implementation Notes

This document captures decisions made during the v1 build that aren't in the spec or ADRs — the "why it's shaped this way" for anyone picking up the code to build the next version.

For domain vocabulary, see `CONTEXT.md`. For the app spec, see `SPEC.md`. For platform research, see `docs/RESEARCH.md`.

---

## High Priority Fix

### ~~GPS lock confirmation before starting~~ — Done (v0.2.0)

**What was built:** The pre-session screen now shows GPS status — **Searching** (gray), **Weak** (yellow), or **Good** (green) — updated live via `Position.enableLocationEvents`. Start is always available regardless of GPS state.

**Implementation:** `PreSessionView.onShow()` registers a `Position.LOCATION_CONTINUOUS` listener. The callback maps `Position.Info.accuracy` to one of the three states and calls `requestUpdate()`. `onHide()` disables the listener. No recording session is created before the user presses start.

See the constraints section below for the full list of GPS APIs that do and don't work on the Venu 4S.

---

### Map display on the summary screen

**Problem:** The summary screen currently shows only total time and distance. There is no visual of the route taken during the session. The original v1 spec deferred this ("use Garmin Connect"), but it is now a priority.

**Confirmed available:** The Venu 4S supports map display — verified by the fact that the built-in SUP activity shows a map after a session. `WatchUi.MapView` should be available for `venu441mm`.

**Implementation approach:**

1. Replace `SummaryView` with a subclass of `WatchUi.MapView` instead of `WatchUi.View`
2. After the session stops, pass the recorded track to the map view
3. The SDK handles tile rendering and route drawing automatically

**Which screen(s)**

- Summary screen: route of the full session — highest priority
- Active screen: live breadcrumb trail — lower priority, add after summary map works

**Files to change:** `SummaryView.mc`, `SummaryDelegate.mc`

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
| Summary | Exit | `System.exit()` | Terminates app after save |

`pushView` was considered for Active → Stop confirmation (free back-button cancel) but rejected — the Venu 4S back button exits the app by default, and the view stack cleanup on confirm was non-trivial.

---

## Key Decisions

### Double press to stop

The stop trigger is a double press of the action button (400ms window), not a long press. Long press was the original design but the simulator has no reliable way to test it. On device, revisit whether long press (`onMenu()`) would feel more natural — the infrastructure is already stubbed in both delegates.

To change the window: `_doublePressTimer.start(method(:onWindowExpired), 400, false)` in `ActiveDelegate.mc` and `StopConfirmationDelegate.mc`. Increase `400` to widen the window.

### Stop confirmation auto-cancel: 5 seconds

The countdown starts in `StopConfirmationView.onShow()`. Change `secondsRemaining = 5` at the top of `StopConfirmationView.mc` to tune this.

### Distance captured at stop time

`Activity.getActivityInfo().elapsedDistance` is read inside `stopSession()` and stored in `sessionDistanceMeters`. It is not re-read on the summary screen. This is intentional — the value is snapshotted the moment recording stops so the summary screen always shows the final number regardless of when it renders.

### Session name from start time, not stop time

`buildSessionName()` reads `System.getClockTime().hour` inside `startSession()`. The name reflects when you paddled out, not when you finished. Stored in `sessionName` on the app.

### Activity recording requires no permission declaration

`ActivityRecording` is available to all `watch-app` type apps by default. No `<iq:uses-permission>` entry is needed in `manifest.xml`. The `Fit` permission (currently declared) was added by the VS Code extension automatically.

---

## Connect IQ Constraints Discovered During Build

### GPS quality API: use `Toybox.Position`, not `Toybox.Positioning`

The correct module for reading GPS status is **`Toybox.Position`** (note: no `-ing`). The older `Toybox.Positioning` module does not compile for `venu441mm`.

The following do **not** work on this device and should not be attempted:
- `Toybox.Positioning` — does not compile
- `ActivityRecording.Session.pause()` / `.resume()` — not available
- `Activity.getActivityInfo().gpsAccuracy` — field does not exist
- `Activity.GPS_QUALITY_*` constants — not defined

What **does** work:
- `Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition))` — registers a callback that fires on each GPS update
- `Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition))` — stops listening
- The callback receives a `Position.Info` object; read `.accuracy` for one of: `Position.QUALITY_NOT_AVAILABLE`, `Position.QUALITY_LAST_KNOWN`, `Position.QUALITY_POOR`, `Position.QUALITY_USABLE`, `Position.QUALITY_GOOD`
- Requires `<iq:uses-permission id="Positioning"/>` in `manifest.xml`

This works independently of `ActivityRecording` — no session needs to exist.

### Valid `manifest.xml` permission IDs

Trial-and-error results for `venu441mm` with SDK 9.1.0:

| Permission ID | Valid |
|---|---|
| `Activity` | No — rejected by manifest parser |
| `HeartRate` | No — rejected by manifest parser |
| `Sensor` | Not tested |
| `Positioning` | Yes — required for `Toybox.Position` (confirmed working via `Position.enableLocationEvents`) |
| `Fit` | Yes — added by VS Code extension |

### `import Toybox.Lang` is required everywhere

`String`, `Number`, `Float`, `Boolean` all live in `Toybox.Lang`. Any file that uses type annotations must import it. The compiler error is `Cannot resolve type 'String'` which is not obviously a missing import.

---

## Hooks for Future Versions

### Wave detection (v2)

Wave detection will use accelerometer and/or gyroscope data. The `Toybox.Sensor` module provides this. Entry point: a listener registered via `Sensor.setEnabledSensors()` and `Sensor.enableSensorEvents()`.

The natural place to add this is in `ActiveView.onShow()` alongside the existing 1-second timer. Wave count would be a field on `wave_trackApp` (e.g. `waveCount as Number`), incremented by the detection logic and displayed on the active screen.

The `Sensor` permission may need to be added to `manifest.xml` when this is built.

### Heart rate on active screen (v2)

HR is already recorded as part of the activity. To display it, read `Activity.getActivityInfo().heartRate` inside `ActiveView.onUpdate()`. No permission changes needed — HR is available from the activity info object during an active session.

### Gesture-based stop (v3)

The spec notes a future arm-rotation gesture for stop. This would replace or supplement the double press. Implementation would use the `Sensor` module to detect orientation changes via gyroscope, pattern-matching against a defined gesture sequence.

---

## Planned UX Improvements

### "Double tap to stop" hint on single press

**Problem:** On the active screen, a single press does nothing and gives no feedback. First-time users (or the user after a long session with cold hands) may not remember the double press gesture.

**Proposed behaviour:** When the first press of a potential double press is detected — i.e. inside `ActiveDelegate.onSelect()` when `_waitingForSecondPress` is false — briefly show a hint on screen. The hint disappears after the 400ms double press window expires.

**Implementation sketch:**
- Add a `showStopHint as Boolean` field to `ActiveView` (or `wave_trackApp`)
- In `ActiveDelegate.onSelect()` (first press path), set the flag and call `WatchUi.requestUpdate()`
- In `ActiveView.onUpdate()`, if the flag is set, draw a small hint label (e.g. "Double press to stop") in a subtle colour
- In `ActiveDelegate.onWindowExpired()`, clear the flag and call `WatchUi.requestUpdate()` to remove the hint

The hint only needs to be visible for ~400ms so it will naturally disappear as part of the existing double press timeout logic.

**Files to change:** `ActiveDelegate.mc`, `ActiveView.mc`

---

### Save or delete on summary screen

**Problem:** Currently the summary screen only offers one action — save. If the user ended the session accidentally or the GPS data is bad, there is no way to discard the session from the watch.

**Proposed behaviour:** The summary screen offers two options: **Save** and **Delete**. Since the session is already over and the screen is not subject to wet-hand interaction, touch input is acceptable here.

**Implementation options:**

- **Option A — Two touch targets:** Draw two labelled buttons on screen (e.g. "Save" top half, "Delete" bottom half). Use `onTap()` in the delegate (requires switching from `BehaviorDelegate` to `InputDelegate` or adding a touch mixin) to detect which half was tapped.
- **Option B — Physical button cycles, then confirms:** Single press cycles between Save (highlighted) and Delete (highlighted). Double press confirms the selected option. Keeps the button-only pattern consistent with the rest of the app.

Option B is more consistent with the rest of the app; Option A is faster and simpler to implement given that touch is explicitly allowed on this screen.

**Discard API:** `ActivityRecording.Session.discard()` — call this instead of `save()` when delete is confirmed. After discarding, call `System.exit()` as normal.

**Files to change:** `SummaryView.mc`, `SummaryDelegate.mc`

---

### ~~Custom launcher icon~~ — Done (v0.2.0)

`resources/drawables/launcher_icon.svg` has been replaced with a surf man with surfboard icon. The manifest wiring (`launcherIcon="@Drawables.LauncherIcon"` → `drawables.xml` → `launcher_icon.svg`) was already correct and required no changes.

---

### ~~App name in Garmin Connect activity list~~ — Done (v0.2.0)

The app appeared as "wave-track" in Garmin Connect's activity type list (alongside Running, Hiking, etc.). Fixed by updating `AppName` in `resources/strings/strings.xml` to `"Wave Track"`.

---

### Timer update frequency and battery usage

**Problem:** `ActiveView` redraws every second via a `Timer.Timer`. Whether this meaningfully affects battery life on a 2-hour surf session is unknown.

**Investigation needed:** Test a full-length session on the physical watch with 1-second updates, then compare battery drain against the device's stated battery life for GPS activities. The Venu 4S has a rated GPS battery life of around 20 hours, so a 2-hour session should be well within budget regardless — but this is worth confirming before tuning.

**If reducing frequency is worthwhile:** change the timer interval from `1000` to `5000` (ms) in `ActiveView.onShow()`. The elapsed time display will update in 5-second steps rather than per-second ticks, which is visually less smooth but perfectly readable.

**Trade-off:** A 1-second timer that only calls `requestUpdate()` is lightweight — it wakes the CPU briefly, redraws the screen, then sleeps. On AMOLED displays, the bigger battery cost is screen brightness and how many pixels are lit, not the redraw frequency. Reducing to 5 seconds is unlikely to make a material difference but is a trivial change if testing shows otherwise.

**Files to change:** `ActiveView.mc` — the `1000` in `_timer.start(method(:onTick), 1000, true)`

---

## What Was Not Built in v1

Per `SPEC.md` — these are explicitly deferred, not forgotten:

- No wave count display
- No HR display
- No gesture controls
- No map display on watch
