# WaveTrack — App Spec (v1)

## Problem Being Solved

Garmin Venu 4S has no native surfing activity. Current workaround: start a Stand Up Paddleboard session, then manually rename the activity to "Surfing" in both Garmin Connect and Strava after every session.

WaveTrack eliminates that manual cleanup. Start the app, surf, stop — the activity is saved as `SPORT_SURFING` and flows correctly to Garmin Connect and Strava with no post-session edits required.

---

## Activity Recording

| Setting | Value |
|---|---|
| Sport type | `Activity.SPORT_SURFING` |
| GPS sampling | 1-second intervals |
| Heart rate | Background recording (not displayed) |
| Typical session | ~2 hours |

---

## Session Flow

### 1. Pre-session screen

- Displays GPS lock status (Searching / Weak / Good)
- Start is always available — GPS lock is not required
- Button press starts the session

### 2. Active screen

Two pieces of information, nothing else:

| Element | Details |
|---|---|
| Elapsed time | Large, prominent — primary display |
| Current time of day | Smaller, secondary |

**Future addition (not v1):** Wave count, once wave detection is implemented.

### 3. Stopping the session

- Button-only interaction — no touch. Screen is wet, fingers are wet, gloves may be on.
- Double press the action button to stop (400ms window between presses)
- No confirmation step — double press is considered sufficient confirmation
- **Future:** Gesture-based stop (e.g. arm rotation sequence)

### 4. End-of-session summary screen

Shown on watch before saving:

| Field | Value |
|---|---|
| Total time | Session elapsed time |
| Distance | GPS-derived distance |

Everything else (map, HR graph, route) is viewed in Garmin Connect on the phone.

---

## Activity Naming

Auto-generated from session start time. No manual input required.

| Start time | Activity name |
|---|---|
| Before 12:00 | Morning Surf |
| 12:00 – 17:00 | Afternoon Surf |
| 17:00 and after | Evening Surf |

---

## What the App Does NOT Do (v1)

- No wave detection or wave count
- No touch interaction of any kind
- No HR display on-screen
- No gesture controls
- No map display on watch (use Garmin Connect)

---

## Future Versions

- Wave count on active screen (requires accelerometer/gyroscope-based wave detection)
- HR displayed on active screen
- Gesture-based start/stop (arm rotation sequence)
- Expand target devices beyond Venu 4S
