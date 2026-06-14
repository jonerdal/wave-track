# WaveTrack — Design Research & Layout Reference

A standing reference for designing screens in this app. Read this instead of going back to
Garmin's docs every time. It captures the **general principles** for laying out Connect IQ
views (all views, not just Summary), the **APIs** that make layouts robust, and the
**device-adaptive** patterns that keep a design working across screen sizes and shapes.

Target device today is the **Venu 4S** (390×390, round, AMOLED, API 6.0), but everything
here is written to scale to other round devices — and to degrade gracefully on semi-round
or rectangular screens — by deriving layout from the device at runtime instead of hardcoding.

> Scope note: this is a reference doc. Concrete redesign work for a specific screen belongs
> in `docs/IMPLEMENTATION.md`. Code snippets here are **patterns**, not committed code.

---

## 1. Why naive screens read as "text boxes"

A screen that places everything with hardcoded vertical percentages (`h * 34 / 100`) or fixed
pixels (`y = 140`), and treats a round screen as a rectangle, produces evenly-stacked labels
with no clear hierarchy and no relationship to the physical bezel.

Garmin's own activity screens (e.g. the Run app) feel "anchored" because they do four things:

1. **They use the round geometry deliberately** — content lives inside a circular safe zone;
   secondary info hugs the top/bottom arcs. This is the "knows where the edges are" feeling.
2. **One dominant element** — a hero number that visibly outranks everything else.
3. **Baseline grid from font metrics**, not guessed percentages — so spacing is consistent
   and adding a field never requires re-tuning magic numbers.
4. **Restrained AMOLED color** — light-on-dark, a single accent color, everything else
   white/gray on black.

The rest of this doc is how to do those four things.

---

## 2. Design principles (apply to every view)

- **Derive, don't hardcode.** Compute positions from `dc.getWidth()/getHeight()` and font
  metrics. Never paste pixel coordinates tuned for one device.
- **One hero per screen.** Pick the single most important value (elapsed time, the headline
  stat) and give it the largest font and the optical center. Everything else is secondary.
- **Label/value pairing.** Tiny dim ALL-CAPS label, larger bright value. Group them so the
  eye reads them as one unit (see §6).
- **Respect the circle.** Keep all content inside a safe inset; lay secondary content along
  the curve, not in the corners (see §5).
- **Light-on-dark, one accent.** Black background, white hero, gray labels, a single accent
  color used sparingly (see §7).
- **Spacing comes from font heights**, expressed as fractions of them (e.g. `0.4 * fontH`
  gaps), so the rhythm scales with the chosen font and the device.
- **Test the layout cold on the largest and smallest target** before trusting it.

---

## 3. Device-adaptive foundation

Query the device once per `onUpdate` (or cache in `onLayout`) and build everything from it.
This is what makes a layout portable to other devices later.

```monkeyc
import Toybox.System;
import Toybox.Graphics;

// In onUpdate(dc):
var w   = dc.getWidth();
var h   = dc.getHeight();
var cx  = w / 2;
var cy  = h / 2;

var settings = System.getDeviceSettings();
var isRound  = (settings.screenShape == System.SCREEN_SHAPE_ROUND);
var isAmoled = settings.requiresBurnInProtection; // proxy for AMOLED / burn-in rules
```

Relevant `DeviceSettings` fields (all API 1.2.0 unless noted):

| Field | Meaning |
|---|---|
| `screenShape` | `SCREEN_SHAPE_ROUND`, `SCREEN_SHAPE_SEMI_ROUND`, `SCREEN_SHAPE_RECTANGLE`, `SCREEN_SHAPE_SEMI_OCTAGON` |
| `screenWidth` / `screenHeight` | Physical pixels. For the area available to the app, prefer `dc.getWidth()/getHeight()`. |
| `requiresBurnInProtection` | `true` on AMOLED. In always-on/sleep: ≤10% of pixels active, ≤1 update/min, a pixel can't stay on >3 min (API 3.0.12). |

**Rule:** use `dc.getWidth()/getHeight()` for layout math (it reflects the drawable area);
use `DeviceSettings` for *decisions* (round vs not, AMOLED vs MIP).

---

## 4. Layout system: manual drawing vs XML

Connect IQ offers two approaches:

- **XML layouts** — declarative `resources/layouts/*.xml`, drawables positioned with
  mnemonics like `x="center"`, `y="bottom"`. Good for static, simple screens.
- **Manual drawing** — draw in `onUpdate(dc)` with `dc.drawText`, `dc.drawArc`, etc.

