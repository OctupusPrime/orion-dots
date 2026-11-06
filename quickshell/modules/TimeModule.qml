import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    readonly property var timeSettings: UserSettings.values.time
    readonly property var locale: Qt.locale(UserSettings.values.locale)

    readonly property bool isRow: shellPosition.direction === "row"
    readonly property bool is12Hour: timeSettings.timeFormat === "12h"

    readonly property string timeText: {
        if (is12Hour)
            return SystemService.date.toLocaleTimeString(locale, isRow ? "hh:mm" : "hh\nmm");

        return SystemService.date.toLocaleTimeString(locale, isRow ? "HH:mm" : "HH\nmm");
    }
    readonly property string periodText: SystemService.date.toLocaleTimeString(locale, "AP")

    spacing: -2

    GridLayout {
        columns: timeModuleRoot.isRow ? 2 : 1
        columnSpacing: 4
        rowSpacing: 0
        Layout.alignment: timeModuleRoot.isRow ? Qt.AlignRight : Qt.AlignHCenter

        QsText {
            text: timeModuleRoot.timeText
            textFormat: Text.PlainText
            fontWeight: 600
            font.features: {
                "tnum": 1
            }
            horizontalAlignment: timeModuleRoot.isRow ? Text.AlignRight : Text.AlignHCenter
            Layout.alignment: timeModuleRoot.isRow ? Qt.AlignBaseline : Qt.AlignHCenter
        }

        QsText {
            visible: timeModuleRoot.is12Hour
            text: timeModuleRoot.periodText
            textFormat: Text.PlainText
            fontSize: 14
            fontWeight: 600
            font.features: {
                "tnum": 1
            }
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: timeModuleRoot.isRow ? Qt.AlignBaseline : Qt.AlignHCenter
        }
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
