pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick

Singleton {
    id: hyprlandService

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace?.id ?? 1

    property string keyboardLang: "UN"

    function updateKeyboardLang(layout): void {
        hyprlandService.keyboardLang = layout ? layout.substring(0, 2).toUpperCase() : "--";
    }

    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name !== "activelayout")
                return;

            const [, layout] = event.parse(2);
            hyprlandService.updateKeyboardLang(layout);
        }
    }

    Process {
        id: keyboardLangProc

        command: ["hyprctl", "-j", "devices"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const devices = JSON.parse(text);

                    const keyboard = devices.keyboards?.find(keyboard => keyboard.main);

                    hyprlandService.updateKeyboardLang(keyboard?.active_keymap);
                } catch (_) {
                    hyprlandService.keyboardLang = "UN";
                }
            }
        }
    }

    Component.onCompleted: keyboardLangProc.running = true
}
