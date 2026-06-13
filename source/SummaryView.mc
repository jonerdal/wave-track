import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Header section
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 10 / 100, Graphics.FONT_TINY, "Session Complete", Graphics.TEXT_JUSTIFY_CENTER);

        // Section divider — centred, spans 60% of screen width
        var lineHalf = w * 30 / 100;
        var lineY = h * 27 / 100;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - lineHalf, lineY, cx + lineHalf, lineY);

        // Stats section
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 34 / 100, Graphics.FONT_TINY, "TOTAL TIME", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 41 / 100, Graphics.FONT_MEDIUM, elapsedTime(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 54 / 100, Graphics.FONT_TINY, "DISTANCE", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 61 / 100, Graphics.FONT_SMALL, distance(), Graphics.TEXT_JUSTIFY_CENTER);

        // Button hint icons — right edge, tuned for Venu 4S button positions
        var iconX = w - 65;
        drawCheckmark(dc, iconX, h * 17 / 100);
        drawBinIcon(dc, iconX, h * 73 / 100);
    }

    private function drawCheckmark(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x + 2, y + 14, x + 10, y + 22);
        dc.drawLine(x + 10, y + 22, x + 25, y + 4);
        dc.setPenWidth(1);
    }

    private function drawBinIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(x + 9, y + 1, x + 17, y + 1);   // handle
        dc.drawLine(x + 3, y + 5, x + 23, y + 5);   // lid
        dc.drawLine(x + 6, y + 8, x + 6, y + 24);   // left wall
        dc.drawLine(x + 20, y + 8, x + 20, y + 24); // right wall
        dc.drawLine(x + 6, y + 24, x + 20, y + 24); // base
        dc.setPenWidth(1);
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
