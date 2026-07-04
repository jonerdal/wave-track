import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

// InputDelegate, not BehaviorDelegate: taps must never map to onSelect —
// water on the touchscreen was stopping sessions mid-surf (see ADR 0001).
class ActiveDelegate extends WatchUi.InputDelegate {

    private var _view as ActiveView;
    private var _waitingForSecondPress as Boolean = false;
    private var _doublePressTimer as Timer.Timer?;

    function initialize(view as ActiveView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            onStopPress();
        }
        return true; // consume all keys — back is blocked while recording
    }

    private function onStopPress() as Void {
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

    function onTap(clickEvent) as Boolean {
        return true;
    }

    function onHold(clickEvent) as Boolean {
        return true;
    }

    function onSwipe(swipeEvent) as Boolean {
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
