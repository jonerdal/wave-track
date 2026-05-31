import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SummaryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        getApp().saveSession();
        System.exit();
    }

    function onBack() as Boolean {
        return true; // block back button — must save before exiting
    }

    function onMenu() as Boolean {
        getApp().saveSession();
        System.exit();
    }

    function onNextPage() as Boolean {
        return true; // consume swipe — no touch interaction
    }

    function onPreviousPage() as Boolean {
        return true; // consume swipe — no touch interaction
    }

}
