import QtQuick
import QtQuick.Layouts

import qs.singletons
import qs.components

QsText {
    id: keyboardModuleRoot

    Layout.preferredWidth: 20

    text: HyprlandService.keyboardLang
    fontSize: 14
    fontWeight: 600
    horizontalAlignment: Text.AlignHCenter
}
