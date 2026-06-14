import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;

class PreSessionView extends WatchUi.View {

    private var _gpsStatus as String = "GPS: Searching";
    private var _gpsColor as Number = Theme.LABEL;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onHide() as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info as Position.Info) as Void {
        var acc = info.accuracy;
        if (acc == null || acc <= Position.QUALITY_LAST_KNOWN) {
            _gpsStatus = "GPS: Searching";
            _gpsColor = Theme.LABEL;
        } else if (acc < Position.QUALITY_USABLE) {
            _gpsStatus = "GPS: Weak";
            _gpsColor = Theme.CAUTION;
        } else {
            _gpsStatus = "GPS: Good";
            _gpsColor = Theme.GOOD;
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;

        dc.setColor(Theme.HERO, Theme.BACKGROUND);
        dc.clear();

        Layout.drawTopCaption(dc, "WAVETRACK");

        // Centered group: GPS status (color-coded) over the start prompt.
        var groupH = Layout.valueHeight(dc, Theme.FONT_VALUE_SMALL)
                   + Layout.valueHeight(dc, Theme.FONT_VALUE_SMALL);
        var y = Layout.centerStart(dc, groupH);
        y = Layout.drawValueBlock(dc, cx, y, _gpsStatus, _gpsColor, Theme.FONT_VALUE_SMALL);
        Layout.drawValueBlock(dc, cx, y, "Press to start", Theme.VALUE, Theme.FONT_VALUE_SMALL);

        Layout.drawBottomHint(dc, "v" + VERSION);
    }

}
