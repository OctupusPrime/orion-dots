import QtQuick

Text {
    id: textRoot

    required property string source
    property var size: 22

    width: size
    height: size

    text: source
    font.family: 'Icons'
    font.pixelSize: size
    color: theme.foreground
}
