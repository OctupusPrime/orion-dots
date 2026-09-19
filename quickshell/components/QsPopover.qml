import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: popoverRoot

    property Component anchor
    property Component content

    property bool opened: false
    property bool _isExiting: false

    property var activePopup: null
    property bool hasActiveChild: false

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

                implicitWidth: contentContainer.implicitWidth + 40
                implicitHeight: contentContainer.implicitHeight + 18

                anchor {
                    window: panel
                    edges: Edges.Bottom
                    gravity: Edges.Top

                    rect: {
                        const item = anchorLoader.item;

                        if (!item)
                            return Qt.rect(0, 0, 0, 0);

                        const pos = item.mapToItem(panel.contentItem, 0, 0);

                        return Qt.rect(pos.x, 0, item.width, 0);
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
                    transformOrigin: Item.Bottom

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
