import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: popoverRoot

    property Component anchor
    property Component content

    property string animateFrom: "bottom" // top | bottom | left | right | center

    property QtObject position: QtObject {
        property string vertical: "top" // top | bottom | center
        property string horizontal: "center" // left | center | right
        property real offset: 8
    }

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

                readonly property bool isHorizontalShell: popoverRoot.position.vertical !== "center"
                property point anchorPosition: Qt.point(0, 0)

                readonly property rect contentRect: {
                    const shell = anchorLoader.QsWindow.window;
                    if (!shell)
                        return Qt.rect(0, 0, 0, 0);

                    const offset = Math.max(0, popoverRoot.position.offset);
                    const width = contentContainer.implicitWidth;
                    const height = contentContainer.implicitHeight;
                    let x = anchorPosition.x + (anchorLoader.width - width) / 2;
                    let y = anchorPosition.y + (anchorLoader.height - height) / 2;

                    if (isHorizontalShell) {
                        if (popoverRoot.position.horizontal === "left")
                            x = anchorPosition.x;
                        else if (popoverRoot.position.horizontal === "right")
                            x = anchorPosition.x + anchorLoader.width - width;

                        // Keep the visible content the same distance from either screen edge.
                        x = Math.max(offset, Math.min(x, shell.width - width - offset));
                        y = popoverRoot.position.vertical === "top" ? -height - offset : shell.height + offset;
                    } else {
                        x = popoverRoot.position.horizontal === "left" ? -width - offset : shell.width + offset;
                        y = Math.max(offset, Math.min(y, shell.height - height - offset));
                    }

                    return Qt.rect(x, y, width, height);
                }

                // Trim only the shadow padding that would extend past a screen edge.
                readonly property real leftPadding: isHorizontalShell ? Math.min(popoverRoot.shadowOffset, Math.max(0, contentRect.x)) : popoverRoot.shadowOffset
                readonly property real rightPadding: isHorizontalShell ? Math.min(popoverRoot.shadowOffset, Math.max(0, (anchorLoader.QsWindow.window?.width ?? 0) - contentRect.x - contentRect.width)) : popoverRoot.shadowOffset
                readonly property real topPadding: isHorizontalShell ? popoverRoot.shadowOffset : Math.min(popoverRoot.shadowOffset, Math.max(0, contentRect.y))
                readonly property real bottomPadding: isHorizontalShell ? popoverRoot.shadowOffset : Math.min(popoverRoot.shadowOffset, Math.max(0, (anchorLoader.QsWindow.window?.height ?? 0) - contentRect.y - contentRect.height))

                implicitWidth: contentContainer.implicitWidth + leftPadding + rightPadding
                implicitHeight: contentContainer.implicitHeight + topPadding + bottomPadding

                anchor {
                    window: anchorLoader.QsWindow.window
                    edges: Edges.Top | Edges.Left
                    gravity: Edges.Bottom | Edges.Right
                    adjustment: popoverPopup.isHorizontalShell ? PopupAdjustment.SlideY : PopupAdjustment.SlideX
                    rect: Qt.rect(popoverPopup.contentRect.x - popoverPopup.leftPadding, popoverPopup.contentRect.y - popoverPopup.topPadding, 1, 1)

                    onAnchoring: {
                        popoverPopup.anchorPosition = anchorLoader.mapToItem(anchorLoader.QsWindow.contentItem, 0, 0);
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

                    x: popoverPopup.leftPadding
                    y: popoverPopup.topPadding

                    opacity: 0
                    scale: 0.95

                    transformOrigin: {
                        switch (popoverRoot.animateFrom) {
                        case "top":
                            return Item.Top;
                        case "bottom":
                            return Item.Bottom;
                        case "left":
                            return Item.Left;
                        case "right":
                            return Item.Right;
                        default:
                            return Item.Center;
                        }
                    }

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
