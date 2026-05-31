# WaveTrack — Domain Glossary

## Terms

**Session**
A single surf outing recorded by WaveTrack. Begins when the user presses Start (after GPS is acquired) and ends when the activity is saved from the Summary screen. Maps directly to one Garmin Connect activity of type `SPORT_SURFING`.

**GPS Acquired**
The state where `Positioning.Info.quality >= QUALITY_USABLE`. This is the threshold that unlocks the Start button on the Pre-session screen.

**Session Name**
Auto-generated from the local time at session start: "Morning Surf" (before 12:00), "Afternoon Surf" (12:00–17:00), "Evening Surf" (17:00+). Set immediately after `startActivity()` is called.

**Stop Confirmation**
A 5-second interstitial screen reached by long-pressing during an Active session. A second long press within the window confirms the stop. Inaction (timeout) or a short press cancels back to the Active screen.

## Screens

**Pre-session screen** — Shows GPS lock status. Blocks start until GPS is acquired.

**Active screen** — Shows elapsed time (large) and current time of day (small). Entry point for the stop flow via long press.

**Stop confirmation screen** — "Hold to stop" prompt. 5-second auto-cancel window.

**Summary screen** — Shows total time and GPS distance. Saves the session on button press then exits.
