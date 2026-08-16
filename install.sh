#!/bin/bash
# One-command install for the omaricethcy rice.
#
#   ./install.sh              install everything, apply goud
#   ./install.sh gloed        install everything, apply gloed
#   ./install.sh --themes-only    only link themes, touch nothing else
#   ./install.sh --per-monitor-wallpapers   also install the wallpaper split
#
# Every file outside this repository is backed up before it is changed, and
# every step is idempotent — rerunning is safe.
#
# Omarchy 4 renders the background itself, one image across every output, and
# animates the change on a theme switch. The per-monitor split predates that and
# is off unless asked for; see the README for what it does and does not do there.

set -euo pipefail

REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_USER_THEMES="$HOME/.config/omarchy/themes"
LOCAL_BIN="$HOME/.local/bin"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
TERMINALS_LIST="$HOME/.config/xdg-terminals.list"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
OMARCHY_USER_TEMPLATES="$HOME/.config/omarchy/themed"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
# Where `omarchy theme set` assembles the active theme. Omarchy 3 kept it under
# ~/.config; Omarchy 4 moved it to the state directory, and Ghostty reads two
# generated files out of it by absolute path.
THEME_STATE_DIR="~/.local/state/omarchy/current/theme"

THEME="goud"
THEMES_ONLY=0
PER_MONITOR_WALLPAPERS=0
for argument in "$@"; do
  case "$argument" in
    --themes-only) THEMES_ONLY=1 ;;
    --per-monitor-wallpapers) PER_MONITOR_WALLPAPERS=1 ;;
    -*) echo "unknown option: $argument" >&2; exit 1 ;;
    *) THEME="$argument" ;;
  esac
done

say() { printf '\n\033[1m%s\033[0m\n' "$1"; }
note() { printf '  %s\n' "$1"; }

backup() {
  local target="$1"
  [[ -f $target ]] || return 0
  local copy="$target.backup.$(date +%Y%m%d%H%M%S)"
  cp "$target" "$copy"
  note "backed up $(basename "$target") -> $(basename "$copy")"
}

# ── Preflight ────────────────────────────────────────────────────────────────
if [[ ! -d $OMARCHY_USER_THEMES ]]; then
  echo "Omarchy user theme directory not found: $OMARCHY_USER_THEMES" >&2
  echo "Is Omarchy installed?" >&2
  exit 1
fi

# Omarchy 4 reads Lua where Omarchy 3 read hyprlang, keeps the active theme in a
# different directory, and has no hyprlock, waybar or walker to theme. This rice
# targets 4; on 3 it would link a set of files nothing reads.
if [[ ! -f $HOME/.config/hypr/hyprland.lua ]]; then
  echo "This needs Omarchy 4: ~/.config/hypr/hyprland.lua was not found." >&2
  echo "On Omarchy 3, check out the branch before feat/omarchy-quattro." >&2
  exit 1
fi

if [[ ! -d $REPOSITORY_DIR/themes/$THEME ]]; then
  echo "No such theme: $THEME" >&2
  echo "Available: $(cd "$REPOSITORY_DIR/themes" && echo */ | tr -d '/')" >&2
  exit 1
fi

