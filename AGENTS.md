# WaveTrack — Agent Context

WaveTrack is a Garmin Connect IQ watch app for the Venu 4S that records surf sessions as `SPORT_SURFING` activities.

## Docs

- `README.md` — project overview, build instructions, and how to run in the simulator or sideload to the watch.
- `CONTEXT.md` — domain glossary (screens, terms). Read this first.
- `docs/SPEC.md` — product spec: what the app does and what it intentionally does not do.
- `docs/IMPLEMENTATION.md` — working project board: Up Next, Architecture, Key Decisions, Done. Open this to see what to work on.
- `docs/RESEARCH.md` — Connect IQ platform research and constraints discovered during build.
- `docs/adr/` — architecture decision records.

## Source

All app code is in `source/`. Each screen is a `*View.mc` + `*Delegate.mc` pair. Shared session state lives in `wave-trackApp.mc` and is accessed everywhere via `getApp()`.

## Key constraints

- Physical buttons only — no touch interaction.
- Target device: Garmin Venu 4S (`venu441mm`), SDK 9.1.0.
- Use `Toybox.Position` (not `Toybox.Positioning`) for GPS.
