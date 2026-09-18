import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

ColumnLayout {
    id: timeModuleRoot

    spacing: 0

    QsText {
        text: SystemService.time
        fontWeight: 600
        Layout.alignment: Qt.AlignRight
    }

    QsText {
        text: SystemService.date
        color: theme.mutedForeground
        fontSize: 12
        fontWeight: 500
        Layout.alignment: Qt.AlignRight
    }
}
