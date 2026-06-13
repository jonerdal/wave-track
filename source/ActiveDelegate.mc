import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class ActiveDelegate extends WatchUi.BehaviorDelegate {

    private var _view as ActiveView;
    private var _waitingForSecondPress as Boolean = false;
    private var _doublePressTimer as Timer.Timer?;

    function initialize(view as ActiveView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Boolean {
        if (_waitingForSecondPress) {
            cancelTimer();
            _view.showStopHint = false;
            getApp().stopSession();
            WatchUi.switchToView(new SummaryView(), new SummaryDelegate(), WatchUi.SLIDE_UP);
        } else {
            if (_doublePressTimer != null) {
                _doublePressTimer.stop();
            }
            _waitingForSecondPress = true;
            _doublePressTimer = new Timer.Timer();
            _doublePressTimer.start(method(:onWindowExpired), 400, false);
            _view.showStopHint = true;
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Phase 1: double-press window closed — reuse timer for remaining hint duration
    function onWindowExpired() as Void {
        _waitingForSecondPress = false;
        if (_doublePressTimer != null) {
            _doublePressTimer.start(method(:onHintExpired), 1600, false);
        }
    }

    function onHintExpired() as Void {
        _doublePressTimer = null;
        _view.showStopHint = false;
        WatchUi.requestUpdate();
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
