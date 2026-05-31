# WaveTrack

A wave surfing activity app for the Garmin Venu 4S, built with Connect IQ (Monkey C).

## The problem

The Venu 4S has no native surfing activity. The workaround, starting a SUP session and manually renaming it to "Surfing" in Garmin Connect and Strava after every session, gets old fast. WaveTrack eliminates that. Start the app, surf, stop. The activity saves as `SPORT_SURFING` and flows correctly to Garmin Connect and Strava with no post-session edits.

## What it does

- Records sessions as `SPORT_SURFING` with GPS tracking
- Auto-names the activity by time of day: Morning / Afternoon / Evening Surf
- Button-only interaction, no touch (screen is wet, hands are wet)
- Double press the action button to stop; 5-second confirmation countdown
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

1. Launch the Venu 4S simulator
2. `Ctrl+Shift+P → Monkey C: Run in Simulator`

In the simulator, single-click the action button for a short press. To trigger a double press, click twice quickly.

## Sideloading to the watch

Transfer `bin/wavetrack.prg` to your phone and open it with the Garmin Connect app — it installs directly to the paired watch over Bluetooth. Alternatively, copy the `.prg` to `GARMIN/Apps/` on the watch via USB.

## Documentation

- [`docs/SPEC.md`](docs/SPEC.md) — v1 app spec and session flow
- [`docs/RESEARCH.md`](docs/RESEARCH.md) — platform research and device constraints
- [`docs/IMPLEMENTATION.md`](docs/IMPLEMENTATION.md) — architecture notes, known constraints, and planned improvements
- [`CONTEXT.md`](CONTEXT.md) — domain glossary
- [`docs/adr/`](docs/adr/) — architecture decision records
