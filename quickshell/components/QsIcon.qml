import QtQuick

Text {
    id: textRoot

    required property string source
    property var size: 24

    text: source
    font.family: 'Icons'
    font.pixelSize: size
    color: theme.foreground
}
