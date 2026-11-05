import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    readonly property var timeSettings: UserSettings.values.time
    readonly property var locale: Qt.locale(UserSettings.values.locale)

    readonly property bool isRow: shellPosition.direction === "row"

    readonly property string timeFormat: {
        if (timeSettings.timeFormat === "12h")
            return isRow ? "hh:mm AP" : "hh\nmm\nAP";

        return isRow ? "HH:mm" : "HH\nmm";
    }

    spacing: -2

    QsText {
        text: SystemService.date.toLocaleTimeString(timeModuleRoot.locale, timeModuleRoot.timeFormat)
        fontWeight: 600
        horizontalAlignment: timeModuleRoot.isRow ? Text.AlignRight : Text.AlignHCenter
        Layout.alignment: timeModuleRoot.isRow ? Qt.AlignRight : Qt.AlignHCenter
    }

    QsText {
        visible: timeModuleRoot.isRow
        text: SystemService.date.toLocaleDateString(timeModuleRoot.locale, timeModuleRoot.timeSettings.dateFormat)
        color: theme.mutedForeground
        fontSize: 12
        fontWeight: 500
        Layout.alignment: Qt.AlignRight
    }
}
