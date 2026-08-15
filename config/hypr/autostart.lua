-- Linked to ~/.config/hypr/autostart.lua by install.sh, replacing Omarchy's
-- stock file.

-- Hyprland does not load hyprpm-managed plugins on its own; hyprpm hands them
-- over on every start. Currently: hypr-autoscroll, see input.lua.
--
-- Not o.launch_on_start: that wraps the command in uwsm-app, which puts it in
-- its own scope. hyprpm has to talk to the compositor that started it.
o.exec_on_start("hyprpm reload")
