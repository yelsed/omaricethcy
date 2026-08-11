#!/bin/bash
# One-command install for the omaricethcy rice.
#
#   ./install.sh              install everything, apply goud
#   ./install.sh gloed        install everything, apply gloed
#   ./install.sh --themes-only    only link themes, touch nothing else
#
# Every file outside this repository is backed up before it is changed, and
# every step is idempotent — rerunning is safe.

set -euo pipefail

REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_USER_THEMES="$HOME/.config/omarchy/themes"
LOCAL_BIN="$HOME/.local/bin"
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
TERMINALS_LIST="$HOME/.config/xdg-terminals.list"
HOOK_DIR="$HOME/.config/omarchy/hooks/theme-set.d"
OMARCHY_USER_TEMPLATES="$HOME/.config/omarchy/themed"
BINDINGS_CONF="$HOME/.config/hypr/bindings.conf"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

THEME="goud"
THEMES_ONLY=0
for argument in "$@"; do
  case "$argument" in
    --themes-only) THEMES_ONLY=1 ;;
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

# ── Wallpaper shims ──────────────────────────────────────────────────────────
# Both wallpaper pickers call omarchy-theme-bg-set, which points one image at
# every output. Omarchy has no hook for that, so these shims sit earlier on PATH,
# run the real command, then restore the per-monitor split.
say "Installing the wallpaper shims"
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
  note "         put $LOCAL_BIN before ~/.local/share/omarchy/bin in PATH"
fi

# ── Per-monitor wallpaper hook ───────────────────────────────────────────────
# `omarchy theme set` finishes by pointing one image at every output, so this
# runs afterwards and restores the per-monitor split.
say "Installing the wallpaper hook"
mkdir -p "$HOOK_DIR"
ln -sf "$REPOSITORY_DIR/hooks/60-omaricethcy-bg.sh" "$HOOK_DIR/60-omaricethcy-bg.sh"
note "linked 60-omaricethcy-bg.sh into $HOOK_DIR"

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

# ── Wallpaper watcher ────────────────────────────────────────────────────────
# The shims only fire for callers that resolve them through PATH. A long-running
# process started before the shims existed — the quickshell bar, typically — keeps
# calling the real command with its own stale environment. This watches the
# background symlink instead, so the split is restored whoever changed it.
say "Installing the wallpaper watcher"
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

# ── Wallpaper keybinding ─────────────────────────────────────────────────────
say "Binding SUPER SHIFT W to the wallpaper cycler"
if [[ -f $BINDINGS_CONF ]] && grep -q 'omaricethcy-bg next' "$BINDINGS_CONF"; then
  note "already bound"
else
  backup "$BINDINGS_CONF"
  printf '\n%s\n%s\n' \
    '# Cycle wallpapers per monitor (omaricethcy)' \
    'bindd = SUPER SHIFT, W, Next wallpaper, exec, omaricethcy-bg next' \
    >>"$BINDINGS_CONF"
  note "added SUPER SHIFT W"
fi

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
  if grep -q 'omarchy/current/theme/ghostty.conf' "$GHOSTTY_CONFIG"; then
    note "already reads the Omarchy theme"
  else
    backup "$GHOSTTY_CONFIG"
    printf '%s\n%s\n' \
      '# Theme colours, regenerated by Omarchy on every `omarchy theme set`.' \
      'config-file = ?"~/.config/omarchy/current/theme/ghostty.conf"' \
      | cat - "$GHOSTTY_CONFIG" >"$GHOSTTY_CONFIG.new"
    mv "$GHOSTTY_CONFIG.new" "$GHOSTTY_CONFIG"
    note "added the theme config-file line"
  fi

  if grep -q 'current/theme/shader.glsl' "$GHOSTTY_CONFIG"; then
    note "already uses the themed shader"
  else
    printf '\n%s\n%s\n' \
      '# Rice shader, swapped along with the theme.' \
      'custom-shader = "~/.config/omarchy/current/theme/shader.glsl"' \
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

# ── Waybar off ───────────────────────────────────────────────────────────────
# The rice uses the quickshell bar; Omarchy's Waybar would sit on top of it.
say "Turning off Omarchy's Waybar"
if omarchy-toggle-enabled waybar-off 2>/dev/null; then
  note "already off"
else
  omarchy toggle waybar >/dev/null 2>&1 || true
  note "off, and it will stay off across reboots"
fi

# ── Apply ────────────────────────────────────────────────────────────────────
say "Applying $THEME"
omarchy theme set "$THEME"

say "Done"
note "switch themes:   omarchy theme set gloed"
note "cycle wallpaper: SUPER SHIFT W  (or omaricethcy-bg next)"
note "new accent:      omaricethcy-theme '#7aa2f7' blauw --apply"
note "then:            omaricethcy-companions blauw && omaricethcy-ascii blauw && omaricethcy-preview blauw"
note "theme picker:    SUPER SHIFT CTRL SPACE"
note "open a new terminal window to pick up the shader"
