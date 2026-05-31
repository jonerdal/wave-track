# ADR 0002 — GPS lifecycle tied to ActiveView, not ActivityRecording session

**Status:** Accepted

## Decision

GPS (`Position.enableLocationEvents`) is enabled in `ActiveView.onShow()` and disabled in `wave_trackApp.stopSession()`. It is not enabled in `startSession()` and not disabled in any view's `onHide()` during the recording window.

## Reason

`ActivityRecording.Session.start()` does **not** automatically enable GPS. It only records data that the platform is already collecting. If `Position.enableLocationEvents` is not active during the session, the FIT file is saved with no track data — no map in Garmin Connect, distance reads as 0.

Enabling GPS in `startSession()` was considered but rejected: `PreSessionView.onHide()` fires during the view transition immediately after `startSession()` is called, and it calls `LOCATION_DISABLE` — which would undo the enable before `ActiveView` ever appears. The view lifecycle ordering makes `startSession()` the wrong place.

Enabling in `ActiveView.onShow()` fires after `PreSessionView.onHide()`, so the ordering is safe. GPS stays on through `StopConfirmationView` (no disable in `ActiveView.onHide()`) because the session is still recording during those ~5 seconds.

## Consequences

- `ActiveView` must import `Toybox.Position` and declare an `onPosition` callback (no-op — GPS data is captured by ActivityRecording automatically)
- `wave_trackApp.stopSession()` must call `LOCATION_DISABLE` after `recordingSession.stop()`
- `wave_trackApp` must also declare a no-op `onPosition` to provide a valid method reference for the disable call
- The GPS is briefly off between `PreSessionView.onHide()` and `ActiveView.onShow()` (a few hundred milliseconds during the slide transition) — acceptable
