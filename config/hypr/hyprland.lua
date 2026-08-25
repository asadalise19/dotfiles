-- User entrypoint. Ambxst owns the generated compositor configuration.
dofile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")

hl.config({
    input = {
        numlock_by_default = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

hl.env("TERMINAL", "ghostty")
hl.env("GNOME_KEYRING_CONTROL", "/run/user/1000/keyring")

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1.25,
})

hl.on("hyprland.start", function()
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
end)

hl.bind("SUPER + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.unbind("SUPER + R")
hl.bind("SUPER + R", hl.dsp.exec_cmd("ambxst run launcher"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("vicinae toggle"))

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

hl.unbind("SUPER + SHIFT + A")
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("ambxst run lens"))
hl.unbind("SUPER + A")

hl.unbind("SUPER + V")
hl.bind("SUPER + V", hl.dsp.exec_cmd("vicinae deeplink 'vicinae://launch/clipboard/history'"))

hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/shutdown-helper.sh poweroff"))
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/shutdown-helper.sh reboot"))

hl.unbind("XF86AudioRaiseVolume")
hl.unbind("XF86AudioLowerVolume")
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-"))

hl.unbind("XF86Calculator")
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"))

for workspace = 1, 10 do
    local key = tostring(workspace % 10)
    hl.unbind("SUPER + ALT + " .. key)
    hl.bind("SUPER + ALT + " .. key, hl.dsp.window.move({
        workspace = workspace,
        follow = false,
    }))
end

local resize_binds = {
    { key = "Down", y = 50 },
    { key = "j", y = 50 },
    { key = "Up", y = -50 },
    { key = "k", y = -50 },
}

for _, bind in ipairs(resize_binds) do
    hl.unbind("SUPER + ALT + " .. bind.key)
    hl.bind("SUPER + ALT + " .. bind.key, hl.dsp.window.resize({
        x = 0,
        y = bind.y,
        relative = true,
    }), { repeating = true })
end
