# ADR 0001 — Button-only interaction

**Status:** Accepted

## Decision

All user interaction in WaveTrack uses the physical side button only. Touch input is disabled throughout.

## Reason

The app is used while surfing — screen is wet, hands are wet, gloves may be worn. Touch input is unreliable in these conditions and risks accidental triggers.

## Consequences

- Every screen's `InputDelegate` ignores touch events
- All flows are designed around single press and double press only
- Stop is triggered by a double press of the action button — no confirmation screen
