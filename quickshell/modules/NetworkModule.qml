import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking

import qs.singletons
import qs.components

QsPopover {
    id: networkModuleRoot

    position: shellPosition.popover
    animateFrom: shellPosition.position

    property real maxWidth: 280
    property real maxHeight: Screen.height * 0.6

    onOpenedChanged: {
        if (opened && Networking.canCheckConnectivity && Networking.connectivityCheckEnabled)
            Networking.checkConnectivity();
    }

    anchor: AbstractButton {
        id: anchorButtonRoot

        property bool isActive: (networkModuleRoot.opened && !networkModuleRoot._isExiting) || hovered || pressed

        hoverEnabled: true
        onClicked: networkModuleRoot.open()

        background: Rectangle {
            color: anchorButtonRoot.isActive ? Qt.alpha(theme.muted, 0.75) : Qt.alpha(theme.background, 0.5)

            radius: 20
            border.width: 1
            border.color: anchorButtonRoot.isActive ? theme.border : Qt.alpha(theme.border, 0)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        readonly property string wifiIcon: {
            if (!NetworkService.connectedWifi)
                return "";

            if (Networking.connectivity === NetworkConnectivity.None)
                return "";
            if (Networking.connectivity === NetworkConnectivity.Limited)
                return icons.wifiLimited;
            if (Networking.connectivity === NetworkConnectivity.Portal)
                return icons.wifiLimited;

            const strength = NetworkService.connectedWifi.signalStrength;

            if (strength > 0.6)
                return icons.wifi;
            if (strength > 0.3)
                return icons.wifiHigh;
            return icons.wifiLow;
        }

        readonly property string ethernetIcon: {
            if (!NetworkService.connectedWiredDevice)
                return "";

            if (Networking.connectivity === NetworkConnectivity.None)
                return "";
            if (Networking.connectivity === NetworkConnectivity.Limited)
                return icons.ethernetPortLimited;
            if (Networking.connectivity === NetworkConnectivity.Portal)
                return icons.ethernetPortLimited;

            return icons.ethernetPort;
        }

        readonly property string offlineIcon: {
            if (NetworkService.connectedWifi)
                return "";
            if (NetworkService.connectedWiredDevice)
                return "";

            return icons.globeOff;
        }

        contentItem: Grid {
            columns: shellPosition.direction === "row" ? Math.max(1, visibleChildren.length) : 1
            spacing: 4
            padding: 4

            Item {
                visible: anchorButtonRoot.wifiIcon !== ""
                implicitWidth: 22
                implicitHeight: 22

                QsIcon {
                    anchors.centerIn: parent
                    size: 18
                    source: anchorButtonRoot.wifiIcon
                }
            }

            Item {
                visible: anchorButtonRoot.ethernetIcon !== ""
                implicitWidth: 22
                implicitHeight: 22

                QsIcon {
                    anchors.centerIn: parent
                    size: 18
                    source: anchorButtonRoot.ethernetIcon
                }
            }

            Item {
                visible: anchorButtonRoot.offlineIcon !== ""
                implicitWidth: 22
                implicitHeight: 22

                QsIcon {
                    anchors.centerIn: parent
                    size: 18
                    source: anchorButtonRoot.offlineIcon
                    color: Qt.alpha(theme.primary, 0.5)
                }
            }
        }
    }

    content: Item {
        implicitWidth: networkModuleRoot.maxWidth
        implicitHeight: Math.min(networkContent.implicitHeight, networkModuleRoot.maxHeight)

        QsPopover.Background {}

        ScrollView {
            id: networkScrollView

            anchors.fill: parent
            clip: true
            contentWidth: availableWidth

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: networkContent

                width: networkScrollView.availableWidth
                spacing: 0

                ColumnLayout {
                    id: wifiSection

                    visible: NetworkService.wifiSupported
                    Layout.fillWidth: true
                    Layout.margins: 10
                    spacing: 4

                    QsSwitch {
                        Layout.fillWidth: true
                        padding: 0
                        text: i18n.t("network.wifi")
                        textPosition: Qt.LeftEdge
                        checked: NetworkService.wifiEnabled
                        onToggled: NetworkService.setWifiEnabled(checked)
                    }

                    QsText {
                        Layout.fillWidth: true
                        text: NetworkService.connectedWifi ? i18n.t("network.connectedSignal", {
                            strength: Math.round(NetworkService.connectedWifi.signalStrength * 100)
                        }) : i18n.t("network.disconnected")
                        fontSize: 14
                        color: theme.mutedForeground
                        elide: Text.ElideRight
                    }

                    QsText {
                        Layout.fillWidth: true
                        visible: NetworkService.connectedWifi !== null
                        text: NetworkService.connectedWifi?.name ?? ""
                        fontSize: 14
                        color: theme.popoverForeground
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    visible: ethernetSection.visible
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: theme.border
                }

                ColumnLayout {
                    id: ethernetSection

                    visible: NetworkService.wiredSupported
                    Layout.fillWidth: true
                    Layout.margins: 10
                    spacing: 4

                    QsSwitch {
                        Layout.fillWidth: true
                        padding: 0
                        text: i18n.t("network.ethernet")
                        textPosition: Qt.LeftEdge
                        checked: NetworkService.wiredEnabled
                        onToggled: NetworkService.setWiredEnabled(checked)
                    }

                    QsText {
                        Layout.fillWidth: true
                        text: NetworkService.connectedWiredDevice ? i18n.t("network.connected") : i18n.t("network.disconnected")
                        fontSize: 14
                        color: theme.mutedForeground
                        elide: Text.ElideRight
                    }
                }

                QsText {
                    id: noConnectionSection

                    visible: !NetworkService.wifiSupported && !NetworkService.wiredSupported
                    Layout.fillWidth: true
                    Layout.margins: 12
                    text: i18n.t("network.noConnection")
                    fontSize: 14
                    color: theme.mutedForeground
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    visible: limitedConnectivitySection.visible
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: theme.border
                }

                ColumnLayout {
                    id: limitedConnectivitySection

                    visible: Networking.connectivity === NetworkConnectivity.Limited
                    Layout.fillWidth: true
                    Layout.margins: 10
                    spacing: 8

                    QsText {
                        Layout.fillWidth: true
                        text: i18n.t("network.limitedConnectivity")
                        fontSize: 14
                        fontWeight: 500
                        color: theme.popoverForeground
                    }

                    QsText {
                        Layout.fillWidth: true
                        text: i18n.t("network.limitedConnectivityDescription")
                        fontSize: 14
                        color: theme.mutedForeground
                        wrapMode: Text.WordWrap
                    }

                    QsButton {
                        Layout.fillWidth: true
                        text: i18n.t("network.openLoginPage")
                        size: "sm"
                        onClicked: {
                            Qt.openUrlExternally("http://neverssl.com/");
                            networkModuleRoot.close();
                        }
                    }
                }
            }
        }
    }
}