# ── Themes ───────────────────────────────────────────────────────────────────
say "Linking themes"
for theme_dir in "$REPOSITORY_DIR"/themes/*/; do
  theme_name="$(basename "$theme_dir")"
  target="$OMARCHY_USER_THEMES/$theme_name"

  if [[ -L $target ]]; then
    rm "$target"
  elif [[ -e $target ]]; then
    moved="$target.backup.$(date +%Y%m%d%H%M%S)"
    note "$theme_name exists as a real directory, moving to $(basename "$moved")"
    mv "$target" "$moved"
  fi

  ln -s "${theme_dir%/}" "$target"
  note "linked $theme_name"
done

if [[ $THEMES_ONLY -eq 1 ]]; then
  say "Done (themes only)"
  note "apply with: omarchy theme set $THEME"
  exit 0
fi

# ── Tools on PATH ────────────────────────────────────────────────────────────
say "Installing the tools"
mkdir -p "$LOCAL_BIN"
for tool in "$REPOSITORY_DIR"/bin/omaricethcy-*; do
  [[ -x $tool ]] || continue
  ln -sf "$tool" "$LOCAL_BIN/$(basename "$tool")"
  note "linked $(basename "$tool")"
done
case ":$PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) note "warning: $LOCAL_BIN is not on your PATH" ;;
esac

mkdir -p "$HOOK_DIR"

# ── Per-monitor wallpapers, on request ───────────────────────────────────────
# Omarchy points one image at every output, which crops a portrait photo on a
# landscape screen and vice versa. This is the machinery that sends each output
# something that fits it: two shims earlier on PATH than the commands both
# wallpaper pickers call, a hook to redo the split after a theme switch, and a
# watcher for the callers that reach the real command anyway.
#
# Off by default. Omarchy 4 renders the background from its own shell and
# animates the transition, and none of the below has been reconciled with that.
if [[ $PER_MONITOR_WALLPAPERS -eq 1 ]]; then
  say "Installing the per-monitor wallpapers"
  for shim in "$REPOSITORY_DIR"/bin/shims/*; do
    [[ -x $shim ]] || continue
    ln -sf "$shim" "$LOCAL_BIN/$(basename "$shim")"
    note "shimmed $(basename "$shim")"
  done

  # A shim only works if it is the one PATH finds first.
  hash -r 2>/dev/null || true
  resolved="$(command -v omarchy-theme-bg-set || true)"
  if [[ $resolved == "$LOCAL_BIN/"* ]]; then
    note "verified: omarchy-theme-bg-set resolves to the shim"
  else
    note "warning: omarchy-theme-bg-set still resolves to $resolved"
    note "         put $LOCAL_BIN before Omarchy's own bin in PATH"
  fi

  ln -sf "$REPOSITORY_DIR/hooks/60-omaricethcy-bg.sh" "$HOOK_DIR/60-omaricethcy-bg.sh"
  note "linked 60-omaricethcy-bg.sh into $HOOK_DIR"

  mkdir -p "$SYSTEMD_USER_DIR"
  for unit in "$REPOSITORY_DIR"/systemd/*; do
    ln -sf "$unit" "$SYSTEMD_USER_DIR/$(basename "$unit")"
  done
  systemctl --user daemon-reload
  systemctl --user enable --now omaricethcy-bg.path >/dev/null 2>&1 || true
  if [[ $(systemctl --user is-active omaricethcy-bg.path) == active ]]; then
    note "omaricethcy-bg.path active"
  else
    note "warning: omaricethcy-bg.path did not start"
  fi

  note "uncomment the SUPER SHIFT W binding in config/hypr/bindings.lua to cycle"
fi

# ── Cursors ──────────────────────────────────────────────────────────────────
# A cursor theme is looked up by name from a fixed set of directories, so it
# cannot live inside an Omarchy theme. Build one per theme in that theme's
# accent, and hook the switch so the pointer follows `omarchy theme set`.
say "Building the cursor themes"
if "$REPOSITORY_DIR/bin/omaricethcy-cursor" 2>&1 | sed 's/^/    /'; then
  ln -sf "$REPOSITORY_DIR/hooks/70-omaricethcy-cursor.sh" "$HOOK_DIR/70-omaricethcy-cursor.sh"
  note "linked 70-omaricethcy-cursor.sh into $HOOK_DIR"
else
  note "warning: cursor themes not built, keeping whatever pointer is set"
fi

# ── Boot splash and login screen ─────────────────────────────────────────────
# Both live in /usr/share rather than in a theme, so they do not follow a theme
# switch on their own. The hook syncs them; it is not run here, because the sync
# needs sudo and rebuilds the initramfs — see the README on doing that once by
# hand for the theme that is already active.
say "Installing the boot splash hook"
ln -sf "$REPOSITORY_DIR/hooks/80-omaricethcy-unlock.sh" "$HOOK_DIR/80-omaricethcy-unlock.sh"
note "linked 80-omaricethcy-unlock.sh into $HOOK_DIR"

# ── Hyprland configuration ───────────────────────────────────────────────────
# The whole personal layer is linked out of this repository, so a fresh machine
# gets the monitors, the input tuning, the extra bindings and the window rules
# along with the themes. Each file replaces Omarchy's stock one and is loaded
# after Omarchy's defaults, so it overrides rather than competes.
say "Installing the Hyprland configuration"
for source in "$REPOSITORY_DIR"/config/hypr/*.lua; do
  target="$HOME/.config/hypr/$(basename "$source")"
  if [[ -L $target ]]; then
    rm "$target"
  elif [[ -e $target ]]; then
    backup "$target"
    rm "$target"
  fi
  ln -s "$source" "$target"
  note "linked $(basename "$source")"
done

# ── Shader template ──────────────────────────────────────────────────────────
# Omarchy renders ~/.config/omarchy/themed/*.tpl into the active theme on every
# `omarchy theme set`, substituting {{ key }} from its colors.toml. Keeping the
# shader here instead of in each theme means one file serves every theme — the
# two shipped here, ones generated later, and Omarchy's own.
say "Installing the shader template"
mkdir -p "$OMARCHY_USER_TEMPLATES"
shader_template="$OMARCHY_USER_TEMPLATES/shader.glsl.tpl"
if [[ -L $shader_template ]]; then
  rm "$shader_template"
elif [[ -e $shader_template ]]; then
  backup "$shader_template"
  rm "$shader_template"
fi
ln -s "$REPOSITORY_DIR/templates/shader.glsl.tpl" "$shader_template"
note "linked shader.glsl.tpl"

# ── Ghostty ──────────────────────────────────────────────────────────────────
# Without the theme's config-file line Ghostty ignores Omarchy's palette
# entirely, which is the single most common reason a rice looks half-applied.
say "Wiring Ghostty"
if [[ -f $GHOSTTY_CONFIG ]]; then
  # Both checks below match on the tail of the path, which Omarchy 3 and 4 share,
  # so a config written against Omarchy 3 would read as already correct and keep
  # pointing at a directory that no longer exists. Move it first.
  if grep -q '~/.config/omarchy/current/theme/' "$GHOSTTY_CONFIG"; then
    backup "$GHOSTTY_CONFIG"
    sed -i 's|~/\.config/omarchy/current/theme/|'"$THEME_STATE_DIR"'/|g' "$GHOSTTY_CONFIG"
    note "moved the theme paths to $THEME_STATE_DIR"
  fi

  if grep -q 'omarchy/current/theme/ghostty.conf' "$GHOSTTY_CONFIG"; then
    note "already reads the Omarchy theme"
  else
    backup "$GHOSTTY_CONFIG"
    printf '%s\n%s\n' \
      '# Theme colours, regenerated by Omarchy on every `omarchy theme set`.' \
      "config-file = ?\"$THEME_STATE_DIR/ghostty.conf\"" \
      | cat - "$GHOSTTY_CONFIG" >"$GHOSTTY_CONFIG.new"
    mv "$GHOSTTY_CONFIG.new" "$GHOSTTY_CONFIG"
    note "added the theme config-file line"
  fi

  if grep -q 'current/theme/shader.glsl' "$GHOSTTY_CONFIG"; then
    note "already uses the themed shader"
  else
    printf '\n%s\n%s\n' \
      '# Rice shader, swapped along with the theme.' \
      "custom-shader = \"$THEME_STATE_DIR/shader.glsl\"" \
      >>"$GHOSTTY_CONFIG"
    note "added the themed shader"
  fi

  if grep -qE '^\s*theme\s*=' "$GHOSTTY_CONFIG"; then
    note "warning: a hardcoded 'theme =' line is still present and will override the rice"
  fi
else
  note "no Ghostty config found, skipping"
fi

# ── Ghostty as the default terminal ──────────────────────────────────────────
say "Setting Ghostty as the default terminal"
GHOSTTY_DESKTOP="com.mitchellh.ghostty.desktop"
if [[ -f /usr/share/applications/$GHOSTTY_DESKTOP ]]; then
  if [[ -f $TERMINALS_LIST ]] && head -3 "$TERMINALS_LIST" | grep -q "$GHOSTTY_DESKTOP"; then
    note "already first in xdg-terminals.list"
  else
    backup "$TERMINALS_LIST"
    {
      echo "# Terminal emulator preference order for xdg-terminal-exec"
      echo "# The first found and valid terminal will be used"
      echo "$GHOSTTY_DESKTOP"
      [[ -f $TERMINALS_LIST ]] && grep -vE "^\s*(#|$GHOSTTY_DESKTOP\s*$)" "$TERMINALS_LIST" || true
    } >"$TERMINALS_LIST.new"
    mv "$TERMINALS_LIST.new" "$TERMINALS_LIST"
    note "put $GHOSTTY_DESKTOP first"
  fi
  xdg-mime default "$GHOSTTY_DESKTOP" x-scheme-handler/terminal 2>/dev/null || true
else
  note "Ghostty desktop entry not found, skipping"
fi

# ── Apply ────────────────────────────────────────────────────────────────────
say "Applying $THEME"
omarchy theme set "$THEME"

say "Done"
note "switch themes:   omarchy theme set gloed"
note "wallpapers:      Omarchy's own picker"
note "new accent:      omaricethcy-theme '#7aa2f7' blauw --apply"
note "then:            omaricethcy-companions blauw && omaricethcy-ascii blauw && omaricethcy-preview blauw"
note "shader off/on:   omaricethcy-shader"
note "open a new terminal window to pick up the shader"
