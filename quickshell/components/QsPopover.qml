import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: popoverRoot

    property Component anchor
    property Component content

    property string verticalPosition: "top" // top | bottom | center
    property string horizontalPosition: "center" // left | center | right

    property real verticalOffset: 0
    property real horizontalOffset: 0

    property bool opened: false
    property bool _isExiting: false

    property var activePopup: null
    property bool hasActiveChild: false

    readonly property int shadowOffset: 20

    function open(): void {
        popoverRoot.opened = true;
    }

    function close(): void {
        if (popoverRoot.opened)
            popoverRoot._isExiting = true;
    }

    function toggle(): void {
        popoverRoot.opened ? popoverRoot.close() : popoverRoot.open();
    }

    function terminate(): void {
        popoverRoot.opened = false;
        popoverRoot._isExiting = false;
    }

    component Background: BorderImage {
        anchors {
            fill: parent
            margins: -40
        }

        border {
            left: 60
            top: 60
            right: 60
            bottom: 60
        }

        source: Qt.resolvedUrl("../assets/popover-shadow.png")

        Rectangle {
            anchors {
                fill: parent
                margins: 40
            }

            color: theme.popover
            radius: 10
            border.color: theme.border
            border.width: 1
        }
    }

    implicitWidth: anchorLoader.item?.implicitWidth ?? 0
    implicitHeight: anchorLoader.item?.implicitHeight ?? 0

    Loader {
        id: anchorLoader

        anchors.fill: parent
        sourceComponent: popoverRoot.anchor
    }

    LazyLoader {
        id: popupLoader

        active: popoverRoot.opened

        QtObject {
            property var focusGrab: HyprlandFocusGrab {
                windows: popoverRoot.activePopup ? [popoverRoot.activePopup] : []

                active: popoverRoot.opened && !popoverRoot._isExiting && !popoverRoot.hasActiveChild

                onCleared: {
                    if (!popoverRoot.hasActiveChild)
                        popoverRoot.close();
                }
            }

            property var window: PopupWindow {
                id: popoverPopup

                visible: true
                color: "transparent"

                implicitWidth: contentContainer.implicitWidth + popoverRoot.shadowOffset * 2
                implicitHeight: contentContainer.implicitHeight + popoverRoot.shadowOffset * 2

                anchor {
                    item: anchorLoader
                    edges: Edges.Top | Edges.Left
                    gravity: {
                        const vertical = popoverRoot.verticalPosition === "top" ? Edges.Top : popoverRoot.verticalPosition === "bottom" ? Edges.Bottom : 0;
                        const horizontal = popoverRoot.horizontalPosition === "left" ? Edges.Right : popoverRoot.horizontalPosition === "right" ? Edges.Left : 0;
                        return vertical | horizontal;
                    }

                    rect: {
                        const shadow = popoverRoot.shadowOffset;
                        const x = popoverRoot.horizontalPosition === "left" ? -shadow : popoverRoot.horizontalPosition === "right" ? anchorLoader.width + shadow : anchorLoader.width / 2;
                        const y = popoverRoot.verticalPosition === "top" ? shadow : popoverRoot.verticalPosition === "bottom" ? anchorLoader.height - shadow : anchorLoader.height / 2;

                        const offsetX = popoverRoot.horizontalOffset * (popoverRoot.horizontalPosition === "left" ? -1 : 1);
                        const offsetY = popoverRoot.verticalOffset * (popoverRoot.verticalPosition === "top" ? -1 : 1);

                        return Qt.rect(x + offsetX, y + offsetY, 1, 1);
                    }
                }

                Component.onCompleted: popoverRoot.activePopup = popoverPopup

                Component.onDestruction: {
                    if (popoverRoot.activePopup === popoverPopup)
                        popoverRoot.activePopup = null;
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!popoverRoot.hasActiveChild)
                            popoverRoot.close();
                    }
                }

                Item {
                    id: contentContainer

                    readonly property bool contentReady: contentLoader.item !== null

                    implicitWidth: contentReady ? contentLoader.item?.implicitWidth ?? 100 : 100

                    implicitHeight: contentReady ? contentLoader.item?.implicitHeight ?? 100 : 100

                    opacity: 0
                    scale: 0.95

                    anchors.centerIn: parent
                    transformOrigin: popoverRoot.verticalPosition === "top" ? Item.Bottom : popoverRoot.verticalPosition === "bottom" ? Item.Top : Item.Center

                    LazyLoader {
                        id: contentLoader

                        activeAsync: popoverRoot.opened
                        component: popoverRoot.content
                    }

                    Binding {
                        target: contentLoader.item

                        property: "parent"
                        value: contentContainer
                    }

                    states: [
                        State {
                            name: "visible"

                            when: popoverRoot.opened && !popoverRoot._isExiting && contentContainer.contentReady

                            PropertyChanges {
                                contentContainer {
                                    opacity: 1
                                    scale: 1
                                }
                            }
                        },
                        State {
                            name: "hidden"
                            when: popoverRoot._isExiting

                            PropertyChanges {
                                contentContainer {
                                    opacity: 0
                                    scale: 0.95
                                }
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: "*"
                            to: "visible"

                            ParallelAnimation {
                                NumberAnimation {
                                    property: "opacity"
                                    duration: 200
                                }

                                NumberAnimation {
                                    property: "scale"
                                    duration: 250
                                    easing.type: Easing.OutBack
                                }
                            }
                        },
                        Transition {
                            from: "*"
                            to: "hidden"

                            SequentialAnimation {
                                ParallelAnimation {
                                    NumberAnimation {
                                        property: "opacity"
                                        duration: 200
                                    }

                                    NumberAnimation {
                                        property: "scale"
                                        duration: 250
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                NumberAnimation {
                                    duration: 100
                                }

                                ScriptAction {
                                    script: popoverRoot.terminate()
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
