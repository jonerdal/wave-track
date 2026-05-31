import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class ActiveDelegate extends WatchUi.BehaviorDelegate {

    private var _waitingForSecondPress as Boolean = false;
    private var _doublePressTimer as Timer.Timer?;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        if (_waitingForSecondPress) {
            cancelTimer();
            WatchUi.switchToView(new StopConfirmationView(), new StopConfirmationDelegate(), WatchUi.SLIDE_UP);
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
        return true; // block back button — session is recording
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
