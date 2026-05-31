import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;

class PreSessionView extends WatchUi.View {

    private var _gpsStatus as String = "GPS: Searching";
    private var _gpsColor as Number = Graphics.COLOR_LT_GRAY;

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
            _gpsColor = Graphics.COLOR_LT_GRAY;
        } else if (acc < Position.QUALITY_USABLE) {
            _gpsStatus = "GPS: Weak";
            _gpsColor = Graphics.COLOR_YELLOW;
        } else {
            _gpsStatus = "GPS: Good";
            _gpsColor = Graphics.COLOR_GREEN;
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 90, Graphics.FONT_MEDIUM, "WaveTrack", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(_gpsColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_SMALL, _gpsStatus, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 30, Graphics.FONT_SMALL, "Press to start", Graphics.TEXT_JUSTIFY_CENTER);
    }

}