**Recommendation for this app: stay manual, add a small layout helper.** Reasons:

- XML is rigid for **dynamic field counts** (we want to add wave count, max speed, etc.).
- XML **cannot express arcs / radial accents**, which is exactly what makes a round watch
  screen look designed.
- We already draw manually everywhere; consistency beats a half-migration.

The fix for "manual = magic numbers" is not XML — it's deriving positions from font metrics
and a couple of reusable helpers (§9).

---

## 5. Round geometry: the part that makes it look intentional

### Safe zone (circular inset)

On a round screen the corners are clipped and the extreme top/bottom/left/right are visually
cramped. Keep content inside a safe inset. Garmin notes edge obscuration is only ~2–4% of
usable space, so a conservative margin is enough.

```monkeyc
// Margin scales with screen size; round screens get a bit more.
var margin   = isRound ? (w * 0.10).toNumber() : (w * 0.04).toNumber();
var safeTop  = margin;
var safeBot  = h - margin;
var safeLeft = margin;
// Vertical content band:
var bandTop  = safeTop;
var bandBot  = safeBot;
```

A more exact circular check (for placing something near an edge at vertical position `y`):
the half-width available at that `y` on a circle of radius `r = w/2` is
`sqrt(r*r - (y - cy)*(y - cy))`. Stay inside that, minus a few px of padding.

### Use arcs, not straight lines, near the edges

