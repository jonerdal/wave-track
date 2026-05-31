import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class StopConfirmationDelegate extends WatchUi.BehaviorDelegate {

    private var _waitingForSecondPress as Boolean = false;
    private var _doublePressTimer as Timer.Timer?;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        if (_waitingForSecondPress) {
            cancelTimer();
            getApp().stopSession();
            WatchUi.switchToView(new SummaryView(), new SummaryDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            _waitingForSecondPress = true;
            _doublePressTimer = new Timer.Timer();
            _doublePressTimer.start(method(:onWindowExpired), 400, false);
        }
        return true;
    }

    function onWindowExpired() as Void {
        _waitingForSecondPress = false;
        _doublePressTimer = null;
    }

    function onBack() as Boolean {
        cancelTimer();
        WatchUi.switchToView(new ActiveView(), new ActiveDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    function onMenu() as Boolean {
        return true; // consume long press
    }

    function onNextPage() as Boolean {
        return true;
    }

    function onPreviousPage() as Boolean {
        return true;
    }

    private function cancelTimer() as Void {
        if (_doublePressTimer != null) {
            _doublePressTimer.stop();
            _doublePressTimer = null;
        }
        _waitingForSecondPress = false;
    }

}
