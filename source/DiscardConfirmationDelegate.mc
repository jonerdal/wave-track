import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// InputDelegate, not BehaviorDelegate: a screen tap must never confirm
// a discard — physical buttons only (see ADR 0001).
class DiscardConfirmationDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) {
            getApp().discardSession();
            System.exit();
        } else if (key == WatchUi.KEY_ESC) {
            WatchUi.switchToView(new SummaryView(), new SummaryDelegate(), WatchUi.SLIDE_DOWN);
        }
        return true;
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
