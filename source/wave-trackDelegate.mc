import Toybox.Lang;
import Toybox.WatchUi;

// InputDelegate, not BehaviorDelegate: a screen tap must never start
// a session — physical buttons only (see ADR 0001).
class PreSessionDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            getApp().startSession();
            var activeView = new ActiveView();
            WatchUi.switchToView(activeView, new ActiveDelegate(activeView), WatchUi.SLIDE_LEFT);
            return true;
        }
        return false; // let back exit the app from the pre-session screen
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

}
