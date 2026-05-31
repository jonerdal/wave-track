import Toybox.Lang;
import Toybox.WatchUi;

class PreSessionDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        getApp().startSession();
        WatchUi.switchToView(new ActiveView(), new ActiveDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    function onMenu() as Boolean {
        return true; // consume long press on pre-session screen
    }

    function onNextPage() as Boolean {
        return true; // consume swipe — no touch interaction
    }

    function onPreviousPage() as Boolean {
        return true; // consume swipe — no touch interaction
    }

}
