pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import QtPositioning

Singleton {
    id: systemService

    // TIME

    SystemClock {
        id: systemClock

        precision: SystemClock.Minutes

        property double lastTick: 0

        onDateChanged: {
            const now = date.getTime();
            const resumed = lastTick > 0 && now - lastTick > 120000;

            // Waked up from sleep after 2 minutes
            if (resumed) {
                systemService.triggerSolarLookup();
                systemService.triggerPositionLookup();
            }

            lastTick = now;
        }

        Component.onCompleted: lastTick = date.getTime()
    }

    readonly property string time: Qt.formatTime(systemClock.date, "HH:mm")
    readonly property string date: Qt.formatDate(systemClock.date, "dd/MM/yyyy")

    // LOCATION

    property string timezone: "UTC"
    // New timezone are only commited after tz-change succeeds.
    property string pendingTimezone: ""

    property double latitude: NaN
    property double longitude: NaN
    // New coordinates are only committed after tz-lookup succeeds.
    property double pendingLatitude: NaN
    property double pendingLongitude: NaN

    readonly property bool locationUpdateRunning: isFinite(pendingLatitude) && isFinite(pendingLongitude)

    function clearPendingLocation(): void {
        pendingLatitude = NaN;
        pendingLongitude = NaN;
        pendingTimezone = "";
    }
    function commitPendingLocation(): void {
        latitude = pendingLatitude;
        longitude = pendingLongitude;

        if (pendingTimezone)
            timezone = pendingTimezone;

        clearPendingLocation();
    }

    function triggerPositionLookup(): void {
        if (!positionSource.valid || locationUpdateRunning)
            return;

        positionSource.update(10000);
    }

    PositionSource {
        id: positionSource

        active: false

        onPositionChanged: {
            if (systemService.locationUpdateRunning)
                return;

            const coord = position.coordinate;

            if (!coord.isValid)
                return;

            const moved = !isFinite(systemService.latitude) || !isFinite(systemService.longitude) || Math.abs(systemService.latitude - coord.latitude) > 0.01 || Math.abs(systemService.longitude - coord.longitude) > 0.01;

            if (!moved)
                return;

            systemService.pendingLatitude = coord.latitude;
            systemService.pendingLongitude = coord.longitude;

            tzLookupProc.exec({
                command: [Quickshell.shellPath("scripts/tz-lookup"), "--lat", coord.latitude, "--lng", coord.longitude]
            });
        }
    }

    Process {
        id: tzLookupProc

        stdout: StdioCollector {
            id: tzLookupStdout
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                systemService.clearPendingLocation();
                return;
            }

            const timezoneStr = tzLookupStdout.text.trim();

            // Location moved, but timezone is unchanged.
            if (systemService.timezone === timezoneStr) {
                systemService.commitPendingLocation();
                systemService.triggerSolarLookup(true);
                return;
            }

            systemService.pendingTimezone = timezoneStr;

            tzChangeProc.exec({
                command: [Quickshell.shellPath("scripts/change-timezone.sh"), timezoneStr]
            });
        }
    }

    Process {
        id: tzChangeProc

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                systemService.clearPendingLocation();
                return;
            }

            // Location moved, timezone moved.
            systemService.commitPendingLocation();
            systemService.triggerSolarLookup(true);
        }
    }

    // SOLAR

    property int sunrise: 480 // Default to 8:00
    property int sunset: 1080 // Default to 18:00

    property string solarDate: ""

    function triggerSolarLookup(force = false): void {
        if (!isFinite(systemService.latitude) || !isFinite(systemService.longitude))
            return;

        if (!force && solarLookupProc.running)
            return;

        if (!force && solarDate === systemService.date)
            return;

        solarLookupProc.exec({
            command: [Quickshell.shellPath("scripts/solar-lookup"), "--lat", systemService.latitude, "--lng", systemService.longitude, "--tz", systemService.timezone]
        });
    }

    Process {
        id: solarLookupProc

        stdout: StdioCollector {
            id: solarLookupStdout
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                return;

            const output = solarLookupStdout.text.trim();

            const match = output.match(/^(\d{1,2}):(\d{2})\s+(\d{1,2}):(\d{2})$/);

            if (!match)
                return;

            const sunriseH = Number(match[1]);
            const sunriseM = Number(match[2]);
            const sunsetH = Number(match[3]);
            const sunsetM = Number(match[4]);

            if (sunriseH > 23 || sunriseM > 59 || sunsetH > 23 || sunsetM > 59)
                return;

            systemService.sunrise = sunriseH * 60 + sunriseM;
            systemService.sunset = sunsetH * 60 + sunsetM;
            systemService.solarDate = systemService.date;
        }
    }

    // APPEARANCE

    property string appearance: "auto" // "light", "dark", "auto"

    readonly property string theme: {
        if (appearance !== "auto")
            return appearance;

        const minutes = systemClock.hours * 60 + systemClock.minutes;
        return minutes >= sunrise && minutes < sunset ? "light" : "dark";
    }

    onThemeChanged: Qt.callLater(triggerThemeChange)

    function triggerThemeChange(): void {
        if (themeChangeProc.running)
            return;

        themeChangeProc.exec({
            command: [Quickshell.shellPath("scripts/change-color-theme.sh"), theme]
        });
    }

    Process {
        id: themeChangeProc

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                return;

            const wallpapers = UserSettings.values.wallpaper;
            const paths = [wallpapers.light, wallpapers.dark].filter(path => !!path);

            Quickshell.execDetached([Quickshell.shellPath("scripts/change-wallpaper.sh"), ...paths]);
        }
    }

    // POWER

    function shutdown(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
    function restart(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }
    function sleep(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    // GENERAL

    readonly property bool identityReady: {
        Qt.application.organization = "orion-dots";
        Qt.application.domain = "orion-dots.local";
        return true;
    }

    Settings {
        location: Quickshell.statePath("system.ini")
        category: "System"

        property alias timezone: systemService.timezone
        property alias latitude: systemService.latitude
        property alias longitude: systemService.longitude
        property alias sunrise: systemService.sunrise
        property alias sunset: systemService.sunset
        property alias solarDate: systemService.solarDate
        property alias appearance: systemService.appearance
    }

    Timer {
        interval: 1000
        running: true

        onTriggered: {
            systemService.triggerSolarLookup();
            systemService.triggerPositionLookup();
        }
    }
}
