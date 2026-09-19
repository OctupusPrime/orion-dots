import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.singletons

Item {
    id: root

    implicitWidth: 108
    implicitHeight: 24

    readonly property int activeWs: HyprlandService.activeWorkspaceId
    readonly property bool middleActive: activeWs === 2 || activeWs === 3

    readonly property var workspaceIcons: UserSettings.values.workspaces

    readonly property string activeIcon: workspaceIcons[activeWs] ?? ""
    readonly property bool showsIcon: activeIcon !== ""

    RowLayout {
        anchors.fill: parent
        spacing: 8

        WorkspaceDot {
            wsId: 1
        }

        RowLayout {
            spacing: 8
            Layout.preferredWidth: root.middleActive ? 76 : 24

            WorkspaceDot {
                visible: !root.showsIcon
                wsId: 2
            }

            Item {
                visible: root.showsIcon
                implicitWidth: 24
                implicitHeight: 24
                Layout.alignment: Qt.AlignHCenter

                Image {
                    anchors.fill: parent
                    source: root.activeIcon
                    sourceSize: Qt.size(48, 48)
                    fillMode: Image.PreserveAspectFit

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1
                        colorizationColor: theme.foreground
                    }
                }
            }

            WorkspaceDot {
                visible: !root.showsIcon
                wsId: 3
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        WorkspaceDot {
            wsId: 4
        }
    }

    component WorkspaceDot: Rectangle {
        required property int wsId

        readonly property bool active: root.activeWs === wsId

        height: 8
        radius: height / 2
        color: theme.foreground

        Layout.fillWidth: true
        Layout.preferredWidth: active ? 60 : 8

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
