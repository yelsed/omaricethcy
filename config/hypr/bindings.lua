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

-- The per-monitor wallpaper cycler used to take SUPER + SHIFT + W back off
-- Omawrite. Wallpapers are Omarchy's own now, so the chord stays Omarchy's;
-- uncomment these two lines alongside ./install.sh --per-monitor-wallpapers.
-- hl.unbind("SUPER + SHIFT + W")
-- o.bind("SUPER + SHIFT + W", "Next wallpaper", "omaricethcy-bg next")

-- Middle-click autoscroll, from the hypr-autoscroll plugin. Arms the mode;
-- middle-click then drags to scroll, and pressing again hands the middle button
-- back. Plugin settings live in input.lua.
--
-- Commented out with them: the dispatcher belongs to the plugin, so while the
-- plugin is unloaded Hyprland reports "Invalid dispatcher" on every reload.
-- The Omarchy 3 form was:
--   bindd = SUPER, A, Toggle middle-button autoscroll, hypr-autoscroll:middle-mode, toggle
-- SUPER + A is free in Omarchy 4, so no unbind is needed when this comes back.
