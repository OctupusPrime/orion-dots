import QtQuick

Item {
    id: positionRoot

    required property string position
    property real popoverOffset: 8

    property string direction: "row"

    // Shift content toward the pinned edge for optical alignment.
    readonly property int contentOffset: 1
    property int horizontalContentOffset: 0
    property int verticalContentOffset: 0

    readonly property QtObject shell: QtObject {
        property bool top: false
        property bool bottom: true
        property bool left: true
        property bool right: true
    }

    readonly property QtObject popover: QtObject {
        property string anchor: "top"
        property string alignment: "center"
        property real offset: positionRoot.popoverOffset
    }

    state: position

    states: [
        State {
            name: "top"

            PropertyChanges {
                target: positionRoot
                direction: "row"
                horizontalContentOffset: 0
                verticalContentOffset: -positionRoot.contentOffset
            }

            PropertyChanges {
                target: positionRoot.shell
                top: true
                bottom: false
                left: true
                right: true
            }

            PropertyChanges {
                target: positionRoot.popover
                anchor: "bottom"
            }
        },
        State {
            name: "bottom"

            PropertyChanges {
                target: positionRoot
                direction: "row"
                horizontalContentOffset: 0
                verticalContentOffset: positionRoot.contentOffset
            }

            PropertyChanges {
                target: positionRoot.shell
                top: false
                bottom: true
                left: true
                right: true
            }

            PropertyChanges {
                target: positionRoot.popover
                anchor: "top"
            }
        },
        State {
            name: "left"

            PropertyChanges {
                target: positionRoot
                direction: "column"
                horizontalContentOffset: -positionRoot.contentOffset
                verticalContentOffset: 0
            }

            PropertyChanges {
                target: positionRoot.shell
                top: true
                bottom: true
                left: true
                right: false
            }

            PropertyChanges {
                target: positionRoot.popover
                anchor: "right"
            }
        },
        State {
            name: "right"

            PropertyChanges {
                target: positionRoot
                direction: "column"
                horizontalContentOffset: positionRoot.contentOffset
                verticalContentOffset: 0
            }

            PropertyChanges {
                target: positionRoot.shell
                top: true
                bottom: true
                left: false
                right: true
            }

            PropertyChanges {
                target: positionRoot.popover
                anchor: "left"
            }
        }
    ]
}
