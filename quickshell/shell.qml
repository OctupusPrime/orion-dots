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
    I18n {
        id: i18n
        language: UserSettings.values.locale
    }
    Theme {
        id: theme
        theme: SystemService.theme
    }
    Position {
        id: shellPosition
        position: UserSettings.values.appearance.position
        popoverOffset: UserSettings.values.appearance.popoverOffset
    }

    Variants {
        model: Quickshell.screens

        Component {
            PanelWindow {
                id: panel

                required property var modelData
                readonly property bool isRow: shellPosition.direction === "row"

                screen: modelData

                anchors {
                    top: shellPosition.shell.top
                    bottom: shellPosition.shell.bottom
                    left: shellPosition.shell.left
                    right: shellPosition.shell.right
                }

                implicitWidth: 36
                implicitHeight: 36

                color: Qt.alpha(theme.background, 0.75)

                GridLayout {
                    id: leftContents

                    columns: panel.isRow ? Math.max(1, visibleChildren.length) : 1
                    rowSpacing: 14
                    columnSpacing: 14

                    anchors {
                        verticalCenter: panel.isRow ? parent.verticalCenter : undefined
                        horizontalCenter: panel.isRow ? undefined : parent.horizontalCenter
                        left: panel.isRow ? parent.left : undefined
                        top: panel.isRow ? undefined : parent.top
                        leftMargin: 2
                        topMargin: 2
                    }
                }

                GridLayout {
                    columns: panel.isRow ? 3 : 1
                    rowSpacing: 14
                    columnSpacing: 14

                    anchors.centerIn: parent

                    SystemMenuModule {
                        Layout.alignment: Qt.AlignCenter
                    }

                    WorkspacesModule {
                        Layout.alignment: Qt.AlignCenter
                    }

                    AppsTrayModule {
                        Layout.alignment: Qt.AlignCenter
                    }
                }

                GridLayout {
                    columns: panel.isRow ? 2 : 1
                    rowSpacing: 14
                    columnSpacing: 14

                    anchors {
                        verticalCenter: panel.isRow ? parent.verticalCenter : undefined
                        horizontalCenter: panel.isRow ? undefined : parent.horizontalCenter
                        right: panel.isRow ? parent.right : undefined
                        bottom: panel.isRow ? undefined : parent.bottom
                        rightMargin: 2
                        bottomMargin: 2
                    }

                    KeyboardModule {
                        Layout.alignment: Qt.AlignCenter
                    }

                    TimeModule {
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        }
    }
}
