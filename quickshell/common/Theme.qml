import QtQuick

import qs.singletons

Item {
    id: themeRoot

    property color background
    property color foreground
    property color card
    property color cardForeground
    property color popover
    property color popoverForeground
    property color primary
    property color primaryForeground
    property color secondary
    property color secondaryForeground
    property color muted
    property color mutedForeground
    property color accent
    property color accentForeground
    property color destructive
    property color destructiveForeground
    property color border
    property color input
    property color ring

    state: SystemService.theme

    states: [
        State {
            name: "light"
            PropertyChanges {
                themeRoot {
                    background: Qt.rgba(255 / 255, 255 / 255, 255 / 255)
                    foreground: Qt.rgba(10 / 255, 10 / 255, 10 / 255)
                    card: Qt.rgba(255 / 255, 255 / 255, 255 / 255)
                    cardForeground: Qt.rgba(10 / 255, 10 / 255, 10 / 255)
                    popover: Qt.rgba(255 / 255, 255 / 255, 255 / 255)
                    popoverForeground: Qt.rgba(10 / 255, 10 / 255, 10 / 255)
                    primary: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    primaryForeground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    secondary: Qt.rgba(245 / 255, 245 / 255, 245 / 255)
                    secondaryForeground: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    muted: Qt.rgba(245 / 255, 245 / 255, 245 / 255)
                    mutedForeground: Qt.rgba(115 / 255, 115 / 255, 115 / 255)
                    accent: Qt.rgba(245 / 255, 245 / 255, 245 / 255)
                    accentForeground: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    destructive: Qt.rgba(231 / 255, 0 / 255, 11 / 255)
                    border: Qt.rgba(229 / 255, 229 / 255, 229 / 255)
                    input: Qt.rgba(229 / 255, 229 / 255, 229 / 255)
                    ring: Qt.rgba(161 / 255, 161 / 255, 161 / 255)
                }
            }
        },
        State {
            name: "dark"
            PropertyChanges {
                themeRoot {
                    background: Qt.rgba(10 / 255, 10 / 255, 10 / 255)
                    foreground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    card: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    cardForeground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    popover: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    popoverForeground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    primary: Qt.rgba(229 / 255, 229 / 255, 229 / 255)
                    primaryForeground: Qt.rgba(23 / 255, 23 / 255, 23 / 255)
                    secondary: Qt.rgba(38 / 255, 38 / 255, 38 / 255)
                    secondaryForeground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    muted: Qt.rgba(38 / 255, 38 / 255, 38 / 255)
                    mutedForeground: Qt.rgba(161 / 255, 161 / 255, 161 / 255)
                    accent: Qt.rgba(38 / 255, 38 / 255, 38 / 255)
                    accentForeground: Qt.rgba(250 / 255, 250 / 255, 250 / 255)
                    destructive: Qt.rgba(255 / 255, 100 / 255, 103 / 255)
                    border: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.1)
                    input: Qt.rgba(255 / 255, 255 / 255, 255 / 255, 0.15)
                    ring: Qt.rgba(115 / 255, 115 / 255, 115 / 255)
                }
            }
        }
    ]
}
