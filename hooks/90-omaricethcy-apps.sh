#!/bin/bash
# Installed to ~/.config/omarchy/hooks/theme-set.d/ by install.sh.
#
# herdr and aether keep their colours outside Omarchy's theme pipeline, so a
# theme switch left them in their own blue and purple. This writes the new
# theme's palette into both.

colors="$HOME/.local/state/omarchy/current/theme/colors.toml"
[[ -f $colors ]] && command -v omarchy-theme-color >/dev/null || exit 0
color() { omarchy-theme-color --file "$colors" "$1"; }

accent=$(color accent)
background=$(color background)
foreground=$(color foreground)
selection=$(color selection)
lighter_background=$(color lighter_background)
dark_background=$(color dark_background)

# herdr has no include, so its [theme] tables are replaced inside config.toml
# and everything else in the file is kept. The `terminal` base theme takes the
# ANSI palette Omarchy already gives the terminal; only the accent and the two
# row highlights need stating.
herdr_config="$HOME/.config/herdr/config.toml"
if [[ -d ${herdr_config%/*} ]]; then
  python3 -I - "$herdr_config" <<PY
import pathlib
import re
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
text = path.read_text() if path.exists() else ""

def is_theme(name):
    name = name.replace('"', "").replace("'", "").replace(" ", "")
    return name == "theme" or name.startswith("theme.")

kept = []
in_theme_table = False
before_first_table = True
for line in text.splitlines():
    header = re.match(r"\s*\[\[?([^\]]+)\]", line)
    if header:
        before_first_table = False
        in_theme_table = is_theme(header.group(1))
    elif before_first_table and re.match(r"\s*[\"']?theme[\"']?\s*[.=]", line):
        continue
    if not in_theme_table:
        kept.append(line)

while kept and not kept[-1].strip():
    kept.pop()

theme = """
[theme]
name = "terminal"

[theme.custom]
accent = "$accent"
selection_bg = "$selection"
active_row_bg = "$lighter_background"
"""
result = "\n".join(kept) + "\n" + theme
try:
    tomllib.loads(result)
except tomllib.TOMLDecodeError as error:
    sys.exit(f"90-omaricethcy-apps: left {path} alone, the result would not parse: {error}")
path.write_text(result)
PY
  herdr server reload-config >/dev/null 2>&1 || true
fi

# aether imports theme.override.css after its own theme.css and reloads it on
# save, so the override is the whole file and nothing else needs touching.
aether_override="$HOME/.config/aether/theme.override.css"
if [[ -d ${aether_override%/*} ]]; then
  cat >"$aether_override" <<CSS
/* Written by omaricethcy's 90-omaricethcy-apps.sh on every theme switch.
 * Edits here are overwritten; change the theme's colors.toml instead. */

@define-color accent_bg_color $accent;
@define-color accent_fg_color $background;
@define-color accent_color $accent;

@define-color window_bg_color $background;
@define-color window_fg_color $foreground;
@define-color view_bg_color $dark_background;
@define-color view_fg_color $foreground;

@define-color headerbar_bg_color $background;
@define-color headerbar_fg_color $foreground;
@define-color card_bg_color $lighter_background;
@define-color card_fg_color $foreground;
CSS
fi
