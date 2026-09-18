import QtQuick

Text {
    id: textRoot

    property var fontSize: 16
    property var fontWeight: 400

    font.family: "Geist"
    font.pixelSize: fontSize
    font.weight: fontWeight
    color: theme.foreground

    font.variableAxes: {
        "wght": fontWeight,
        "opsz": fontSize
    }
}
