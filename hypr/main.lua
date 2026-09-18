hl.env("QT_QPA_PLATFORMTHEME", "qt5ct:qt6ct")

hl.on("hyprland.start", function()
    hl.exec_cmd('hyprpaper -c "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/orion-dots/hyprpaper.conf"')
    hl.exec_cmd("qs -c orion-dots")
end)