-- Modular Imports
local colors = require("colors")
local animations = require("animations")
local keybinds = require("keybinds")

------------------
---- MONITORS ----
------------------

hl.monitor({
    output = "HDMI-A-2",
    mode = "1680x1050@59.95",
    position = "0x0",
    scale = 1,
})

---------------------
---- AUTOSTART ----
---------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("swaybg -i ~/walls/Minimal-Nord.png")
    hl.exec_cmd("waybar")
end)

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "foot"
local fileManager = "thunar"
local menu = "rofi -show drun"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,

        col = {
            active_border = { colors = { colors.active_border_1, colors.active_border_2 }, angle = 45 },
            inactive_border = colors.inactive_border,
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = colors.shadow_color,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})

-- Initialize System Animations & Curves
animations.setup()

----------------
----  LAYOUTS / MISC  ----
----------------

hl.config({
    dwindle = { preserve_split = true },
    master = { new_status = "slave" },
    scrolling = { fullscreen_on_one_column = true },
    misc = { force_default_wallpaper = -1, disable_hyprland_logo = false },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        kb_options = "caps:escape",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Initialize Keyboard and Multimedia Bindings
keybinds.setup(terminal, fileManager, menu)

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})
