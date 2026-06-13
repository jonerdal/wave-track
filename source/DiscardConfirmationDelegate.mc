import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DiscardConfirmationDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        getApp().discardSession();
        System.exit();
    }

    function onBack() as Boolean {
        WatchUi.switchToView(new SummaryView(), new SummaryDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    function onMenu() as Boolean {
        getApp().discardSession();
        System.exit();
    }

    function onNextPage() as Boolean {
        return true;
    }

    function onPreviousPage() as Boolean {
        return true;
    }

}
