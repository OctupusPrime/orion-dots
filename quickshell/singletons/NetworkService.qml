pragma Singleton

import Quickshell.Networking
import Quickshell
import QtQuick

Singleton {
    id: networkService

    readonly property var devices: Networking.devices.values

    function deviceKey(device): string {
        return device?.address ?? "";
    }
    function networkKey(network): string {
        return `${network.name}:${network.security}`;
    }

    function isNetworkPersonal(network): bool {
        return network?.security === WifiSecurityType.WpaPsk || network?.security === WifiSecurityType.Wpa2Psk || network?.security === WifiSecurityType.Sae;
    }
    function isNetworkOpen(network): bool {
        return network?.security === WifiSecurityType.Open || network?.security === WifiSecurityType.Owe;
    }

    signal passwordRequired(var network)

    // WIRED

    readonly property var wiredDevices: devices.filter(device => device.type === DeviceType.Wired)

    readonly property bool wiredSupported: wiredDevices.length > 0
    // Its true when physical cable is pluged in to ethernet port.
    readonly property bool wiredHasLink: wiredDevices.some(device => device.hasLink)

    readonly property bool wiredEnabled: wiredSupported && wiredDevices.every(device => device.autoconnect)

    function setWiredEnabled(enabled: bool): void {
        if (!wiredSupported)
            return;

        for (const device of wiredDevices) {
            device.autoconnect = enabled;

            if (!enabled) {
                if (device.connected)
                    device.disconnect();

                continue;
            }

            if (device.network && !device.network.connected && !device.network.stateChanging) {
                device.network.connect();
            }
        }
    }

    readonly property var connectedWiredDevice: wiredDevices.find(device => device.connected) ?? null

    function connectWired(device): void {
        const network = device?.network;

        if (!network || network.stateChanging)
            return;

        clearDeviceError(device);
        network.connect();
    }

    function disconnectWired(device): void {
        if (!device || !device.connected)
            return;

        clearDeviceError(device);
        device.disconnect();
    }

    // WI-FI

    readonly property var wifiDevices: devices.filter(device => device.type === DeviceType.Wifi)
    readonly property var wifiNetworks: {
        const networks = {};

        for (const device of wifiDevices) {
            for (const network of device.networks.values) {
                const key = networkKey(network);
                const current = networks[key];

                if (!current || network.connected || (!current.connected && network.signalStrength > current.signalStrength)) {
                    networks[key] = network;
                }
            }
        }

        return Object.values(networks).sort((a, b) => b.connected - a.connected || b.known - a.known || b.signalStrength - a.signalStrength || a.name.localeCompare(b.name));
    }

    readonly property bool wifiSupported: wifiDevices.length > 0
    // Its false when wifi chip blocked on hardware level.
    readonly property bool wifiHardwareEnabled: wifiSupported && Networking.wifiHardwareEnabled

    readonly property bool wifiEnabled: wifiSupported && Networking.wifiEnabled

    function setWifiEnabled(enabled: bool): void {
        if (wifiSupported && wifiHardwareEnabled)
            Networking.wifiEnabled = enabled;
    }

    function setScanning(enabled: bool): void {
        for (const device of wifiDevices)
            device.scannerEnabled = enabled && wifiEnabled;
    }

    readonly property var connectedWifi: wifiNetworks.find(network => network.connected) ?? null

    function connectWifi(network, password = ""): void {
        if (!network || network.stateChanging)
            return;

        clearNetworkError(network);

        if (password && isNetworkPersonal(network)) {
            network.connectWithPsk(password);
            return;
        }

        if (network.known || isNetworkOpen(network)) {
            network.connect();
            return;
        }

        if (isNetworkPersonal(network)) {
            passwordRequired(network);
            return;
        }

        networkService.setNetworkError(network, "Unsupported Wi-Fi security.");
    }

    function disconnectWifi(network): void {
        if (!network || network.stateChanging)
            return;

        clearNetworkError(network);
        network.disconnect();
    }

    // ERRORS

    property var networkErrors: ({})
    property var deviceErrors: ({})

    function updateError(map, key, value) {
        const next = Object.assign({}, map);
        if (value === null)
            delete next[key];
        else
            next[key] = value;
        return next;
    }

    function networkError(network) {
        return networkErrors[networkKey(network)] ?? null;
    }
    function deviceError(device) {
        return deviceErrors[deviceKey(device)] ?? null;
    }

    function handleConnectionFailure(network, reason): void {
        if (!network?.device)
            return;

        const message = ConnectionFailReason.toString(reason);

        if (network.device.type === DeviceType.Wifi) {
            const noPassword = reason === ConnectionFailReason.NoSecrets && isNetworkPersonal(network);
            networkErrors = updateError(networkErrors, networkKey(network), noPassword ? "Password missing or incorrect." : message);

            if (noPassword)
                passwordRequired(network);

            return;
        }
        deviceErrors = updateError(deviceErrors, deviceKey(network.device), message);
    }

    function clearNetworkError(network): void {
        networkErrors = updateError(networkErrors, networkKey(network), null);
    }
    function clearDeviceError(device): void {
        deviceErrors = updateError(deviceErrors, deviceKey(device), null);
    }

    // WATCHERS

    property Instantiator wifiWatchers: Instantiator {
        model: networkService.wifiNetworks

        delegate: Connections {
            required property var modelData

            target: modelData

            function onConnectionFailed(reason): void {
                networkService.handleConnectionFailure(modelData, reason);
            }

            function onConnectedChanged(): void {
                if (modelData.connected)
                    networkService.clearNetworkError(modelData);
            }
        }
    }
    property Instantiator wiredWatchers: Instantiator {
        model: networkService.wiredDevices

        delegate: Connections {
            required property var modelData

            target: modelData.network

            function onConnectionFailed(reason): void {
                networkService.handleConnectionFailure(modelData.network, reason);
            }

            function onConnectedChanged(): void {
                if (modelData.network?.connected)
                    networkService.clearDeviceError(modelData);
            }
        }
    }
}
