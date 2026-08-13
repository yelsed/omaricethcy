#!/bin/bash
# Installed to ~/.config/omarchy/hooks/theme-set.d/ by install.sh.
#
# The boot splash and the login screen are the two surfaces Omarchy does not
# re-theme on a switch: their assets live in /usr/share, not in the theme.
# omarchy-plymouth-set-by-theme pushes the theme's unlock.png and colours into
# both, so this hook calls it and the banner follows whichever theme is active.

theme="${1:-}"
theme_dir="$HOME/.config/omarchy/themes/$theme"
[[ -n $theme && -f $theme_dir/unlock.png ]] || exit 0

# Same expression omarchy-plymouth-set-by-theme uses, so the comparison below is
# against the value that would actually be written. `^background` matches only
# the one key, not dark_background or lighter_background.
background=$(awk -F'"' '/^background/{print $2}' "$theme_dir/colors.toml")

# The sync asks for sudo and rebuilds the initramfs, which is far too much to
# spend on a theme switch that changes nothing. Both halves of what it writes
# have to be stale before it is worth running: the logo in either destination,
# or the colours in the login screen's Main.qml.
if cmp -s "$theme_dir/unlock.png" /usr/share/plymouth/themes/omarchy/logo.png &&
  cmp -s "$theme_dir/unlock.png" /usr/share/sddm/themes/omarchy/logo.png &&
  grep -q "color: \"$background\"" /usr/share/sddm/themes/omarchy/Main.qml; then
  exit 0
fi

# A theme-set hook has no terminal, and sudo needs one to prompt on. This is how
# Omarchy runs the same command from its own unlocks menu in Walker.
command -v omarchy-launch-floating-terminal-with-presentation >/dev/null || exit 0
omarchy-launch-floating-terminal-with-presentation \
  "omarchy-plymouth-set-by-theme '$theme'"
