import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

QtObject {
    component MenuLabel: WrapperItem {
        id: menyLabelRoot

        property string text: ""

        leftMargin: 6
        rightMargin: 6
        topMargin: 4
        bottomMargin: 4
        anchors.left: parent ? parent.left : undefined
        anchors.right: parent ? parent.right : undefined

        QsText {
            text: menyLabelRoot.text
            color: theme.mutedForeground
            fontSize: 12
        }
    }

    component MenuItem: AbstractButton {
        id: menuItemRoot

        property bool hasSubMenu: false
        property var buttonType: 0 // 0: normal, 1: checkable, 2: radio
        property var checkState: 0 // 0: unchecked, 1: partially checked, 2: checked

        leftPadding: 6
        rightPadding: 6
        topPadding: 4
        bottomPadding: 4

        hoverEnabled: enabled
        opacity: enabled ? 1.0 : 0.5
        anchors.left: parent ? parent.left : undefined
        anchors.right: parent ? parent.right : undefined

        background: Rectangle {
            color: (menuItemRoot.hovered || menuItemRoot.pressed) ? theme.accent : Qt.alpha(theme.accent, 0)
            radius: 8

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        contentItem: RowLayout {
            id: contentRow
            spacing: 6

            QsText {
                text: menuItemRoot.text
                color: theme.popoverForeground
                fontSize: 14
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            QsIcon {
                visible: menuItemRoot.hasSubMenu
                source: icons.chevronRight
                size: 16
            }

            QsIcon {
                visible: menuItemRoot.buttonType > 0 && menuItemRoot.checkState > 0
                source: icons.check
                size: 16
            }
        }
    }

    component MenuSeparator: Item {
        id: menuSeparatorRoot

        height: 9
        anchors.left: parent ? parent.left : undefined
        anchors.right: parent ? parent.right : undefined

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: theme.border
        }
    }
}
