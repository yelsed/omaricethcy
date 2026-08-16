#!/bin/bash
# Installed to ~/.config/omarchy/hooks/theme-set.d/ by install.sh.
#
# The theme's hyprland.conf exports XCURSOR_THEME and HYPRCURSOR_THEME, but
# Hyprland reads those once at startup, so a theme switch mid-session would not
# move the pointer until the next relaunch. These three lines cover the
# consumers that can be told at runtime.

theme="omaricethcy-${1:-}"
[[ -d ${XDG_DATA_HOME:-$HOME/.local/share}/icons/$theme ]] || exit 0

# Hyprland itself, and through it every Wayland client asking for a shape.
hyprctl setcursor "$theme" "${XCURSOR_SIZE:-24}" >/dev/null 2>&1 || true

# GTK reads its own setting rather than the environment.
gsettings set org.gnome.desktop.interface cursor-theme "$theme" 2>/dev/null || true

# Anything that resolves the cursor theme by the name `default`: XWayland
# clients, Qt, and applications started before the switch. Shadows the
# system-wide /usr/share/icons/default, which inherits Adwaita.
default_dir="${XDG_DATA_HOME:-$HOME/.local/share}/icons/default"
mkdir -p "$default_dir"
printf '[Icon Theme]\nName=Default\nComment=Follows the active Omaricethcy theme\nInherits=%s\n' \
  "$theme" >"$default_dir/index.theme"
