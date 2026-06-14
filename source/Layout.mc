import Toybox.Graphics;
import Toybox.Lang;

// Shared, font-metric-driven layout helpers for WaveTrack's screens.
// Round-only: positions are derived from dc dimensions and font heights, never
// hardcoded pixels. See docs/DESIGN.md (this app's layout decisions) and
// docs/DESIGN-RESEARCH.md (the general principles).
module Layout {

    // Circular safe-inset margin, as a fraction of screen width.
    const MARGIN_FRACTION as Float = 0.10;

    function margin(dc as Dc) as Number {
        return (dc.getWidth() * MARGIN_FRACTION).toNumber();
    }

    // Inter-block gap, scaled to label height so spacing rides the font.
    function gap(dc as Dc) as Number {
        return (dc.getFontHeight(Theme.FONT_LABEL) * 0.4).toNumber();
    }

    // Y of the top safe inset (where the top caption sits).
    function topY(dc as Dc) as Number {
        return margin(dc);
    }

    // Y of the bottom hint line (one label height above the bottom inset).
    function bottomY(dc as Dc) as Number {
        return dc.getHeight() - margin(dc) - dc.getFontHeight(Theme.FONT_LABEL);
    }

    // Top of a content group of total height `groupHeight`, vertically centered.
    function centerStart(dc as Dc, groupHeight as Number) as Number {
        return ((dc.getHeight() - groupHeight) / 2).toNumber();
    }

    // --- Measurement helpers (mirror the advance of the draw helpers) ---

    function valueHeight(dc as Dc, valueFont as Graphics.FontDefinition) as Number {
        return dc.getFontHeight(valueFont) + gap(dc);
    }

    function statHeight(dc as Dc, valueFont as Graphics.FontDefinition) as Number {
        return dc.getFontHeight(Theme.FONT_LABEL) + dc.getFontHeight(valueFont) + gap(dc);
    }

    function dividerHeight(dc as Dc) as Number {
        return (dc.getFontHeight(Theme.FONT_LABEL) * 0.6).toNumber();
    }

    // --- Arc-hugging text ---

    function drawTopCaption(dc as Dc, text as String) as Void {
        dc.setColor(Theme.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, topY(dc), Theme.FONT_CAPTION, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawBottomHint(dc as Dc, text as String) as Void {
        dc.setColor(Theme.HINT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, bottomY(dc), Theme.FONT_LABEL, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // --- Content blocks (return the next y cursor) ---

    // A bare value, centered at cx. Use for the hero and label-less values.
    function drawValueBlock(dc as Dc, cx as Number, y as Number, value as String, valueColor as Number, valueFont as Graphics.FontDefinition) as Number {
        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, valueFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        return y + dc.getFontHeight(valueFont) + gap(dc);
    }

    // A label-over-value stat block, centered at cx.
    function drawStatBlock(dc as Dc, cx as Number, y as Number, label as String, value as String, valueColor as Number, valueFont as Graphics.FontDefinition) as Number {
        dc.setColor(Theme.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Theme.FONT_LABEL, label, Graphics.TEXT_JUSTIFY_CENTER);
        y += dc.getFontHeight(Theme.FONT_LABEL);
        return drawValueBlock(dc, cx, y, value, valueColor, valueFont);
    }

    // Two half-width stat columns sharing a baseline. Returns the next y.
    function drawColumns(dc as Dc, y as Number, leftLabel as String, leftValue as String, rightLabel as String, rightValue as String, valueColor as Number, valueFont as Graphics.FontDefinition) as Number {
        var w = dc.getWidth();
        drawStatBlock(dc, (w * 0.30).toNumber(), y, leftLabel, leftValue, valueColor, valueFont);
        return drawStatBlock(dc, (w * 0.70).toNumber(), y, rightLabel, rightValue, valueColor, valueFont);
    }

    // A straight dim divider spanning 60% of the width. (Curved variant deferred.)
    function drawDivider(dc as Dc, y as Number) as Number {
        var w = dc.getWidth();
        var half = (w * 0.30).toNumber();
        var cx = w / 2;
        dc.setColor(Theme.HINT, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(cx - half, y, cx + half, y);
        return y + dividerHeight(dc);
    }
}
