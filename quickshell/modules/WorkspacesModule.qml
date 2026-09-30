import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.singletons

Item {
    id: root

    readonly property bool isRow: shellPosition.direction === "row"

    property bool animationsReady: false
    Component.onCompleted: Qt.callLater(() => {
        root.animationsReady = true;
    })

    implicitWidth: isRow ? 84 : 24
    implicitHeight: isRow ? 24 : 84

    readonly property int activeWs: HyprlandService.activeWorkspaceId
    readonly property bool middleActive: activeWs === 2 || activeWs === 3

    readonly property var workspaceIcons: UserSettings.values.workspaces

    readonly property string activeIcon: workspaceIcons[activeWs] ?? ""
    readonly property bool showsIcon: activeIcon !== ""

    GridLayout {
        anchors.fill: parent
        columns: root.isRow ? 3 : 1
        rowSpacing: 6
        columnSpacing: 6

        WorkspaceDot {
            wsId: 1
        }

        GridLayout {
            columns: root.isRow ? 3 : 1
            rowSpacing: 6
            columnSpacing: 6
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.isRow ? (root.middleActive ? 60 : 18) : -1
            Layout.preferredHeight: root.isRow ? -1 : (root.middleActive ? 60 : 18)

            WorkspaceDot {
                visible: !root.showsIcon
                wsId: 2
            }

            Item {
                visible: root.showsIcon
                implicitWidth: root.isRow ? 26 : 22
                implicitHeight: root.isRow ? 22 : 26
                Layout.alignment: Qt.AlignCenter

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    height: 22

                    source: root.activeIcon
                    sourceSize: Qt.size(22, 22)
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
                enabled: root.animationsReady && root.isRow

                NumberAnimation {
                    duration: 150
                }
            }

            Behavior on Layout.preferredHeight {
                enabled: root.animationsReady && !root.isRow

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

        implicitWidth: 6
        implicitHeight: 6
        radius: Math.min(width, height) / 2
        color: theme.foreground

        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: root.isRow
        Layout.fillHeight: !root.isRow
        Layout.preferredWidth: root.isRow && active ? 48 : 6
        Layout.preferredHeight: !root.isRow && active ? 48 : 6

        Behavior on Layout.preferredWidth {
            enabled: root.animationsReady && root.isRow

            NumberAnimation {
                duration: 150
            }
        }

        Behavior on Layout.preferredHeight {
            enabled: root.animationsReady && !root.isRow

            NumberAnimation {
                duration: 150
            }
        }
    }
}
