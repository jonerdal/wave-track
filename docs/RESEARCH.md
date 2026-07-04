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

## Garmin Connect surf fields & FIT developer fields

Researched July 2026, prompted by "Top Speed" (and Surfing Time / Longest Wave / Total Waves) showing empty on WaveTrack activities in Garmin Connect.

### Why the native surf fields are empty

The surf-specific fields on a Garmin Connect surfing activity page — Total Waves, Longest Wave, Surf Time, Top Speed — are populated by Garmin's **native surf activity profile**, which does on-device wave detection and writes surf-specific FIT data. A Connect IQ app produces a plain FIT recording and cannot fill those fields, even though the device tracks max speed (`Activity.getActivityInfo().maxSpeed` is available on-watch — WaveTrack shows it on the Summary screen).

The SDK's escape hatch, `:nativeNum` on [`Session.createField()`](https://developer.garmin.com/connect-iq/api-docs/Toybox/FitContributor.html) (mapping a developer field onto a native FIT field number), **is deliberately not honored by Garmin Connect**. A Garmin rep confirmed in [this forum thread](https://forums.garmin.com/developer/connect-iq/f/discussion/4854/fitcontributor-nativenum-functionality): *"I agree that it is odd we have the feature in the SDK, but do not support it on Garmin Connect."* Some third-party consumers (e.g. Strava) do honor it, but the FIT spec then expects the developer field's data to be unit-equivalent to the native field (session `max_speed` is m/s), which would force the Connect-visible value into m/s. WaveTrack skips `:nativeNum` and stores km/h for readable display.

Wave-derived fields (Surfing Time, Longest Wave, Total Waves) are doubly out of reach: they'd also require wave detection, parked as v2 in `IMPLEMENTATION.md`. Existing store surf apps hit the same wall — see the [Surf Tracker showcase thread](https://forums.garmin.com/developer/connect-iq/f/showcase/521/data-field-surf-tracker), where the question of setting native surf fields went unanswered.

### What works: FitContributor developer fields

[`Toybox.FitContributor`](https://developer.garmin.com/connect-iq/api-docs/Toybox/FitContributor.html) lets the app write custom fields into the FIT file. A field created with `:mesgType => MESG_TYPE_SESSION` and declared in a `fitContributions` resource with `displayInActivitySummary="true"` appears on the Garmin Connect activity page in the app's own **Connect IQ section** (with label and units) — not in the greyed-out native slot, but visible. Requires the `FitContributor` permission in `manifest.xml`.

Caveat from the forums: some devices have had issues writing CIQ session-message fields; and the session field's value is whatever was last `setData()` before `save()`. WaveTrack sets it once in `stopSession()`. If the field doesn't appear on the Venu 4S, the fallback is calling `setData()` periodically during recording instead.

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
| Native surf fields (Top Speed, waves) not writable by CIQ | Max speed exposed as a FitContributor developer field instead; Connect ignores `:nativeNum` |

---

## Next Steps

1. Create a free Garmin developer account at https://developer.garmin.com/
2. Install the Connect IQ SDK Manager
3. Install the Connect IQ VS Code extension
4. Run through the "Your First App" tutorial to get familiar with Monkey C
5. Build a minimal activity app skeleton: start/stop session, record GPS, save as SPORT_SURFING
