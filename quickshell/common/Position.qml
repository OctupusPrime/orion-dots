import QtQuick

Item {
    id: positionRoot

    required property string position
    property string direction: "row"

    readonly property QtObject shell: QtObject {
        property bool top: false
        property bool bottom: true
        property bool left: true
        property bool right: true
    }

    readonly property QtObject popover: QtObject {
        property string vertical: "top"
        property string horizontal: "center"
        property real verticalOffset: 8
        property real horizontalOffset: 0
    }

    state: position

    states: [
        State {
            name: "top"

            PropertyChanges {
                target: positionRoot
                direction: "row"
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
                vertical: "bottom"
                horizontal: "center"
                verticalOffset: 8
                horizontalOffset: 0
            }
        },
        State {
            name: "bottom"

            PropertyChanges {
                target: positionRoot
                direction: "row"
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
                vertical: "top"
                horizontal: "center"
                verticalOffset: 8
                horizontalOffset: 0
            }
        },
        State {
            name: "left"

            PropertyChanges {
                target: positionRoot
                direction: "column"
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
                vertical: "center"
                horizontal: "right"
                verticalOffset: 0
                horizontalOffset: 8
            }
        },
        State {
            name: "right"

            PropertyChanges {
                target: positionRoot
                direction: "column"
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
                vertical: "center"
                horizontal: "left"
                verticalOffset: 0
                horizontalOffset: 8
            }
        }
    ]
}
