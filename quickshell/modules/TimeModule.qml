import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    readonly property var clockSettings: UserSettings.values.clock

    spacing: -1

    QsText {
        text: Qt.formatTime(SystemService.date, clockSettings.timeFormat)
        fontWeight: 600
        Layout.alignment: Qt.AlignRight
    }

    QsText {
        text: Qt.formatDate(SystemService.date, clockSettings.dateFormat)
        color: theme.mutedForeground
        fontSize: 12
        fontWeight: 500
        Layout.alignment: Qt.AlignRight
    }
}
