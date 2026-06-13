# WaveTrack — Research Document

Wave surfing activity app for Garmin Venu 4S.

---

## Project Goal

Build a wave surfing activity app for the Garmin Venu 4S. Personal use first, with the door open for future publishing to the Connect IQ Store.

---

## Platform: Garmin Connect IQ

Garmin's platform for third-party watch apps is **Connect IQ**, using their proprietary language **Monkey C**.

- Monkey C is influenced by Java, JavaScript, Python, and PHP — learnable with existing Java/JS background
- SDK is free to download and use
- VS Code is the supported IDE via the official Connect IQ extension
- A built-in simulator is included for testing UI and logic without the physical watch

### App Types

Connect IQ supports several app types. WaveTrack will be an **Activity App** — the type that runs a full activity session with its own screens, GPS recording, and data logging. This is distinct from watch faces, widgets, and data fields.

---

## Target Device: Garmin Venu 4S

| Spec | Value |
|---|---|
| Screen | 390×390, round, AMOLED |
| API Level | 6.0 |
| Water Resistance | 5ATM |
| System | System 8 |

### Available Sensors

All sensors needed for WaveTrack are present on the Venu 4S:

| Sensor | Use |
|---|---|
| GPS | Session track, speed, distance |
| Accelerometer | Motion data (wave detection in future versions) |
| Gyroscope | Orientation data (wave detection in future versions) |
| Optical heart rate | Session health metrics |
| Barometric altimeter | Available but not surfing-relevant |

---

## Activity Type

`Activity.SPORT_SURFING` exists as a native SDK constant, available since API Level 3.2.0. The Venu 4S (API 6.0) fully supports it.

Sessions recorded with this sport type will appear as **Surfing** in Garmin Connect with the correct icon and categorisation.

### Why the native surfing activity isn't on Venu 4S

Garmin's built-in surf activity is restricted on 5ATM watches — their official reason is that surfing is a "high-speed water sport" requiring 10ATM. This is widely disputed by users as a product decision rather than a genuine hardware constraint.

**This does not affect custom Connect IQ apps.** A third-party app using `Activity.SPORT_SURFING` works around this restriction entirely and is exactly the approach used by existing surf apps in the store.

---

## Development Workflow

### Toolchain

1. VS Code (already installed)
2. Connect IQ SDK Manager — installs the SDK and device simulators
3. Garmin Connect IQ VS Code extension

### Testing

- **Simulator**: Use for all UI, layout, and logic development. Fast iteration.
- **Sideload to watch**: Required for real sensor/GPS testing. Deploy via USB or the Garmin Connect mobile app (already installed).

### Sideloading (personal use)

No developer account or publishing required for personal sideloading. Build the `.prg` file → push to watch via Connect mobile app. Immediate.

---

## Developer Account

- A free Garmin developer account is required even for sideloading
- Same account used for publishing if that becomes relevant later
- Register at: https://developer.garmin.com/
- **Status: not yet created**

---

## Publishing (future consideration)

- Free to publish free apps — no cost
- App goes through a Garmin review process
- Target devices declared explicitly in `manifest.xml`
- Potential review concern: Garmin may flag surfing app on a 5ATM device. Mitigations: target only 10ATM devices for store version, or add a disclaimer.
- **Not a current priority — personal use is the goal**

---

## Market Gap

Checked the Connect IQ Store. No free wave surfing app exists for the Venu 4S. Available options are:
- Kite surfing apps (different sport, different data)
- Apps targeting higher-end outdoor watches only

This confirms the build is worthwhile.

---

## Cross-Device Strategy

- **Phase 1**: Venu 4S only
- **Phase 2 (if expanding)**: Venu 4 series (same shape, same API level)
- **Phase 3 (if publishing)**: All devices with API 6.0+, round screen, similar sensor set

Device support is declared per-device in `manifest.xml` — not a blanket "supports all" toggle.

---

## Timer limit: 2 concurrent timers on Venu 4S

The Venu 4S enforces a hard cap on simultaneous `Timer.Timer` instances. Exceeding it throws `Too Many Timers Error` at runtime. With `ActiveView._timer` (1s tick) already running, only one additional timer can be active at a time in `ActiveDelegate`. Work around this by reusing a single timer across sequential phases rather than allocating a second one.

---

## Key Constraints Summary

| Constraint | Impact |
|---|---|
| Monkey C only — no .NET/C# | New language to learn, manageable with Java/JS background |
| 5ATM water rating | No impact for personal use; potential store review issue later |
| No native surfing activity on device | Solved via custom Connect IQ activity app |
| Simulator cannot replicate real sensor data | Physical ocean testing required for sensor-dependent features |
| Device manifest must list each target explicitly | Start with Venu 4S only |
| Max ~2 concurrent timers on Venu 4S | Sequential timer reuse required when multiple timed events overlap |

---

## Next Steps

1. Create a free Garmin developer account at https://developer.garmin.com/
2. Install the Connect IQ SDK Manager
3. Install the Connect IQ VS Code extension
4. Run through the "Your First App" tutorial to get familiar with Monkey C
5. Build a minimal activity app skeleton: start/stop session, record GPS, save as SPORT_SURFING
