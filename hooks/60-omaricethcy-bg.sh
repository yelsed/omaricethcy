#!/bin/bash
# Installed to ~/.config/omarchy/hooks/theme-set.d/ by install.sh.
#
# `omarchy theme set` ends by calling omarchy-theme-bg-next, which points one
# image at every output. This runs afterwards and re-applies the wallpaper per
# monitor, so landscape screens get the blur-fill variant back.

# `restore`, not `apply`: omarchy-theme-bg-next has just rewritten the symlink,
# and `apply` would read that as someone picking a wallpaper and overwrite the
# selection this theme had. `restore` ignores the symlink and re-asserts the
# stored pair, so each theme comes back showing what it was showing.
command -v omaricethcy-bg >/dev/null || exit 0
omaricethcy-bg restore >/dev/null 2>&1 || true
