import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class wave_trackApp extends Application.AppBase {

    var recordingSession as ActivityRecording.Session? = null;
    var sessionStartTime as Time.Moment? = null;
    var sessionEndTime as Time.Moment? = null;
    var sessionDistanceMeters as Float = 0.0f;
    var sessionMaxSpeed as Float = 0.0f;      // m/s, snapshotted at stop
    var sessionAvgSpeed as Float = 0.0f;      // m/s, snapshotted at stop (not yet displayed)
    var sessionName as String = "";

    // FIT developer field: max speed on the session message, shown in the
    // Connect IQ section of the Garmin Connect activity page. The native
    // surf "Top Speed" field can't be written by CIQ apps (see docs/RESEARCH.md).
    private const MAX_SPEED_FIELD_ID = 0;
    private var _maxSpeedField as FitContributor.Field? = null;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new PreSessionView(), new PreSessionDelegate() ];
    }

    function startSession() as Void {
        sessionStartTime = Time.now();
        sessionName = buildSessionName();
        var session = ActivityRecording.createSession({
            :name => sessionName,
            :sport => Activity.SPORT_SURFING,
            :subSport => Activity.SUB_SPORT_GENERIC
        });
        _maxSpeedField = session.createField("max_speed", MAX_SPEED_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "km/h" });
        recordingSession = session;
        session.start();
    }

    function stopSession() as Void {
        if (recordingSession != null) {
            recordingSession.stop();
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
            sessionEndTime = Time.now();
            var info = Activity.getActivityInfo();
            if (info != null) {
                if (info.elapsedDistance != null) {
                    sessionDistanceMeters = info.elapsedDistance;
                }
                if (info.maxSpeed != null) {
                    sessionMaxSpeed = info.maxSpeed;
                }
                if (info.averageSpeed != null) {
                    sessionAvgSpeed = info.averageSpeed;
                }
            }
            var field = _maxSpeedField;
            if (field != null) {
                field.setData(sessionMaxSpeed * 3.6); // stored as km/h to match the display unit
            }
        }
    }

    function onPosition(info as Position.Info) as Void {}

    function saveSession() as Void {
        if (recordingSession != null) {
            recordingSession.save();
            recordingSession = null;
        }
    }

    function discardSession() as Void {
        if (recordingSession != null) {
            recordingSession.discard();
            recordingSession = null;
        }
    }

    private function buildSessionName() as String {
        var hour = System.getClockTime().hour;
        if (hour < 12) { return "Morning Surf"; }
        if (hour < 17) { return "Afternoon Surf"; }
        return "Evening Surf";
    }

}

function getApp() as wave_trackApp {
    return Application.getApp() as wave_trackApp;
}
