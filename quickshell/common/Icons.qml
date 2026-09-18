import Quickshell.Io

FileView {
    path: Qt.resolvedUrl("../assets/Icons.json")
    blockLoading: true

    readonly property var values: JSON.parse(text())
}
