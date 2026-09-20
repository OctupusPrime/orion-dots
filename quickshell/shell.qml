import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.singletons
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

    Icons {
        id: icons
    }
    Theme {
        id: theme
        theme: SystemService.theme
    }
    I18n {
        id: i18n
        language: UserSettings.values.locale
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

                implicitHeight: 36
                color: Qt.alpha(theme.background, 0.75)

                RowLayout {
                    spacing: 14

                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }

                    SystemMenuModule {}

                    WorkspacesModule {}

                    AppsTrayModule {}
                }

                RowLayout {
                    spacing: 14

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 2
                    }

                    KeyboardModule {}

                    TimeModule {}
                }
            }
        }
    }
}
