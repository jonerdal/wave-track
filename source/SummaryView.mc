import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

    private const ICON_SIZE = 40;

    private var _checkIcon as Graphics.BitmapType;
    private var _binIcon as Graphics.BitmapType;

    function initialize() {
        View.initialize();
        _checkIcon = WatchUi.loadResource(Rez.Drawables.CheckIcon) as Graphics.BitmapType;
        _binIcon = WatchUi.loadResource(Rez.Drawables.BinIcon) as Graphics.BitmapType;
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
        // (upper = save, lower = discard). Positions track hardware, not layout;
        // bitmaps are centered where the old 25px glyphs' centers were.
        var iconX = w - Layout.margin(dc) - ICON_SIZE;
        dc.drawBitmap(iconX, (h * 0.20).toNumber() + 13 - ICON_SIZE / 2, _checkIcon);
        dc.drawBitmap(iconX, (h * 0.66).toNumber() + 13 - ICON_SIZE / 2, _binIcon);
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
