#!/bin/bash
# Installed to ~/.config/omarchy/hooks/theme-set.d/ by install.sh.
#
# The boot splash and the login screen are the two surfaces Omarchy does not
# re-theme on a switch: their assets live in /usr/share, not in the theme.
# omarchy-plymouth-set-by-theme pushes the theme's unlock.png and colours into
# both, so this hook calls it and the banner follows whichever theme is active.
#
# It then lays this rice's Main.qml over the login screen. That has to happen
# afterwards rather than instead: omarchy-plymouth-set writes Omarchy's stock
# version there on every run.

theme="${1:-}"
theme_dir="$HOME/.config/omarchy/themes/$theme"
[[ -n $theme && -f $theme_dir/unlock.png ]] || exit 0

repository=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")
template="$repository/templates/sddm-Main.qml"

# Same expression omarchy-plymouth-set-by-theme uses, so the comparison below is
# against the value that would actually be written. `^background` matches only
# the one key, not dark_background or lighter_background.
background=$(awk -F'"' '/^background/{print $2}' "$theme_dir/colors.toml")

# The reveal on the login screen steps through the columns this theme's letters
# end at, so a switch between two banners of different width has to reinstall it
# even when nothing else moved.
letter_ends=
[[ -f $theme_dir/unlock.widths ]] && letter_ends=$(tr ' ' ',' <"$theme_dir/unlock.widths")

# The sync asks for sudo and rebuilds the initramfs, which is far too much to
# spend on a theme switch that changes nothing. Every piece of what it writes has
# to be current before it is worth skipping: the logo in either destination, the
# colours in the login screen's Main.qml, and the reveal baked into it.
if cmp -s "$theme_dir/unlock.png" /usr/share/plymouth/themes/omarchy/logo.png &&
  cmp -s "$theme_dir/unlock.png" /usr/share/sddm/themes/omarchy/logo.png &&
  grep -q "color: \"$background\"" /usr/share/sddm/themes/omarchy/Main.qml &&
  grep -q "letterEnds: \[$letter_ends\]" /usr/share/sddm/themes/omarchy/Main.qml; then
  exit 0
fi

# A theme-set hook has no terminal, and sudo needs one to prompt on. This is how
# Omarchy runs the same command from its own unlocks menu in Walker.
command -v omarchy-launch-floating-terminal-with-presentation >/dev/null || exit 0

# Rendered here, where nothing needs root; the terminal below only copies it.
staged=$(mktemp --suffix=-Main.qml)
sed -e "s/#181716/$background/" \
  -e "s|/\* UNLOCK_WIDTHS \*/|$letter_ends|" \
  "$template" >"$staged"

omarchy-launch-floating-terminal-with-presentation \
  "omarchy-plymouth-set-by-theme '$theme' && sudo cp '$staged' /usr/share/sddm/themes/omarchy/Main.qml && rm -f '$staged'"
