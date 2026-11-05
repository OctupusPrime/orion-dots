import Quickshell
import Quickshell.Hyprland
import QtQuick

Item {
    id: popoverRoot

    property Component anchor
    property Component content

    property string animateFrom: "bottom" // top | bottom | left | right | center

    property QtObject position: QtObject {
        property string anchor: "top" // left | right | top | bottom
        property string alignment: "center" // start | center | end
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

                readonly property var anchorWindow: anchorLoader.QsWindow.window
                readonly property bool isSideAnchor: popoverRoot.position.anchor === "left" || popoverRoot.position.anchor === "right"
                readonly property point anchorPosition: {
                    // Coordinate mapping is not reactive; watch the entire path to the trigger.
                    anchorTransform.transform;
                    return anchorLoader.mapToItem(anchorTransform.a, 0, 0);
                }

                TransformWatcher {
                    id: anchorTransform

                    a: anchorLoader.QsWindow.contentItem
                    b: anchorLoader
                }

                // Start/end mean left/right for top/bottom, and top/bottom for left/right.
                function alignedCoordinate(start: real, anchorSize: real, contentSize: real, availableSize: real): real {
                    let coordinate = start;
                    if (popoverRoot.position.alignment === "end")
                        coordinate += anchorSize - contentSize;
                    else if (popoverRoot.position.alignment === "center")
                        coordinate += (anchorSize - contentSize) / 2;

                    return Math.max(popoverRoot.position.offset, Math.min(coordinate, availableSize - contentSize - popoverRoot.position.offset));
                }

                readonly property rect contentRect: {
                    if (!anchorWindow)
                        return Qt.rect(0, 0, 0, 0);

                    const width = contentContainer.width;
                    const height = contentContainer.height;
                    let x = alignedCoordinate(anchorPosition.x, anchorLoader.width, width, anchorWindow.width);
                    let y = alignedCoordinate(anchorPosition.y, anchorLoader.height, height, anchorWindow.height);

                    // Keep the gap relative to the panel edge, independent of the trigger size.
                    switch (popoverRoot.position.anchor) {
                    case "left":
                        x = -width - popoverRoot.position.offset;
                        break;
                    case "right":
                        x = anchorWindow.width + popoverRoot.position.offset;
                        break;
                    case "top":
                        y = -height - popoverRoot.position.offset;
                        break;
                    case "bottom":
                        y = anchorWindow.height + popoverRoot.position.offset;
                        break;
                    }

                    return Qt.rect(x, y, width, height);
                }

                // Trim only the shadow padding that would extend past a screen edge.
                readonly property real leftPadding: isSideAnchor ? popoverRoot.shadowOffset : Math.min(popoverRoot.shadowOffset, Math.max(0, contentRect.x))
                readonly property real rightPadding: isSideAnchor ? popoverRoot.shadowOffset : Math.min(popoverRoot.shadowOffset, Math.max(0, (anchorWindow?.width ?? 0) - contentRect.x - contentRect.width))
                readonly property real topPadding: isSideAnchor ? Math.min(popoverRoot.shadowOffset, Math.max(0, contentRect.y)) : popoverRoot.shadowOffset
                readonly property real bottomPadding: isSideAnchor ? Math.min(popoverRoot.shadowOffset, Math.max(0, (anchorWindow?.height ?? 0) - contentRect.y - contentRect.height)) : popoverRoot.shadowOffset

                implicitWidth: contentContainer.width + leftPadding + rightPadding
                implicitHeight: contentContainer.height + topPadding + bottomPadding

                anchor {
                    window: popoverPopup.anchorWindow
                    edges: Edges.Top | Edges.Left
                    gravity: Edges.Bottom | Edges.Right
                    adjustment: popoverPopup.isSideAnchor ? PopupAdjustment.SlideX : PopupAdjustment.SlideY
                    rect: Qt.rect(popoverPopup.contentRect.x - popoverPopup.leftPadding, popoverPopup.contentRect.y - popoverPopup.topPadding, 1, 1)
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

                    // Use the live size so both explicit and implicit content resizing repositions the popup.
                    implicitWidth: contentLoader.item?.width ?? 0
                    implicitHeight: contentLoader.item?.height ?? 0

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
