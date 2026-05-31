import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

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

        // Header
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 55, Graphics.FONT_SMALL, "Session Complete", Graphics.TEXT_JUSTIFY_CENTER);

        // Total time
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 105, Graphics.FONT_TINY, "TOTAL TIME", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 125, Graphics.FONT_NUMBER_HOT, elapsedTime(), Graphics.TEXT_JUSTIFY_CENTER);

        // Distance
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 220, Graphics.FONT_TINY, "DISTANCE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 240, Graphics.FONT_NUMBER_MEDIUM, distance(), Graphics.TEXT_JUSTIFY_CENTER);

        // Save hint
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 318, Graphics.FONT_TINY, "Press to save", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function elapsedTime() as String {
        var start = getApp().sessionStartTime;
        var end = getApp().sessionEndTime;
        if (start == null || end == null) { return "0:00:00"; }

        var seconds = (end.subtract(start) as Time.Duration).value().toNumber();
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        return h.format("%d") + ":" + m.format("%02d") + ":" + s.format("%02d");
    }

    private function distance() as String {
        var km = getApp().sessionDistanceMeters / 1000.0;
        return km.format("%.2f") + " km";
    }

}
