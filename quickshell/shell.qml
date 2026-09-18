import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.common
import qs.modules

ShellRoot {
    FontLoader {
        id: geistFont
        source: Qt.resolvedUrl("./assets/Geist.ttf")
    }
    FontLoader {
        id: iconsFont
        source: Qt.resolvedUrl("./assets/Icons.ttf")
    }

    Theme {
        id: theme
    }
    Icons {
        id: iconData
    }

    Variants {
        model: Quickshell.screens

        Component {
            PanelWindow {
                id: panel

                required property var modelData
                screen: modelData

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                implicitHeight: 44
                color: Qt.alpha(theme.background, 0.75)

                RowLayout {
                    spacing: 16

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 6
                    }

                    KeyboardModule {}

                    TimeModule {}
                }
            }
        }
    }
}
