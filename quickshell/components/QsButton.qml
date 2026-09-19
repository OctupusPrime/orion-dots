import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: buttonRoot

    property string variant: "default" // "default" | "outline" | "ghost" | "destructive" | "secondary" | "link"
    property string size: "default" // "default" | "xs" | "sm" | "lg" | "icon" | "icon-xs" | "icon-sm" | "icon-lg"
    property int radiusOverride: -1
    property url iconSource: ""

    property color _bgColor: theme.primary
    property color _hoverBgColor: Qt.alpha(theme.primary, 0.8)
    property color _borderColor: "transparent"
    property color _contentColor: theme.primaryForeground

    property int _width: -1
    property int _height: 32
    property int _radius: 10
    property int _padding: 10
    property int _gap: 6
    property int _fontSize: 14
    property int _iconSize: 16

    StateGroup {
        state: buttonRoot.variant
        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: theme.primary
                    _hoverBgColor: Qt.alpha(theme.primary, 0.8)
                    _borderColor: "transparent"
                    _contentColor: theme.primaryForeground
                }
            },
            State {
                name: "outline"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: theme.state === "dark" ? Qt.alpha(theme.input, 0.15 * 0.3) : theme.background
                    _hoverBgColor: theme.state === "dark" ? Qt.alpha(theme.input, 0.15 * 0.5) : theme.muted
                    _borderColor: theme.state === "dark" ? theme.input : theme.border
                    _contentColor: theme.foreground
                }
            },
            State {
                name: "secondary"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: theme.secondary
                    _hoverBgColor: Qt.alpha(theme.secondary, 0.8)
                    _borderColor: "transparent"
                    _contentColor: theme.secondaryForeground
                }
            },
            State {
                name: "ghost"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: Qt.alpha(theme.muted, 0)
                    _hoverBgColor: theme.state === "dark" ? Qt.alpha(theme.muted, 0.5) : theme.muted
                    _borderColor: "transparent"
                    _contentColor: theme.foreground
                }
            },
            State {
                name: "destructive"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: theme.state === "dark" ? Qt.alpha(theme.destructive, 0.2) : Qt.alpha(theme.destructive, 0.1)
                    _hoverBgColor: theme.state === "dark" ? Qt.alpha(theme.destructive, 0.3) : Qt.alpha(theme.destructive, 0.2)
                    _borderColor: "transparent"
                    _contentColor: theme.destructive
                }
            },
            State {
                name: "link"
                PropertyChanges {
                    target: buttonRoot
                    _bgColor: "transparent"
                    _hoverBgColor: "transparent"
                    _borderColor: "transparent"
                    _contentColor: theme.primary
                }
            }
        ]
    }
    StateGroup {
        state: buttonRoot.size
        states: [
            State {
                name: "xs"
                PropertyChanges {
                    target: buttonRoot
                    _width: -1
                    _height: 24
                    _radius: 8
                    _padding: 8
                    _gap: 4
                    _fontSize: 12
                    _iconSize: 12
                }
            },
            State {
                name: "sm"
                PropertyChanges {
                    target: buttonRoot
                    _width: -1
                    _height: 28
                    _radius: 8
                    _padding: 10
                    _gap: 4
                    _fontSize: 13
                    _iconSize: 16
                }
            },
            State {
                name: "default"
                PropertyChanges {
                    target: buttonRoot
                    _width: -1
                    _height: 32
                    _radius: 10
                    _padding: 10
                    _gap: 6
                    _fontSize: 14
                    _iconSize: 16
                }
            },
            State {
                name: "lg"
                PropertyChanges {
                    target: buttonRoot
                    _width: -1
                    _height: 36
                    _radius: 10
                    _padding: 10
                    _gap: 6
                    _fontSize: 14
                    _iconSize: 16
                }
            },
            State {
                name: "icon-xs"
                PropertyChanges {
                    target: buttonRoot
                    _height: 24
                    _width: 24
                    _radius: 8
                    _padding: 0
                    _gap: 0
                    _fontSize: 0
                    _iconSize: 12
                }
            },
            State {
                name: "icon-sm"
                PropertyChanges {
                    target: buttonRoot
                    _width: 28
                    _height: 28
                    _radius: 8
                    _padding: 0
                    _gap: 0
                    _fontSize: 0
                    _iconSize: 16
                }
            },
            State {
                name: "icon"
                PropertyChanges {
                    target: buttonRoot
                    _width: 32
                    _height: 32
                    _radius: 10
                    _padding: 0
                    _gap: 0
                    _fontSize: 0
                    _iconSize: 16
                }
            },
            State {
                name: "icon-lg"
                PropertyChanges {
                    target: buttonRoot
                    _width: 32
                    _height: 32
                    _radius: 10
                    _padding: 0
                    _gap: 0
                    _fontSize: 0
                    _iconSize: 16
                }
            }
        ]
    }

    hoverEnabled: enabled
    opacity: enabled ? 1.0 : 0.5
    implicitHeight: _height
    implicitWidth: _width > 0 ? _width : contentRow.implicitWidth + _padding * 2

    background: Rectangle {
        color: (buttonRoot.hovered || buttonRoot.pressed) ? buttonRoot._hoverBgColor : buttonRoot._bgColor
        border.color: buttonRoot._borderColor
        border.width: 1
        radius: buttonRoot.radiusOverride >= 0 ? buttonRoot.radiusOverride : buttonRoot._radius

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        RowLayout {
            id: contentRow
            spacing: buttonRoot._gap
            anchors.centerIn: parent

            QsIcon {
                visible: buttonRoot.iconSource.toString() !== ""
                source: buttonRoot.iconSource
                size: buttonRoot._iconSize
                color: buttonRoot._contentColor
            }

            QsText {
                visible: buttonRoot.text !== ""
                text: buttonRoot.text
                color: buttonRoot._contentColor
                fontSize: buttonRoot._fontSize
                fontWeight: 500
                font.underline: buttonRoot.variant === "link" ? buttonRoot.hovered || buttonRoot.pressed : false
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }
}
