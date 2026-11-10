import QtQuick
import QtQuick.Controls.Basic

Switch {
    id: switchRoot

    property int textPosition: Qt.RightEdge

    implicitHeight: Math.max(indicator.implicitHeight, contentItem.implicitHeight)
    spacing: 8

    indicator: Rectangle {
        implicitWidth: 32
        implicitHeight: 18

        x: switchRoot.textPosition === Qt.RightEdge ? switchRoot.leftPadding : switchRoot.width - width - switchRoot.rightPadding
        y: parent.height / 2 - height / 2

        radius: 10
        color: switchRoot.checked ? theme.primary : (theme.state === "dark" ? Qt.alpha(theme.input, 0.15 * 0.8) : theme.input)

        Rectangle {
            x: switchRoot.checked ? parent.width - width - 1 : 1
            y: 1
            width: 16
            height: 16
            radius: 8
            color: switchRoot.checked ? (theme.state === "dark" ? theme.primaryForeground : theme.background) : (theme.state === "dark" ? theme.foreground : theme.background)

            Behavior on x {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    contentItem: QsText {
        text: switchRoot.text
        fontSize: 14
        fontWeight: 500
        opacity: switchRoot.enabled ? 1.0 : 0.5
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap

        leftPadding: switchRoot.textPosition === Qt.RightEdge ? switchRoot.indicator.implicitWidth + switchRoot.spacing : 0
        rightPadding: switchRoot.textPosition === Qt.LeftEdge ? switchRoot.indicator.implicitWidth + switchRoot.spacing : 0
    }
}
