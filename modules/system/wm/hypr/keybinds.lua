local M = {}

M.setup = function(terminal, fileManager, menu)
    local mainMod = "SUPER"

    -- ── Terminal & Core ──────────────────────────────────────────────────────
    hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + Q", hl.dsp.window.close())
    hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl dispatch exit"))

    -- ── App Launchers ────────────────────────────────────────────────────────
    hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
    hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-beta"))
    hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("zeditor"))
    hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
    hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("foot -e sh -c yazi"))
    hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("foot -e sh -c rmpc"))
    hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("foot -e sh -c cava"))
    hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("foot -e sh -c nvim"))

    -- ── Screenshot ───────────────────────────────────────────────────────────
    hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("grim ~/Pictures/$(date +%Y-%m-%d-%H%M%S)_screenshot.png"))

    -- ── Window State ─────────────────────────────────────────────────────────
    hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
    -- zoom / swap with master (was MODKEY+SHIFT+Return in DWL)
    hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg swapwithmaster"))

    hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd("sh -c 'pkill hyprsunset; hyprsunset -t 3500 &'"))
    hl.bind(mainMod .. " + SHIFT + F5", hl.dsp.exec_cmd("pkill hyprsunset"))

    -- Arrow key focus (carried from the template's directional model)
    hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

    -- -- ── Layout / Sizing ──────────────────────────────────────────────────────
    -- -- mfact equivalent (splitratio in Hyprland master/dwindle)
    -- hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("hyprctl dispatch splitratio -0.05"))
    -- hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.05"))
    -- -- incnmaster / decnmaster (Hyprland master layout)
    -- -- Remapped from MODKEY+i / MODKEY+d (d was conflicting with rofi)
    -- hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg addmaster"))
    -- hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg removemaster"))
    -- -- Layout toggle (was MODKEY+space in DWL)
    -- hl.bind(mainMod .. " + Space", hl.dsp.layout("togglesplit"))
    -- -- Tab → last workspace (DWL's "view last tag")
    -- hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

    -- ── Workspaces 1–9 ───────────────────────────────────────────────────────
    for i = 1, 9 do
        hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
    end
    -- DWL's MODKEY+0 (view all tags) has no direct equivalent in Hyprland.
    -- Nearest: toggle a special overview workspace, or omit.

    -- -- ── Multi-monitor ────────────────────────────────────────────────────────
    -- hl.bind(mainMod .. " + Comma", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor l"))
    -- hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor r"))
    -- hl.bind(mainMod .. " + SHIFT + Comma", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:-1"))
    -- hl.bind(mainMod .. " + SHIFT + Period", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:+1"))

    -- ── Audio (Pipewire / wpctl) ──────────────────────────────────────────────
    hl.bind(
        "XF86AudioRaiseVolume",
        hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
        { locked = true, repeating = true }
    )
    hl.bind(
        "XF86AudioLowerVolume",
        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
        { locked = true, repeating = true }
    )
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
    -- playerctl (MODKEY+p in DWL)
    hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

    -- ── Mouse Binds ───────────────────────────────────────────────────────────
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
end

return M
