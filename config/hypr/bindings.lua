-- Linked to ~/.config/hypr/bindings.lua by install.sh, replacing Omarchy's
-- stock file. Only bindings that differ from Omarchy's defaults live here;
-- everything this rice used to restate by hand — terminal, browser, the web
-- apps, 1Password, Obsidian, Signal, Spotify, lazydocker — Omarchy 4 already
-- binds to the same keys in default/hypr/bindings/applications.lua.
--
-- See the full set with: omarchy menu keybindings --print

-- Omarchy binds btop to SUPER + CTRL + T. This is the chord the rice has always
-- used for it; both reach the same TUI, so this is an addition, not a move.
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

-- Omarchy 4 binds SUPER + SHIFT + W to Omawrite. The per-monitor wallpaper
-- cycler is the older claim on that chord here, so it takes the key back.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Next wallpaper", "omaricethcy-bg next")

-- Middle-click autoscroll, from the hypr-autoscroll plugin. Arms the mode;
-- middle-click then drags to scroll, and pressing again hands the middle button
-- back. Plugin settings live in input.lua.
--
-- Commented out with them: the dispatcher belongs to the plugin, so while the
-- plugin is unloaded Hyprland reports "Invalid dispatcher" on every reload.
-- The Omarchy 3 form was:
--   bindd = SUPER, A, Toggle middle-button autoscroll, hypr-autoscroll:middle-mode, toggle
-- SUPER + A is free in Omarchy 4, so no unbind is needed when this comes back.
