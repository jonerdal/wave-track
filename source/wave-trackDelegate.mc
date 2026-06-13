import Toybox.Lang;
import Toybox.WatchUi;

class PreSessionDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        getApp().startSession();
        var activeView = new ActiveView();
        WatchUi.switchToView(activeView, new ActiveDelegate(activeView), WatchUi.SLIDE_LEFT);
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
