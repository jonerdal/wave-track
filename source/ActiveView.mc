import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

class ActiveView extends WatchUi.View {

    var showStopHint as Boolean = false;
    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Drawing programmatically — no XML layout
    }

    function onShow() as Void {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        // GPS stays on — session keeps recording until stopSession()
    }

    function onPosition(info as Position.Info) as Void {
        // ActivityRecording captures GPS data automatically; nothing to do here
    }

    function onTick() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;

        dc.setColor(Theme.HERO, Theme.BACKGROUND);
        dc.clear();

        // Session name hugs the top safe inset.
        Layout.drawTopCaption(dc, getApp().sessionName);

        // Centered group: elapsed-time hero (accent) over time of day.
        var groupH = Layout.valueHeight(dc, Theme.FONT_HERO)
                   + Layout.valueHeight(dc, Theme.FONT_VALUE);
        var y = Layout.centerStart(dc, groupH);
        y = Layout.drawValueBlock(dc, cx, y, elapsedTime(), Theme.ACCENT, Theme.FONT_HERO);
        Layout.drawValueBlock(dc, cx, y, currentTime(), Theme.LABEL, Theme.FONT_VALUE);

        if (showStopHint) {
            Layout.drawBottomHint(dc, "Double press to stop");
        }
    }

    private function elapsedTime() as String {
        var startTime = getApp().sessionStartTime;
        if (startTime == null) { return "0:00:00"; }

        var seconds = (Time.now().subtract(startTime) as Time.Duration).value().toNumber();
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        return h.format("%d") + ":" + m.format("%02d") + ":" + s.format("%02d");
    }

    private function currentTime() as String {
        var t = System.getClockTime();
        return t.hour.format("%02d") + ":" + t.min.format("%02d");
    }

}