`dc.drawArc(x, y, r, attr, degreeStart, degreeEnd)` — center `(x,y)`, radius `r`,
`attr` is `Graphics.ARC_CLOCKWISE` or `Graphics.ARC_COUNTER_CLOCKWISE`, angles in degrees
(0° = 3 o'clock, increasing counter-clockwise).

Two cheap, high-impact upgrades:

- **Curved divider** instead of a straight `drawLine` between sections — a short arc
  concentric with the bezel.
- **Accent arc** along the top (e.g. ~60°–120°) framing a header, drawn in the accent color
  with `setPenWidth(3..5)`. This single touch is most of what separates "designed" from
  "stacked labels".

```monkeyc
dc.setPenWidth(4);
dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
dc.drawArc(cx, cy, (w / 2) - 6, Graphics.ARC_CLOCKWISE, 110, 70); // top accent
dc.setPenWidth(1);
```

### Field widths: full or half

Garmin's round-screen field rule: a field takes **full width** or **half width**. For
secondary stats, prefer two **half-width columns** (value over micro-label) rather than a
long centered row — it reads cleanly and uses the widest part of the circle (the middle).

---

## 6. Visual hierarchy & fonts

Three tiers, every screen:

| Tier | Role | Font example | Color |
|---|---|---|---|
| Hero | The one number that matters | `FONT_NUMBER_HOT` / `FONT_NUMBER_THAI_HOT` | white (or accent) |
| Value | Secondary stats | `FONT_MEDIUM` / `FONT_SMALL` | white |
| Label | ALL-CAPS descriptor | `FONT_TINY` / `FONT_XTINY` | dim gray (`COLOR_LT_GRAY`/`COLOR_DK_GRAY`) |

- `FONT_NUMBER_*` (MILD → MEDIUM → HOT → THAI_HOT) are tabular number fonts — use them for
  any digits that update live so the layout doesn't jitter.
- Pair label **above or below** its value with a small gap; keep the pair as one block.
- Fonts scale proportionally across devices (`FONT_TINY` occupies ~the same fraction of the
  screen everywhere), so choosing by role is portable.
- `Graphics.getVectorFont({ :face=>..., :size=>... })` gives scalable vector fonts if a
  system font size doesn't fit — useful for hero text that must hit an exact size.

---

## 7. AMOLED color language (Venu 4S)

Garmin's explicit AMOLED guidance:

- **Light-on-dark.** Black/near-black background (every lit pixel costs battery).
- **Gradients fade to black**, not bright solid fills.
- **Color for accents only.** Use **one** accent color for the hero value *or* an accent arc,
  not both, not everywhere. White for hero/values, gray for labels.
- If you ever add an always-on / low-power state, honor burn-in rules
  (`requiresBurnInProtection`): thin fonts, move elements between frames, ≤10% pixels lit.

> WaveTrack's concrete palette and accent choice live in `docs/DESIGN.md` (the `Theme` module).

---

## 8. Font metrics — the core of clean spacing

This is the single biggest upgrade over hardcoded percentages.

Key fact: **text origin is the top-left of the glyph box** (the `(x,y)` you pass to
`drawText`), and justification only shifts horizontally. So to place rows you work in glyph
boxes and advance by their heights.

APIs (`Dc`):

| Method | Returns | Use |
|---|---|---|
| `getFontHeight(font)` | Number | full line height (ascent+descent). Primary tool. |
| `getFontDescent(font)` | Number | distance below baseline; for baseline alignment of mixed fonts. |
| `getFontAscent(font)` | Number | distance above baseline. |
| `getTextDimensions(text, font)` | `[w, h]` | measure a specific string (e.g. to fit/center it). |

**Vertical centering of one line on a target center `yc`:**
```monkeyc
var fh = dc.getFontHeight(font);
dc.drawText(cx, yc - fh / 2, font, text, Graphics.TEXT_JUSTIFY_CENTER);
```

**Baseline-align two different-sized fonts on a shared line `yBase`:** position each so its
baseline lands on `yBase`, i.e. `y = yBase - (getFontHeight(f) - getFontDescent(f))`.

**Debug trick:** temporarily give text a gray background (`setColor(fg, 0x555555)`) to see
the exact glyph box and verify alignment.

---

## 9. Reusable building blocks (patterns)

These are the helpers worth extracting so every view stops using magic numbers. Pseudo-code
patterns, not committed code.

### a) Vertical row stacker

Lay out a label/value block, advancing a cursor by measured heights so any number of fields
auto-space:

```monkeyc
// Draw a stat as: tiny gray label, then big value below it. Returns next y.
function drawStat(dc, cx, y, label, value, valueFont) {
    var labelFont = Graphics.FONT_XTINY;
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawText(cx, y, labelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
    y += dc.getFontHeight(labelFont);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.drawText(cx, y, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);
    y += dc.getFontHeight(valueFont);
    return y + (dc.getFontHeight(labelFont) * 0.4).toNumber(); // inter-block gap
}
```

To vertically center the whole stack: pre-sum the block heights, then start at
`cy - totalHeight/2`.

### b) Half-width columns

```monkeyc
var leftCx  = w * 0.30;
var rightCx = w * 0.70;
drawStat(dc, leftCx,  rowY, "DISTANCE", dist,  Graphics.FONT_SMALL);
drawStat(dc, rightCx, rowY, "MAX SPD",  maxSp, Graphics.FONT_SMALL);
```

### c) Curved divider / accent arc — see §5.

### d) Safe-inset helper — see §5.

---

## 10. Applying it per view

How these principles map onto WaveTrack's specific screens — the per-view hero/secondary/
geometry table, the Summary layout sketch, and the `Theme`/`Layout` modules that implement
them — lives in **`docs/DESIGN.md`**. Keep this reference generic; record concrete per-view
decisions there.

---

## 11. Pre-flight checklist (run before calling a layout done)

- [ ] No hardcoded pixel coordinates; everything derived from `dc` dims + font metrics.
- [ ] Exactly one hero element; clear three-tier hierarchy.
- [ ] All content inside the circular safe inset on round screens.
- [ ] Background black; ≤1 accent color; labels gray, values white.
- [ ] Live-updating numbers use `FONT_NUMBER_*` (no horizontal jitter).
- [ ] Dividers/edges follow the curve (arcs), not straight lines in the corners.
- [ ] Renders correctly on the smallest and largest intended device.
- [ ] (If always-on added) burn-in rules respected when `requiresBurnInProtection`.

---

## 12. Sources

- [Tips for screen layout — Garmin Forums](https://forums.garmin.com/developer/connect-iq/f/discussion/213680/tips-for-screen-layout) — grid, font metrics, baseline alignment, edge obscuration.
- [Connect IQ Layouts — Core Topics](https://developer.garmin.com/connect-iq/core-topics/layouts/) — XML layout system, positioning mnemonics, half/full-width field rule.
- [Views, Drawables and Layers](https://developer.garmin.com/connect-iq/core-topics/user-interface/) — layout vs manual drawing model.
- [The Real Devices of Connect IQ (Part 1)](https://forums.garmin.com/developer/connect-iq/b/news-announcements/posts/the-real-devices-of-connect-iq-part-1) — AMOLED vs MIP, light-on-dark, accents, burn-in.
- [Toybox.Graphics.Dc API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html) — `drawArc`, `drawText`, `getFontHeight/Ascent/Descent`, `getTextDimensions` signatures.
- [Toybox.System.DeviceSettings API](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html) — `screenShape`, `screenWidth/Height`, `requiresBurnInProtection`.
- [Toybox.Graphics module](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics.html) — font constants, `getVectorFont`, arc/justify constants.
