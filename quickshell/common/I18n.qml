import QtQuick

QtObject {
    id: root

    required property string language
    readonly property string fallbackLanguage: "en_US"

    readonly property var translations: ({
            en_US: {
                systemMenu: {
                    appearance: "Appearance",
                    light: "Light",
                    adaptive: "Adaptive",
                    dark: "Dark",
                    system: "System",
                    sleep: "Sleep mode",
                    shutdown: "Shutdown",
                    restart: "Restart"
                },
                appsTray: {
                    back: "Back"
                }
            },
            uk_UA: {
                systemMenu: {
                    appearance: "Зовнішній вигляд",
                    light: "Світла",
                    adaptive: "Адаптивна",
                    dark: "Темна",
                    system: "Система",
                    sleep: "Режим сну",
                    shutdown: "Вимкнути",
                    restart: "Перезапустити"
                },
                appsTray: {
                    back: "Назад"
                }
            }
        })

    function hasOwn(object, key) {
        return object !== null && object !== undefined && Object.prototype.hasOwnProperty.call(object, key);
    }

    function hasLanguage(language) {
        return hasOwn(root.translations, language);
    }

    function getValue(object, path) {
        if (object === null || object === undefined)
            return undefined;

        const parts = path.split(".");
        let value = object;

        for (let i = 0; i < parts.length; ++i) {
            if (value === null || value === undefined || !hasOwn(value, parts[i])) {
                return undefined;
            }

            value = value[parts[i]];
        }

        return value;
    }

    function interpolate(text, params) {
        if (typeof text !== "string")
            return text;

        if (params === null || params === undefined)
            return text;

        return text.replace(/\{\{([^{}]+)\}\}/g, function (match, key) {
            const name = key.trim();

            if (!hasOwn(params, name))
                return match;

            const value = params[name];

            if (value === null || value === undefined)
                return match;

            return String(value);
        });
    }

    function getTranslation(language, key) {
        if (!hasLanguage(language))
            return undefined;

        const value = getValue(root.translations[language], key);

        // Translations must always resolve to strings.
        if (typeof value !== "string")
            return undefined;

        return value;
    }

    function t(key, params) {
        // Referencing root.language here ensures bindings using t()
        // react when the externally provided language changes.
        const currentLanguage = root.language;

        let value = getTranslation(currentLanguage, key);

        // Missing OR invalid selected translation falls back.
        if (value === undefined) {
            value = getTranslation(root.fallbackLanguage, key);
        }

        if (value === undefined) {
            console.warn("I18n: missing or invalid translation:", key, "language:", currentLanguage);

            return key;
        }

        return interpolate(value, params);
    }
}
