# WaveTrack — Domain Glossary

## Terms
**GPS Status**
One of three states shown on the Pre-session screen via `Toybox.Position`: **Searching** (QUALITY_NOT_AVAILABLE or QUALITY_LAST_KNOWN), **Weak** (QUALITY_POOR), **Good** (QUALITY_USABLE or QUALITY_GOOD). Informational only — start is always available.

**Session**
A single surf outing recorded by WaveTrack. Begins when the user presses Start on the Pre-session screen and ends when the activity is saved from the Summary screen. Maps directly to one Garmin Connect activity of type `SPORT_SURFING`.


**Session Name**
Auto-generated from the local time at session start: "Morning Surf" (before 12:00), "Afternoon Surf" (12:00–17:00), "Evening Surf" (17:00+). Set immediately after `startActivity()` is called.

## Screens

**Pre-session screen** — Shows GPS Status (Searching / Weak / Good). Start is always available.

**Active screen** — Shows elapsed time (large) and current time of day (small). Double press stops the session and navigates to the Summary screen.

**Summary screen** — Shows total time and GPS distance. Saves the session on button press then exits. Back button enters the Discard Confirmation screen.

**Discard Confirmation screen** — Warns the user that the activity will be deleted. Button press confirms discard and exits. Back button returns to the Summary screen.
