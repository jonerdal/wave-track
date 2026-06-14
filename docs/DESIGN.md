# WaveTrack — Design Implementation

How WaveTrack's screens are *actually* built. This is the concrete companion to
`docs/DESIGN-RESEARCH.md`: that doc explains the **general principles** for laying out
Connect IQ views (font metrics, round geometry, AMOLED color, the patterns); this doc records
the **specific decisions** this app made when applying them — the colors, fonts, module
structure, and per-view layout it actually ships.

> Rule of thumb: if it's true for any round Connect IQ app, it belongs in DESIGN-RESEARCH.
> If it's a choice specific to WaveTrack, it belongs here.

---

## Module structure

Two modules of static helpers, called by every `*View.mc`:

- **`source/Theme.mc`** — color tokens and font-role constants. Changes when colors/fonts are
  tuned (e.g. refining the accent on-device).
- **`source/Layout.mc`** — font-metric-driven drawing helpers (safe inset, captions/hints,
  stat blocks, half-width columns, divider) plus matching measurement helpers for centering.
  Changes when geometry changes.

They're split because color tuning and layout tuning are separate activities. Views never
hardcode pixel coordinates or raw colors — they compose `Layout.*` calls with `Theme.*` tokens.

## Round-only, fully derived

WaveTrack targets the **Venu 4S only** (390×390, round, AMOLED). `Layout` assumes a round
screen and contains **no `screenShape` / rectangle branches** — shipping untested non-round
code paths buys nothing when there's no non-round device to run them on. But every position is
**derived from `dc` dimensions and font metrics**, so nothing is hardcoded and the code stays
portable-by-construction if a second device is ever added. (This is a deliberate, easily
reversible narrowing of DESIGN-RESEARCH §3's device-adaptive guidance — add the `isRound`
branches if/when a non-round target appears.)

---

## The shared screen skeleton

All four views use the **same** layout skeleton — the split between them was incidental, not
principled, so they were unified:

```
top caption     → tiny gray caps, hugs the top safe inset    (optional)
centered stack  → 1..n content blocks, centered as a group
bottom hint     → tiny dim text, hugs the bottom safe inset   (optional)
```

A view computes its group height from `Layout.*Height(...)` measurement helpers, gets the
start `y` from `Layout.centerStart(dc, groupH)`, then draws top-down with the block helpers
(each returns the next `y`). The "hero" is just a value block in a larger font.

---

## Color tokens (`Theme`)

AMOLED light-on-dark: black background, white values, gray labels, **one** accent.

| Token | Value | Use |
|---|---|---|
| `BACKGROUND` | `COLOR_BLACK` | screen fill |
| `HERO` / `VALUE` | `COLOR_WHITE` | primary/secondary values |
| `LABEL` | `COLOR_LT_GRAY` | captions, labels |
| `HINT` | `COLOR_DK_GRAY` | bottom hints, version, dividers |
| `ACCENT` | `0x00B5C2` (surf teal-blue) | the numeric hero only — see below |
| `WARN` | `COLOR_RED` | destructive (discard, bin icon) |
| `GOOD` | `COLOR_GREEN` | GPS good, save checkmark |
| `CAUTION` | `COLOR_YELLOW` | GPS weak |

**Accent policy:** the teal-blue is used in exactly **two** places — the elapsed-time hero on
the Active and Summary screens. Nothing else is teal. No decorative/accent arcs in this pass
(arcs are the most likely thing to need on-device angle/radius tuning; deferred). `0x00B5C2`
is a seeded value to refine on the watch.

## Font roles (`Theme`)

| Token | Font | Role |
|---|---|---|
| `FONT_HERO` | `FONT_NUMBER_HOT` | the one numeric hero (elapsed time) |
| `FONT_TITLE` | `FONT_MEDIUM` | text hero / title (e.g. "Discard?") |
| `FONT_VALUE` | `FONT_MEDIUM` | secondary value |
| `FONT_VALUE_SMALL` | `FONT_SMALL` | stat-column values |
| `FONT_LABEL` / `FONT_CAPTION` | `FONT_TINY` | labels, captions, hints |

`FONT_NUMBER_HOT` is tabular, so the live-updating elapsed timer doesn't jitter. The Summary
time hero uses `FONT_HERO` too — this **reverses** the earlier deliberate downsizing to
`FONT_MEDIUM`; with the teal accent and the unified skeleton it now matches Active.

---

## Per-view layout

| View | Top caption | Centered stack | Bottom hint |
|---|---|---|---|
| Pre-session | `WAVETRACK` | GPS status (color-coded) · "Press to start" | `v<VERSION>` |
| Active | session name | **elapsed time (teal hero)** · time of day | stop hint (conditional) |
| Summary | `SESSION COMPLETE` | **time (teal hero)** · divider · DISTANCE \| MAX SPEED columns | — |
| Discard | — | "Discard?" (red title) · "This will delete the activity" | "Press to confirm" / "Back to cancel" |

Target Summary layout:

```
        ╭───────────────╮
       ╱  SESSION COMPLETE ╲    ← tiny gray caps, hugs top
      │      1:24:06        │   ← hero: FONT_NUMBER_HOT, teal
      │   ──── divider ───  │   ← straight dim line (curved variant deferred)
      │  3.20 km   18.0 kmh │   ← half-width columns:
      │  DISTANCE  MAX SPEED│     label over value
   ✓  │                     │ 🗑 ← drawn icons on right edge,
        ╲                  ╱       aligned to physical buttons
        ╰───────────────╯
```

**Summary stats:** `maxSpeed` and `averageSpeed` are both snapshotted in
`wave-trackApp.stopSession()` from `Activity.getActivityInfo()`, but only **max speed** is
displayed (in km/h). Average speed is noise for surf sessions — most of the time is spent
sitting/paddling, so the average trends toward zero — so it's stored for future use but not
shown.

**Summary icons:** the save/discard hint icons are still drawn programmatically
(`drawCheckmark`/`drawBinIcon`); their right-edge X is derived, but their Y positions track the
**physical Venu 4S side buttons** (upper = save, lower = discard), so they're hardware-anchored
fractions, not layout guesses. Replacing them with SVG bitmaps is a separate task (blocked on
the `BitmapResource` type issue — see `docs/IMPLEMENTATION.md`).

---

## Explicitly out of scope (this pass)

- Decorative/accent arcs and the curved divider.
- SVG button icons (blocked separately).
- Wave count (v2 feature).
- Average-speed display.
- Any non-round / non-Venu-4S support.
