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

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 80, Graphics.FONT_MEDIUM, "Discard?", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 150, Graphics.FONT_SMALL, "This will delete", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, 185, Graphics.FONT_SMALL, "the activity.", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 270, Graphics.FONT_TINY, "Press to confirm", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, 300, Graphics.FONT_TINY, "Back to cancel", Graphics.TEXT_JUSTIFY_CENTER);
    }

}
