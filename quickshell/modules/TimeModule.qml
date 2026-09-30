import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    readonly property bool isRow: shellPosition.direction === "row"

    spacing: -2

    QsText {
        text: Qt.formatTime(SystemService.date, timeModuleRoot.isRow ? "HH:mm" : "HH\nmm")
        fontWeight: 600
        horizontalAlignment: timeModuleRoot.isRow ? Text.AlignRight : Text.AlignHCenter
        Layout.alignment: timeModuleRoot.isRow ? Qt.AlignRight : Qt.AlignHCenter
    }

    QsText {
        visible: timeModuleRoot.isRow
        text: Qt.formatDate(SystemService.date, "dd/MM/yyyy")
        color: theme.mutedForeground
        fontSize: 12
        fontWeight: 500
        Layout.alignment: Qt.AlignRight
    }
}
