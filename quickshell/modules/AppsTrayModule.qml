import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.components
import qs.singletons

QsPopover {
    id: appsTrayModuleRoot

    property real maxWidth: 184
    property real maxHeight: Screen.height * 0.6

    property var appItems: SystemTray.items
    property string activeAppId: ""

    property var menuStack: null

    readonly property var trayAppsIcons: UserSettings.values.tray

    onOpenedChanged: {
        if (appsTrayModuleRoot.opened)
            return;

        appsTrayModuleRoot.menuStack.clear();
        appsTrayModuleRoot.activeAppId = "";
    }

    anchor: AbstractButton {
        id: anchorButtonRoot

        property bool isActive: (appsTrayModuleRoot.opened && !appsTrayModuleRoot._isExiting) || hovered || pressed

        hoverEnabled: true
        onClicked: appsTrayModuleRoot.open()

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
                source: icons.boxes
                anchors.centerIn: parent
            }
        }
    }

    content: ColumnLayout {
        spacing: 8

        StackView {
            id: trayMenuStackView

            implicitWidth: appsTrayModuleRoot.maxWidth
            implicitHeight: appsTrayModuleRoot.maxHeight

            replaceEnter: null
            replaceExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    to: 0
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Component.onCompleted: appsTrayModuleRoot.menuStack = trayMenuStackView

            Component.onDestruction: {
                if (appsTrayModuleRoot.menuStack === trayMenuStackView)
                    appsTrayModuleRoot.menuStack = null;
            }
        }

        Item {
            property int margin: 4
            property int minSize: 32

            implicitWidth: Math.max(minSize, appsGridContainer.implicitWidth) + (margin * 2)
            implicitHeight: Math.max(minSize, appsGridContainer.implicitHeight) + (margin * 2)
            Layout.alignment: Qt.AlignCenter

            QsPopover.Background {}

            MouseArea {
                anchors.fill: parent
            }

            Grid {
                id: appsGridContainer

                anchors.fill: parent
                anchors.margins: parent.margin
                columns: Math.min(appsGridRepeater.count, 5)
                spacing: 4

                Repeater {
                    id: appsGridRepeater

                    model: appsTrayModuleRoot.appItems

                    delegate: AppItem {
                        required property SystemTrayItem modelData

                        appId: modelData.id
                        iconSource: modelData.icon
                        active: appsTrayModuleRoot.activeAppId === modelData.id

                        onClicked: {
                            appsTrayModuleRoot.activeAppId = modelData.id;
                            appsTrayModuleRoot.menuStack.replaceCurrentItem(trayMenuFactory, {
                                modelData: modelData
                            });
                        }

                        onMiddleClicked: Quickshell.clipboardText = modelData.id
                    }
                }
            }
        }
    }

    Component {
        id: trayMenuFactory

        ColumnLayout {
            id: trayMenuRoot

            required property SystemTrayItem modelData

            Item {
                id: trayMenuContainer

                readonly property bool hasContent: traySubMenuStack.currentItem && traySubMenuStack.currentItem.implicitHeight > 0

                implicitHeight: hasContent ? traySubMenuStack.currentItem.implicitHeight : 0
                transformOrigin: Item.Bottom
                opacity: 0
                scale: 0.95
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true

                states: [
                    State {
                        name: "visible"
                        when: trayMenuContainer.hasContent
                        PropertyChanges {
                            trayMenuContainer {
                                opacity: 1
                                scale: 1
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
                    }
                ]

                QsPopover.Background {}

                MouseArea {
                    anchors.fill: parent
                }

                StackView {
                    id: traySubMenuStack

                    anchors.fill: parent
                    clip: true

                    Component.onCompleted: {
                        traySubMenuStack.push(traySubMenuFactory, {
                            handle: trayMenuRoot.modelData.menu,
                            isSubMenu: false
                        });
                    }
                    Component.onDestruction: {
                        traySubMenuStack.clear();
                    }

                    pushEnter: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 1
                        }
                        PropertyAnimation {
                            property: "x"
                            from: traySubMenuStack.width
                            to: 0
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    pushExit: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 0
                        }
                        PropertyAnimation {
                            property: "x"
                            from: 0
                            to: -traySubMenuStack.width
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    popEnter: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 1
                        }
                        PropertyAnimation {
                            property: "x"
                            from: -traySubMenuStack.width
                            to: 0
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    popExit: Transition {
                        PropertyAction {
                            property: "opacity"
                            value: 0
                        }
                        PropertyAnimation {
                            property: "x"
                            from: 0
                            to: traySubMenuStack.width
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Component {
        id: traySubMenuFactory

        ListView {
            id: traySubMenuRoot

            required property QsMenuHandle handle
            property bool isSubMenu: false
            property int margin: 4

            topMargin: margin
            bottomMargin: isSubMenu ? 48 : margin
            implicitHeight: contentHeight > 0 ? Math.min(contentHeight + topMargin + bottomMargin, appsTrayModuleRoot.maxHeight) : 0
            layer.enabled: StackView.view ? StackView.view.busy : false
            layer.smooth: true

            QsMenuOpener {
                id: traySubMenuOpener

                menu: traySubMenuRoot.handle
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            model: traySubMenuOpener.children

            delegate: DelegateChooser {
                role: "isSeparator"

                DelegateChoice {
                    roleValue: true

                    QsDropdown.MenuSeparator {}
                }

                DelegateChoice {
                    roleValue: false

                    QsDropdown.MenuItem {
                        required property var modelData

                        anchors.leftMargin: traySubMenuRoot.margin
                        anchors.rightMargin: traySubMenuRoot.margin

                        text: modelData.text
                        enabled: modelData.enabled
                        hasSubMenu: modelData.hasChildren
                        buttonType: modelData.buttonType
                        checkState: modelData.checkState

                        onClicked: {
                            if (modelData.hasChildren) {
                                traySubMenuRoot.StackView.view.pushItem(traySubMenuFactory, {
                                    handle: modelData,
                                    isSubMenu: true
                                });
                                return;
                            }

                            modelData.triggered();

                            if (modelData.buttonType === QsMenuButtonType.None)
                                appsTrayModuleRoot.close();
                        }
                    }
                }
            }

            CloseSubMenuButton {
                visible: traySubMenuRoot.isSubMenu
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: traySubMenuRoot.StackView.view.popCurrentItem()
            }
        }
    }

    component AppItem: AbstractButton {
        id: appItemRoot

        required property var appId
        property string iconSource
        property bool active

        signal middleClicked

        hoverEnabled: true

        function getIconSource(id: string, pathname: string): string {
            if (Object.prototype.hasOwnProperty.call(appsTrayModuleRoot.trayAppsIcons, id)) {
                return Qt.resolvedUrl(appsTrayModuleRoot.trayAppsIcons[id]);
            }

            if (pathname.includes("?path=")) {
                const [name, path] = pathname.split("?path=");
                return Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
            }
            return pathname;
        }

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: mouse => {
                if (mouse.button === Qt.MiddleButton)
                    appItemRoot.middleClicked();
                else
                    appItemRoot.clicked();
            }
        }

        background: Rectangle {
            color: appItemRoot.active || appItemRoot.hovered || appItemRoot.pressed ? theme.accent : Qt.alpha(theme.accent, 0)
            radius: 8

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        contentItem: Item {
            implicitWidth: 32
            implicitHeight: 32

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: appItemRoot.getIconSource(appItemRoot.appId, appItemRoot.iconSource)
                sourceSize: Qt.size(20, 20)
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    component CloseSubMenuButton: Item {
        id: closeSubMenuButtonRoot

        signal clicked

        height: 48
        Layout.fillWidth: true

        Rectangle {
            anchors.fill: parent
            radius: 10

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "transparent"
                }
                GradientStop {
                    position: 1
                    color: theme.popover
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onWheel: wheel.accepted = true
        }

        Rectangle {
            id: buttonWrapper

            width: backButton.width
            height: backButton.height
            radius: 8
            color: theme.background
            anchors.centerIn: parent

            QsButton {
                id: backButton

                size: "sm"
                variant: "secondary"
                text: i18n.t("appsTray.back")
                onClicked: closeSubMenuButtonRoot.clicked()
            }
        }
    }
}
