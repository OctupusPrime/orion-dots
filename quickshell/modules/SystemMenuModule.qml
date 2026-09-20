import QtQuick
import QtQuick.Controls

import qs.singletons
import qs.components

QsPopover {
    id: systemMenuModuleRoot

    property real maxWidth: 148
    property real maxHeight: Screen.height * 0.6

    anchor: AbstractButton {
        id: anchorButtonRoot

        property bool isActive: (systemMenuModuleRoot.opened && !systemMenuModuleRoot._isExiting) || hovered || pressed

        hoverEnabled: true
        onClicked: systemMenuModuleRoot.open()

        background: Rectangle {
            color: anchorButtonRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.muted, 0)
            radius: 10

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        contentItem: Item {
            implicitWidth: 34
            implicitHeight: 34

            QsIcon {
                source: icons.arch
                anchors.centerIn: parent
            }
        }
    }

    ListModel {
        id: systemMenuModel

        ListElement {
            type: "label"
            textKey: "systemMenu.appearance"
        }
        ListElement {
            type: "appearanceItem"
            textKey: "systemMenu.light"
            value: "light"
        }
        ListElement {
            type: "appearanceItem"
            textKey: "systemMenu.adaptive"
            value: "auto"
        }
        ListElement {
            type: "appearanceItem"
            textKey: "systemMenu.dark"
            value: "dark"
        }
        ListElement {
            type: "separator"
        }
        ListElement {
            type: "label"
            textKey: "systemMenu.system"
        }
        ListElement {
            type: "item"
            textKey: "systemMenu.sleep"
            onClicked: function () {
                SystemService.sleep();
            }
        }
        ListElement {
            type: "item"
            textKey: "systemMenu.shutdown"
            onClicked: function () {
                SystemService.shutdown();
            }
        }
        ListElement {
            type: "item"
            textKey: "systemMenu.restart"
            onClicked: function () {
                SystemService.restart();
            }
        }
    }

    content: Item {
        implicitWidth: contentListView.implicitWidth
        implicitHeight: contentListView.implicitHeight

        QsPopover.Background {}

        ListView {
            id: contentListView

            property int margin: 4

            anchors.fill: parent

            topMargin: margin
            bottomMargin: margin

            implicitWidth: systemMenuModuleRoot.maxWidth
            implicitHeight: Math.min(contentHeight + topMargin + bottomMargin, systemMenuModuleRoot.maxHeight)

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            model: systemMenuModel

            delegate: DelegateChooser {
                role: "type"

                DelegateChoice {
                    roleValue: "separator"

                    QsDropdown.MenuSeparator {}
                }
                DelegateChoice {
                    roleValue: "label"

                    QsDropdown.MenuLabel {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: i18n.t(modelData.textKey)
                    }
                }
                DelegateChoice {
                    roleValue: "item"

                    QsDropdown.MenuItem {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: i18n.t(modelData.textKey)
                        onClicked: modelData.onClicked()
                    }
                }
                DelegateChoice {
                    roleValue: "appearanceItem"

                    QsDropdown.MenuItem {
                        required property var modelData

                        anchors.leftMargin: contentListView.margin
                        anchors.rightMargin: contentListView.margin

                        text: i18n.t(modelData.textKey)
                        buttonType: 2
                        checkState: SystemService.appearance === modelData.value ? 2 : 0
                        onClicked: {
                            SystemService.appearance = modelData.value;
                        }
                    }
                }
            }
        }
    }
}
