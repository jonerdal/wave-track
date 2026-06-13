# WaveTrack

A wave surfing activity app for the Garmin Venu 4S, built with Connect IQ (Monkey C).

## The problem

The Venu 4S has no native surfing activity. The workaround, starting a SUP session and manually renaming it to "Surfing" in Garmin Connect and Strava after every session, gets old fast. WaveTrack eliminates that. Start the app, surf, stop. The activity saves as `SPORT_SURFING` and flows correctly to Garmin Connect and Strava with no post-session edits.

## What it does

- Records sessions as `SPORT_SURFING` with GPS tracking
- Auto-names the activity by time of day: Morning / Afternoon / Evening Surf
- Button-only interaction, no touch (screen is wet, hands are wet)
- Double press the action button to stop
- Summary screen shows total time and distance before saving

## Requirements

- Garmin Venu 4S
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) — SDK 9.1.0
- VS Code with the [Monkey C extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)
- A Garmin developer key (`.der` file) configured in VS Code settings

## Building

```
Ctrl+Shift+P → Monkey C: Build
```

Compiled output: `bin/wavetrack.prg`

## Running in the simulator

Press **F5** in VS Code. This builds and launches the app in the Venu 4S simulator in one step.

## Deploying to the watch

1. `Ctrl+Shift+P → Monkey C: Export Project` — builds a signed `.iq` package
2. Transfer the `.iq` file to your phone and open it with the Garmin Connect app — it installs directly to the paired watch over Bluetooth

## Deploying to Garmin IQ store

The app is deployed as a beta version application in Garmin Store. Use the file from the export.

## Documentation

- [`docs/SPEC.md`](docs/SPEC.md) — v1 app spec and session flow
- [`docs/RESEARCH.md`](docs/RESEARCH.md) — platform research and device constraints
- [`docs/IMPLEMENTATION.md`](docs/IMPLEMENTATION.md) — architecture notes, known constraints, and planned improvements
- [`CONTEXT.md`](CONTEXT.md) — domain glossary
- [`docs/adr/`](docs/adr/) — architecture decision records
