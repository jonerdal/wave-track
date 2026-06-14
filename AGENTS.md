# WaveTrack — Agent Context

WaveTrack is a Garmin Connect IQ watch app for the Venu 4S that records surf sessions as `SPORT_SURFING` activities.

## Start of session

Open `docs/IMPLEMENTATION.md` first. It is the working project board — read the **Investigate / Revisit** and **Up Next** sections to understand what to work on and what is already under consideration.

## Docs

- `README.md` — project overview, build instructions, and how to run in the simulator or sideload to the watch.
- `CONTEXT.md` — domain glossary (screens, terms). Read this first.
- `docs/SPEC.md` — product spec: what the app does and what it intentionally does not do.
- `docs/IMPLEMENTATION.md` — working project board: Up Next, Architecture, Key Decisions, Done. Open this to see what to work on.
- `docs/RESEARCH.md` — Connect IQ platform research and constraints discovered during build.
- `docs/DESIGN-RESEARCH.md` — screen layout & design reference: principles, font metrics, round geometry, AMOLED color. Read before any UI/layout work.
- `docs/adr/` — architecture decision records.

## Source

All app code is in `source/`. Each screen is a `*View.mc` + `*Delegate.mc` pair. Shared session state lives in `wave-trackApp.mc` and is accessed everywhere via `getApp()`.

## Version

The app version is defined in `source/constants.mc` (`VERSION as String`). This is the single source of truth — update it there, and also update the matching `version` attribute in `manifest.xml`.

## Key constraints

- Physical buttons only — no touch interaction.
- Target device: Garmin Venu 4S (`venu441mm`), SDK 9.1.0. Two physical buttons on the right side of the case: upper = select/save, lower = back/discard.
- Use `Toybox.Position` (not `Toybox.Positioning`) for GPS.
