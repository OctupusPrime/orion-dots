pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: settings

    // PATHS AND PUBLIC VALUES

    readonly property string home: Quickshell.env("HOME")
    readonly property string configDir: Quickshell.env("XDG_CONFIG_HOME") || home + "/.config"

    readonly property var values: {
        // Complete the initial load (including onLoaded parsing) before use.
        settingsFile.text();
        return state.values;
    }

    function defaults() {
        return {
            locale: "en_US",
            clock: {
                timeFormat: "HH:mm",
                dateFormat: "dd/MM/yyyy"
            },
            workspaces: {},
            tray: {},
            wallpaper: {
                light: "",
                dark: ""
            }
        };
    }

    // CUSTOM VALIDATORS
    // Group registrations by section, using dotted setting paths.
    // Each validator receives (value, fallback, key) and returns the normalized
    // value or fallback. Custom validators must also check the value's type.

    readonly property var validators: ({
            "locale": (value, fallback, key) => readChoice(value, fallback, key, ["en_US", "uk_UA"]),
            "clock.timeFormat": readString,
            "clock.dateFormat": readString,
            "workspaces": readPathMap,
            "tray": readPathMap,
            "wallpaper.light": readPath,
            "wallpaper.dark": readPath
        })

    function readString(value, fallback, key) {
        if (typeof value === "string")
            return value;

        console.warn("Settings: invalid " + key + "; using default");
        return fallback;
    }

    function readNumber(value, fallback, key) {
        if (typeof value === "number" && Number.isFinite(value))
            return value;

        console.warn("Settings: invalid " + key + "; using default");
        return fallback;
    }

    function readChoice(value, fallback, key, choices) {
        if (typeof value === "string" && choices.includes(value))
            return value;

        console.warn("Settings: invalid " + key + "; using default");
        return fallback;
    }

    function readPath(value, fallback, key) {
        if (value === undefined || value === null || value === "")
            return fallback;

        if (typeof value === "string" && value.trim().length > 0 && !value.includes("\u0000")) {
            if (value.startsWith("~/"))
                return home + value.slice(1);
            if (value.startsWith("/"))
                return value;
        }

        console.warn("Settings: invalid " + key + "; using default");
        return fallback;
    }

    function readPathMap(value, fallback, key) {
        if (!isObject(value)) {
            console.warn("Settings: invalid " + key + "; using default");
            return fallback;
        }

        const result = {};
        for (const name of Object.keys(value)) {
            const path = readPath(value[name], "", key + "." + name);
            if (path)
                Object.defineProperty(result, name, {
                    value: path,
                    enumerable: true,
                    writable: true,
                    configurable: true
                });
        }
        return result;
    }

    // LOADER

    QtObject {
        id: state
        property bool valuesLoaded: false
        property var values: settings.defaults()
    }

    function isObject(value) {
        return value !== null && typeof value === "object" && !Array.isArray(value);
    }

    function normalize(value, fallback, key) {
        if (value === undefined)
            return fallback;

        if (Object.prototype.hasOwnProperty.call(validators, key))
            return validators[key](value, fallback, key);

        if (isObject(fallback)) {
            if (!isObject(value)) {
                console.warn("Settings: invalid " + key + "; using defaults");
                return fallback;
            }

            const result = {};
            for (const name of Object.keys(fallback)) {
                const child = Object.prototype.hasOwnProperty.call(value, name) ? value[name] : undefined;
                result[name] = normalize(child, fallback[name], key ? key + "." + name : name);
            }
            return result;
        }

        // Lists and other complex types require a custom validator.
        const type = typeof fallback;
        if ((type === "string" || type === "boolean" || type === "number") && typeof value === type && (type !== "number" || Number.isFinite(value)))
            return value;

        console.warn("Settings: invalid " + key + "; using default");
        return fallback;
    }

    function applyText(text) {
        try {
            const data = JSON.parse(text);
            if (!isObject(data))
                throw new Error("Root must be an object");

            // Replace the object to notify bindings; unknown keys are ignored.
            state.values = normalize(data, defaults(), "");

            // Runs when settings.json was changed
            if (state.valuesLoaded) {
                triggerWallpaperChange();
            }

            state.valuesLoaded = true;
        } catch (error) {
            // An incomplete edit must not discard the last valid settings.
            console.warn("Settings: keeping previous values:", error);
        }
    }

    FileView {
        id: settingsFile

        path: settings.configDir + "/orion-dots/settings.json"

        blockLoading: true
        watchChanges: true

        onFileChanged: reload()
        onLoaded: settings.applyText(settingsFile.text())
        onLoadFailed: {
            state.values = settings.defaults();
            console.warn("Settings: unable to read file; using defaults");
        }
    }

    // SCRIPTS

    function triggerWallpaperChange(): void {
        if (wallpaperChangeProc.running)
            return;

        const wallpapers = state.values.wallpaper;
        const paths = [wallpapers.light, wallpapers.dark].filter(path => !!path);

        wallpaperChangeProc.exec({
            command: [Quickshell.shellPath("scripts/change-wallpaper.sh"), ...paths]
        });
    }

    Process {
        id: wallpaperChangeProc
    }
}
