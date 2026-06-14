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

        dc.setColor(Theme.HERO, Theme.BACKGROUND);
        dc.clear();

        Layout.drawTopCaption(dc, "SESSION COMPLETE");

        // Centered group: time hero (accent), divider, then distance + max-speed columns.
        var groupH = Layout.valueHeight(dc, Theme.FONT_HERO)
                   + Layout.dividerHeight(dc)
                   + Layout.statHeight(dc, Theme.FONT_VALUE_SMALL);
        var y = Layout.centerStart(dc, groupH);
        y = Layout.drawValueBlock(dc, cx, y, elapsedTime(), Theme.ACCENT, Theme.FONT_HERO);
        y = Layout.drawDivider(dc, y);
        Layout.drawColumns(dc, y, "DISTANCE", distance(), "MAX SPEED", maxSpeed(), Theme.VALUE, Theme.FONT_VALUE_SMALL);

        // Button-hint icons hug the right edge, aligned to the Venu 4S side buttons
        // (upper = save, lower = discard). Positions track hardware, not layout.
        var iconX = w - Layout.margin(dc) - 25;
        drawCheckmark(dc, iconX, (h * 0.20).toNumber());
        drawBinIcon(dc, iconX, (h * 0.66).toNumber());
    }

    private function drawCheckmark(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Theme.GOOD, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x + 2, y + 14, x + 10, y + 22);
        dc.drawLine(x + 10, y + 22, x + 25, y + 4);
        dc.setPenWidth(1);
    }

    private function drawBinIcon(dc as Dc, x as Number, y as Number) as Void {
        dc.setColor(Theme.WARN, Graphics.COLOR_TRANSPARENT);
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

    private function maxSpeed() as String {
        var kmh = getApp().sessionMaxSpeed * 3.6;
        return kmh.format("%.1f") + " km/h";
    }

}
