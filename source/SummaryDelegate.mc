import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SummaryDelegate extends WatchUi.InputDelegate {

    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER) {
            getApp().saveSession();
            System.exit();
        } else if (key == WatchUi.KEY_ESC) {
            WatchUi.switchToView(new DiscardConfirmationView(), new DiscardConfirmationDelegate(), WatchUi.SLIDE_UP);
        }
        return true;
    }

    function onTap(clickEvent) as Boolean {
        return true;
    }

    function onHold(clickEvent) as Boolean {
        return true;
    }

}
