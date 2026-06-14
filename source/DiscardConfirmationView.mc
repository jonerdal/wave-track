import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DiscardConfirmationView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Drawing programmatically — no XML layout
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;

        dc.setColor(Theme.HERO, Theme.BACKGROUND);
        dc.clear();

        // Centered group: red destructive hero question over the explanatory lines.
        var lineH = dc.getFontHeight(Theme.FONT_VALUE_SMALL);
        var groupH = Layout.valueHeight(dc, Theme.FONT_TITLE) + (lineH * 2);
        var y = Layout.centerStart(dc, groupH);
        y = Layout.drawValueBlock(dc, cx, y, "Discard?", Theme.WARN, Theme.FONT_TITLE);
        dc.setColor(Theme.LABEL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Theme.FONT_VALUE_SMALL, "This will delete", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, y + lineH, Theme.FONT_VALUE_SMALL, "the activity.", Graphics.TEXT_JUSTIFY_CENTER);

        // Two button hints stacked above the bottom safe inset.
        var hintH = dc.getFontHeight(Theme.FONT_LABEL);
        var hintY = Layout.bottomY(dc);
        dc.setColor(Theme.HINT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hintY - hintH, Theme.FONT_LABEL, "Press to confirm", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, hintY, Theme.FONT_LABEL, "Back to cancel", Graphics.TEXT_JUSTIFY_CENTER);
    }

}
