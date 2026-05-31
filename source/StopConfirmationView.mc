import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class StopConfirmationView extends WatchUi.View {

    var secondsRemaining as Number = 5;
    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        // Drawing programmatically — no XML layout
    }

    function onShow() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTick() as Void {
        secondsRemaining -= 1;
        if (secondsRemaining <= 0) {
            WatchUi.switchToView(new ActiveView(), new ActiveDelegate(), WatchUi.SLIDE_DOWN);
        } else {
            WatchUi.requestUpdate();
        }
    }

    function onUpdate(dc as Dc) as Void {
        var cx = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 140, Graphics.FONT_MEDIUM, "Double press", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 210, Graphics.FONT_NUMBER_HOT, secondsRemaining.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
    }

}
