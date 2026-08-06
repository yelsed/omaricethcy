# omaricethcy

Two sibling [Omarchy](https://omarchy.org/) themes: **goud** (gold) and **gloed** (ember).

They share one dark neutral base and differ only in their accent ramp. The ramp is used *as accent* — borders, focus, selection, icons, chrome. The primary is always dark. Neither theme borrows the other's colours.

```
omarchy theme set goud     # gold
omarchy theme set gloed    # ember
```

## Install

```bash
git clone https://github.com/yelsed/omaricethcy.git
cd omaricethcy
./install.sh              # or: ./install.sh gloed
```

One command. Every step is idempotent, and anything outside this repository is backed up to `<file>.backup.<timestamp>` before it is touched.

| Step | What it does |
|---|---|
| Themes | Symlinks each `themes/<name>/` into `~/.config/omarchy/themes/`. Symlinks, not copies, so edits here are live on the next `omarchy theme set`. Both `omarchy theme list` and `omarchy-theme-set` handle symlinked theme directories natively. |
| Tools | Links `bin/omaricethcy-*` into `~/.local/bin` |
| Wallpaper hook | Installs `hooks/60-omaricethcy-bg.sh` into `~/.config/omarchy/hooks/theme-set.d/` so the per-monitor split survives a theme change, and binds `SUPER SHIFT W` to the cycler |
| Shader | Links `templates/shader.glsl.tpl` into `~/.config/omarchy/themed/`, where Omarchy renders it into whichever theme is active |
| Ghostty | Adds the `config-file` line for the theme palette and points `custom-shader` at the theme's shader. Warns if a hardcoded `theme =` line is still overriding the rice. |
| Default terminal | Puts Ghostty first in `~/.config/xdg-terminals.list` and registers `x-scheme-handler/terminal` |
| Waybar | Turns off Omarchy's Waybar, persistently — the rice uses the quickshell bar, and Waybar would sit on top of it |
| Apply | `omarchy theme set <name>` |

`./install.sh --themes-only` links the themes and touches nothing else.

## Any accent, whole desktop

```bash
omaricethcy-theme '#7aa2f7' blauw --apply
```

Generates a complete theme from one colour — ramp, neutrals, semantics, terminal palette, Hyprland decoration, lock screen, launcher and wallpapers — then applies it. The Ghostty shader needs no per-theme file: it is one template that reads the active palette, see [The shader](#the-shader).

The ramp keeps the seed's hue and walks its lightness down a fixed curve fitted to the hand-authored goud ramp, which it reproduces to within 8/255 per channel. Error and success stay outside the ramp and are pushed at least 22° away from the seed's hue, so a red-accented theme still shows errors in a distinguishable red. Every generated text-carrying slot is lifted until it clears 4.5:1 against the background — blues and violets are perceptually dark and fail at a fixed lightness.

The seed itself is never altered. If it is too dark to read as text the generator says so and points at the lighter variant, rather than quietly changing the colour you picked.

`goud` and `gloed` stay hand-authored: goud is the reference the curve was fitted to, and gloed's ramp shifts hue as it darkens, which this generator does not model.

```bash
python3 bin/test_omaricethcy_theme.py    # 6 checks on the colour maths
```

## Palette

### Primary — the neutral scale

Shared by both themes. This is where every background and surface comes from. It is deliberately not derived from either accent ramp.

| Token | Hex | Role | Contrast on `#181716` |
|---|---|---|---|
| `bg` | `#181716` | Main background | — |
| `surface` | `#211f1d` | Panels, waybar, walker, mako | — |
| `overlay` | `#2d2a27` | Dividers, inactive borders, code blocks | — |
| `muted` | `#4a4541` | Disabled, bright black | — |
| `subtle` | `#837c74` | Comments, secondary text | 4.35:1 |
| `fg_dim` | `#c9bc93` goud / `#d3c4b4` gloed | Dim foreground | 8.6:1 / 9.1:1 |
| `fg` | `#ede4c8` goud / `#f0e3d5` gloed | Foreground | 14.1:1 / 14.4:1 |

The two foregrounds differ on purpose: `#ede4c8` carries a gold cast, `#f0e3d5` an ember one. Same neutral base, different warmth.

### goud — accent ramp

Ten steps of `#E5C125`, each assigned to a role rather than dropped in as a gradient.

| Step | Hex | Role |
|---|---|---|
| 1 | `#e5c125` | Active window border, cursor, focus ring, prompt glyph |
| 2 | `#c7a71f` | Hover, active workspace, links |
| 3 | `#aa8f19` | Icons, secondary accent, module labels |
| 4 | `#8e7713` | Progress fill, accent text on surfaces |
| 5 | `#725f0d` | Accent borders on surfaces |
| 6 | `#584908` | Selection background |
| 7 | `#3f3404` | Badge and chip backgrounds |
| 8 | `#282002` | Accent wash, hover on a dark surface |
| 9 | `#120e00` | Accent-tinted shadow |
| 10 | `#030200` | Deepest shadow |

Steps 1–3 clear 4.5:1 against `#181716` and are safe for text (11.0:1, 8.8:1, 6.5:1). Step 4 sits at 4.1:1 — interface chrome only. Steps 5–10 are surfaces and shadows, never text.

### gloed — accent ramp

| Step | Hex | Role |
|---|---|---|
| 1 | `#ffab40` | Active window border, cursor, focus ring, prompt glyph |
| 2 | `#ff8c00` | Hover, active workspace, links |
| 3 | `#ff6a00` | Icons, secondary accent, module labels |
| 4 | `#ff4d00` | Progress fill, accent text on surfaces |
| 5 | `#ff3200` | Accent borders on surfaces |
| 6 | `#d63100` | Emphasis on surfaces |
| 7 | `#a62600` | Badge and chip backgrounds |
| 8 | `#7c1b00` | Selection background |
| 9 | `#5a1000` | Accent-tinted shadow |
| 10 | `#3b0800` | Deepest shadow |

### Semantic colours

Only red and green stay outside the ramp, so errors and `git diff` remain readable in an otherwise monochrome interface.

| Purpose | goud | | gloed | |
|---|---|---|---|---|
| Error, deletion | `#d85e40` | 4.77:1 | `#ff3200` | 4.87:1 |
| Success, addition | `#8a9d33` | 5.93:1 | `#8a9d33` | 5.93:1 |

gloed needs no separate error colour — the hot end of its own ramp reads as red.

### Terminal ANSI mapping

| Slot | goud | gloed | |
|---|---|---|---|
| `color0` black | `#2d2a27` | `#2d2a27` | neutral |
| `color1` red | `#d85e40` | `#ff3200` | semantic |
| `color2` green | `#8a9d33` | `#8a9d33` | semantic |
| `color3` yellow | `#e5c125` | `#ffab40` | ramp 1 |
| `color4` blue | `#aa8f19` | `#ff6a00` | ramp 3 |
| `color5` magenta | `#c7a71f` | `#ff8c00` | ramp 2 |
| `color6` cyan | `#8e7713` | `#d63100` | ramp 4 / 6 |
| `color7` white | `#c9bc93` | `#d3c4b4` | dim foreground |
| `color8` bright black | `#4a4541` | `#4a4541` | neutral |
| `color9`–`color14` | brighter steps of the above | | |
| `color15` bright white | `#ede4c8` | `#f0e3d5` | foreground |

## How the themes are built

Current Omarchy generates almost every per-application config from a single `colors.toml`. `omarchy-theme-set` calls `omarchy-theme-set-templates`, which renders `~/.local/share/omarchy/default/themed/*.tpl` by substituting `{{ key }}`, `{{ key_strip }}` and `{{ key_rgb }}`.

A theme-local file always wins over its template. So these themes ship `colors.toml` plus exactly the files where the generated output is not enough:

```
themes/<name>/
├── colors.toml           the single source of truth, in both palette schemas
├── hyprland.conf         blur, shadow, rounding, gaps, animations
├── hyprland.lua          the same, in the Lua config Omarchy 4 reads instead
├── hyprlock.conf         lock screen colour variables, incl. ones Omarchy has no template for
├── walker.css            launcher rounding and motion — the template is colours only
├── waybar.css            adds accent and alert, so style.css need not hardcode hexes
├── shell.bar.toml        Omarchy 4's bar, which replaces waybar
├── shell.launcher.toml   Omarchy 4's launcher, which replaces walker
├── icons.theme           GTK icon theme name
├── vscode.json           VS Code theme name and extension id
├── neovim.lua            LazyVim colorscheme spec
└── backgrounds/          wallpapers
```

The `.lua` and `shell.*.toml` files are inert on Omarchy 3 and the `.conf` and `.css` files are inert on Omarchy 4 — see [Ready for Omarchy 4](#ready-for-omarchy-4).

### Adding wallpapers

Each theme has one place to drop new images, split by shape:

```
themes/<name>/wallpapers/
├── landscape/    wide images  (width >= height)
└── portrait/     tall images  (height > width)
```

Drop the file in, then:

```bash
omaricethcy-companions <name>       # or with no argument, every theme
omaricethcy-bg next                 # pick it up
```

That mirrors it into `backgrounds/` and builds the companion for the other shape. It also warns when an image sits in the folder that does not match its real dimensions:

```
WRONGPLACE.jpg   is landscape (1920x1080) but sits in wallpapers/portrait
```

The file is still processed by its real shape rather than by which folder it is in — the folders are there so you know where to put things, not so the tooling can be fooled.

Three directories per theme are **generated and will be overwritten**, so do not edit them by hand:

| Directory | What it is |
|---|---|
| `backgrounds/` | relative symlinks to every wallpaper, flat — this is what Omarchy reads, and it cannot cope with subdirectories |
| `landscape/` | wide companions built from portrait sources |
| `portrait/` | tall companions built from landscape sources |

Symlinks rather than copies because Omarchy's `cp -r` of the theme preserves them and its `find -L` follows them, so nothing is duplicated on disk or in the repository.

### Wallpapers

Each theme carries its own set, split by dominant hue so neither theme shows the other's colour. Cycle with `omarchy theme bg next`, or pick one from the background menu (`SUPER CTRL SPACE`).

| goud | gloed |
|---|---|
| `goudwater` glowing caustics | `stripstad` comic night city, red sky |
| `goudstrepen` blurred gold stripes | `rode-bar` terracotta bar interior |
| `zandloper` hourglass gradient | `avondwolken` white cloud, orange sky |
| `doolhoflijnen` yellow maze lines | `halftoon-bergen` halftone dot mountains |
| `straatlantaarns` amber street lamps | `woestijnwolk` storm cloud over cactus |
| `otter-poster` Zoo Praha vydra print | `bergtop` dark peak, orange sky |
| `batman-silhouet` | `wolkenzee` golden sea of clouds |
| `gele-auto` | `gloed-verloop`, `gloed-kern` generated gradients |
| `rubberplant` | |

#### One wallpaper, two screen shapes

Every photo here is portrait. Omarchy runs `swaybg -i <one image> -m fill` across all outputs at once, which turns a portrait photo on a landscape screen into a cropped slice. swaybg does support `-o`, so `omaricethcy-bg` uses it:

```
swaybg -o DP-2 -i landscape/gouden-koepel.jpg -m fill \
       -o DP-3 -i backgrounds/gouden-koepel.jpeg -m fill
```

A screen gets a companion whenever the wallpaper's shape does not match it. `themes/<name>/landscape/` holds wide versions of portrait sources, `themes/<name>/portrait/` tall versions of landscape ones — the problem is symmetric, and a wide photo on a 1080x1920 screen keeps only 32% of its width without one.

The companion is the photo at full height (or full width), with its own outermost pixel line stretched to fill the rest of the frame. The colour at the join is by definition identical on both sides, so the image carries on into the margin rather than stopping at an edge. The stretched bars are blurred vertically; without that, any subject touching the edge smears into hard horizontal streaks.

That works beautifully for an edge of flat colour and badly for one a subject runs into — the stretch turns leaves or a car body into muddy bands. So each edge is measured independently and only busy ones are treated:

| Edge standard deviation | Treatment |
|---|---|
| below 10% | stretched as-is; it already continues cleanly |
| 10% or above | stretched, then faded outward to the image's dominant colour, so the join keeps the edge's own colour and the far end settles to something clean |

The threshold is not a guess. Across the shipped wallpapers clean edges measure 0.5–9.5% and busy ones 12% and up, so 10 sits in an empty gap. The two are frequently different on the same image: `rubberplant` is 2.3% left and 29.5% right, `batman-silhouet` is exactly the mirror at 28.5% and 0.3%.

The fade mask has to be white at the *outer* end of each bar. Reversed, the dominant colour lands at the join and the seam it was meant to hide becomes the worst part of the image — measured at 210/255 on `rubberplant`'s right edge before it was corrected.

##### Sizing the companions

Companions are rendered at a fixed pixel size, which has to match the screens they are for. `omaricethcy-companions` asks Hyprland what is attached and takes the largest landscape and largest portrait output, so a first run on any machine needs no configuration. Rotated outputs report their unrotated mode, so odd `transform` values are swapped back.

To pin the sizes instead, create `~/.config/omaricethcy/config`:

```bash
LANDSCAPE_SIZE="3440x1440"
PORTRAIT_SIZE="1440x2560"
EDGE_VARIANCE=10        # the busy-edge threshold above, in percent
EDGE_BLUR="0x90"        # vertical blur applied to the stretched bars
```

It is plain shell, sourced by the tool. Precedence is flags, then this file, then what was detected, then `1920x1080` / `1080x1920` if there is no Hyprland to ask. `OMARICETHCY_CONFIG` points at a different file.

Portrait outputs get the untouched original. Orientation comes from `hyprctl monitors`, accounting for rotation: an odd `transform` means the reported width and height are the other way round.

Three approaches that were tried and discarded:

| Approach | Why it failed |
|---|---|
| Blurred copy of the photo | Sources are ~736px wide, so filling 2560px magnifies them ~3.5x. Blur cannot hide structure at that scale — a giant recognisable fragment of the photo sits either side. |
| Gradient from the theme palette | Fine until the image's own background differs from it. A black-backed image on a gold gradient is a hard, ugly seam. |
| Mirrored edges | Produces an obvious axis of symmetry; on anything with a subject it reads as a mirrored monster. |

```bash
omaricethcy-bg next          # or SUPER SHIFT W
omaricethcy-bg set zandloper
omaricethcy-bg list
omaricethcy-companions       # rebuild companions, e.g. after adding photos
```

#### A different wallpaper per screen

Each screen shape keeps its own selection, so the landscape and portrait monitors show different pictures rather than one image rendered twice.

A wallpaper is shown untouched on a screen of its own shape and through its companion on a screen of the other, so which one suits which screen is decided by the image, not by hand.

| Action | Result |
|---|---|
| `set <stem>` | goes to the screen its shape fits; the other screen advances to its own next wallpaper, so both change and each gets something that suits |
| `next` / `previous` | every screen steps within its own shape's pool. The pools are usually different lengths — gloed has 7 portrait and 2 landscape — so the pairing keeps shifting |
| a picker sets the symlink directly | detected on the next `apply` and treated as `set`, so Omarchy's menu and the bar's carousel behave the same way |

When no wallpaper of a given shape exists — the normal case for a set of phone wallpapers, and true of `goud` today — that screen falls back to the other shape's list and shows it through its companion. That is exactly what this did before per-screen selections existed, so nothing regresses when a theme has portrait images only.

Selections live in `${XDG_STATE_HOME:-~/.local/state}/omaricethcy/<theme>`, one file per theme.

Switching themes does not bring back the exact pair a theme last had. `omarchy theme set` ends by calling its own `omarchy-theme-bg-next`, which rewrites the background symlink; the watcher sees that as someone choosing a wallpaper and records it. The theme comes back one step along rather than where it was left. That matches what stock Omarchy does — it cycles the wallpaper on every theme change — so it is left alone rather than fought with a lock file.

#### Keeping the split applied

Everything that changes a wallpaper in Omarchy ends by pointing one image at every output, which undoes the split. There is no hook for it, so three things cover the routes:

The backstop is a systemd user path unit that watches the background symlink and re-applies whenever it changes. It does not care which process changed it or what that process's `PATH` was, so it covers every route including ones that never touch the shims:

```
systemd/omaricethcy-bg.path      watches ~/.config/omarchy/current
systemd/omaricethcy-bg.service   runs `omaricethcy-bg apply`
```

Two details that are easy to get wrong here:

- It watches the **directory**, not the symlink. `ln -nsf` replaces a symlink by renaming over it, and `PathChanged=` on a file waits for a write followed by a close, which a rename never produces. The rename does show up as a change to the containing directory.
- The service sets `KillMode=process`. `Type=oneshot` tears down the unit's cgroup once `ExecStart` returns, and the default `control-group` mode killed the very swaybg the unit had just started.

`omaricethcy-bg apply` exits early when swaybg already has the arguments it would set, so the symlink write it performs does not retrigger the unit forever.

On top of that, shims in `~/.local/bin` intercept the two Omarchy commands directly, which avoids the brief double swaybg launch the watcher path incurs:

| Route | Covered by |
|---|---|
| `omarchy theme set` | `hooks/60-omaricethcy-bg.sh` in `~/.config/omarchy/hooks/theme-set.d/` |
| Omarchy's background menu, quickshell bar picker | `bin/shims/omarchy-theme-bg-set` — both call that one command |
| `omarchy theme bg next` | `bin/shims/omarchy-theme-bg-next` |
| Anything else, including long-running processes with a stale environment | the path unit above |

Each shim runs the real Omarchy command then re-applies, so deleting them restores stock behaviour exactly.

The shims depend on `~/.local/bin` preceding `~/.local/share/omarchy/bin`, which in the graphical session it did not: `~/.config/uwsm/env` prepends Omarchy's bin, putting it ahead. `install.sh` does not touch that file — fixing it is a one-line addition of `export PATH=$HOME/.local/bin:$PATH` after Omarchy's line. Without it the shims are simply skipped and the path unit does the work instead.

Selecting a wallpaper from outside the current theme has no companion to pair with, so `omaricethcy-bg apply` leaves Omarchy's single-image result alone rather than failing.

`~/.config/omarchy/current/background` keeps pointing at the sharp original, because other things follow that symlink — the quickshell bar among them.

### ASCII art

The theme's own name, rendered as a slab-letter banner in its accent:

```bash
omaricethcy-ascii            # rebuild for every theme
```

There is no `figlet` here and it is not worth a dependency, so the letter forms live in the script. Anything outside the defined set falls back to a filled block, so a new theme name still produces something rather than failing.

The letterforms are stored small and enlarged on the way out, `--scale 2` by default. Terminal text size is fixed by the font, so a bigger banner has to mean taller glyphs. Scaling is not a matter of repeating each row: a half block fills half a cell, so at twice the size `▀` becomes one full cell followed by an empty one. Getting that wrong turns `O`, `U` and `D` into the same shape, since they differ only in their top row.

```bash
omaricethcy-ascii --scale 1    # 5 rows x 23 columns
omaricethcy-ascii --scale 2    # 9 rows x 41 columns, the default
```

It writes three files per theme, because each surface needs a different form:

| File | Used by |
|---|---|
| `ascii/logo.txt` | fastfetch's logo, and the shell greeting |
| `ascii/logo.png` | the lock screen — hyprlock labels are single-line and the banner is six |
| `unlock.png` | the Plymouth boot logo, at the 800x188 the stock themes use |

fastfetch colours it with ANSI `yellow`, which is `color3` and therefore the accent, so it follows the theme with no per-theme wiring.

#### Typing it out

The banner types itself in, one whole letter per frame, on a new shell and on the lock screen.

```bash
omaricethcy-banner                   # default: type, one letter at a time
omaricethcy-banner --style sweep     # wipe left to right, column by column
omaricethcy-banner --style lines     # one row of the banner at a time
omaricethcy-banner --style fade      # fade from the background up to the accent
omaricethcy-banner --style none      # static
```

By the time the banner is a file it is flat text, and the block glyphs are multi-byte, so the columns each letter ends at cannot be recovered from it. `omaricethcy-ascii` writes them alongside as `ascii/logo.widths`.

**Shell.** A guarded block at the end of `~/.bashrc`. It costs about **215ms per interactive shell** — 72ms becomes 287ms — paid on every new terminal and every split:

```bash
omaricethcy-banner --delay 25   # roughly half the cost
OMARICETHCY_BANNER=off          # skip it
```

It prints without animating when stdout is not a terminal or the terminal cannot do truecolour, so scripts and pipes are unaffected.

**Lock screen.** hyprlock cannot animate — an image is static and a label is a single line — but it will re-run a command on a timer. So each of the six banner rows is its own label calling `omaricethcy-banner --lock-row N`, and how much is revealed comes from elapsed time rather than from a frame counter, since the labels are separate processes with no shared state. The clock is a marker file in `$XDG_RUNTIME_DIR`; when it is older than 30 seconds the next lock is treated as a fresh session and the banner types again.

Two costs worth knowing. The rows are padded to equal width because hyprlock centres each label on its own and unequal rows drift out of alignment — and the padding counts characters, not bytes, since `printf`'s field width is bytes and these glyphs are three bytes each. And the labels keep polling after the animation finishes: six labels at 80ms is about 75 executions a second for as long as the lock screen is up. hyprlock has no way to stop an update timer once it has started.

fastfetch stays static; it renders its logo once and exits. The other moving piece is the Ghostty background shader — a spinning ASCII logo, separate from all of this.

The boot splash is the one piece `install.sh` does not wire up — `omarchy-plymouth-set-by-theme` is marked `requires-sudo` and rebuilds the initramfs, which is not something an installer should do behind your back:

```bash
omarchy plymouth set-by-theme gloed   # asks for sudo, rebuilds initramfs
```

### The launcher

Omarchy's walker `style.css` is imported *after* the theme's `walker.css` and sets `.box-wrapper { border: 2px solid @border }`, which wins on source order — that is where the glass frame comes from, and `border: none` from the theme cannot remove it. So `@border` is set to the panel colour and the frame paints itself invisible, and the theme's own rules are qualified with `window` to outrank style.css's bare class selectors.

The selection is marked by a 4px accent bar on its leading edge rather than by outlining the whole panel.

### The bar

The quickshell bar reads `colors.toml`, so it inherited the terminal's semantic red and green — off-theme against a monochrome rice. In `~/.config/quickshell/bar/Theme.qml` the two semantic slots and a hardcoded `green` literal now derive from `accentHint` instead:

```qml
property color color01: Qt.darker(accentHint, 1.45)    // was terminal red
property color color02: Qt.lighter(accentHint, 1.12)   // was terminal green
property color green:   Qt.darker(accentHint, 1.2)     // was #8a9a73
```

`accentHint` previously defaulted to `color01`, so deriving `color01` from it would have been circular; its default is a literal now. `Palette.js` no longer applies `color01`/`color02` from `colors.toml`, which is what lets the declarations above survive.

The terminal keeps its real red and green — `git diff` still reads correctly. Only the bar is monochrome.

Both changes live in your quickshell config rather than in this repository, and apply to every Omarchy theme, not just these two. **The bar does not hot-reload**; restart it with `qs-barctl stop-wait && qs-barctl start`.

### Theme previews

`preview.png` is what the theme picker shows. Without one the picker falls back to the first file in `backgrounds/`, which for these themes meant a raw portrait photo.

```bash
omaricethcy-preview          # rebuild for every theme
```

It composes 1800x1012 from the theme's own assets — a dimmed wallpaper backdrop, an accent rule, the theme name, and the ramp and semantic swatches. Nothing is screenshotted, so previews are reproducible and carry none of the desktop's contents.

Why each override exists, rather than taking the generated version:

| File | Generated version gives | Why it is overridden |
|---|---|---|
| `hyprland.conf` | active border colour, nothing else | No blur, shadow, rounding, gaps or animations |
| `hyprlock.conf` | five colour variables | Not enough for a real lock screen layout |
| `walker.css` | six colour variables | Omarchy's walker `style.css` sets **no** `border-radius` anywhere, so nothing is rounded |
| `waybar.css` | foreground and background | No accent or alert, forcing hardcoded hexes in `style.css` |

Everything else is produced by Omarchy from `colors.toml` and is deliberately **not** committed: `alacritty.toml`, `ghostty.conf`, `kitty.conf`, `foot.ini`, `mako.ini`, `swayosd.css`, `btop.theme`, `obsidian.css`, `helix.toml`, `chromium.theme`, `keyboard.rgb`, `gum.env.conf`.

### The shader

The Ghostty background shader — a slowly spinning ASCII Omarchy logo — is 200 lines of GLSL of which exactly one line differs between themes. Shipping it per theme meant two identical 9K files whose only distinction was a colour constant, and a third copy for every theme generated later.

It is one template instead, at `templates/shader.glsl.tpl`:

```glsl
const vec3  LOGO_COLOR      = vec3({{ accent_rgb }}) / 255.0;
```

`install.sh` links it into `~/.config/omarchy/themed/`, which Omarchy renders into the active theme on every `omarchy theme set`, substituting from that theme's `colors.toml`. `{{ accent_rgb }}` expands to a decimal triple, hence the `/ 255.0`.

Two things fall out of this beyond removing the duplication. Themes generated later get the shader without doing anything. And so do Omarchy's own themes — switching to catppuccin now gives a catppuccin-blue logo rather than a dangling `custom-shader` path.

### Configs outside the theme

Three files live in `~/.config/` rather than in a theme, because they are layout rather than colour, and they read the theme's variables so they follow whichever theme is active:

- `~/.config/hypr/hyprlock.conf` — lock screen layout. Sources the theme's `hyprlock.conf` for colours.
- `~/.config/waybar/style.css` — bar layout. Imports the theme's `waybar.css`; uses `@alert` rather than a hex.
- `~/.config/ghostty/config` — must contain `config-file = ?"~/.config/omarchy/current/theme/ghostty.conf"` or Ghostty ignores the theme entirely, and `custom-shader = "~/.config/omarchy/current/theme/shader.glsl"` so the shader switches with the theme.

Not yet shipped, and optional: `preview.png` and `preview-unlock.png` (theme picker thumbnails, 1800×1012 and 1920×1080) and `unlock.png` (Plymouth boot logo, 800×188).

## Ready for Omarchy 4

Omarchy 4 rewrites three things this rice is built on. The themes carry both versions of each, so a theme directory works on Omarchy 3 today and on Omarchy 4 whenever the machine gets there. Nothing has to be switched over on upgrade day.

| | Omarchy 3 | Omarchy 4 |
|---|---|---|
| Palette | `color0`…`color15` | semantic names — `red`, `lighter_background`, `bright_foreground` |
| Hyprland | hyprlang, `hyprland.conf` | Hyprland's own Lua config, `hyprland.lua` |
| Desktop surfaces | waybar + walker + mako + swayosd + hyprlock | one built-in shell, configured by `shell.toml` |

`colors.toml` holds both palettes in one file. Omarchy 3 reads the ANSI half and never sees the semantic names; Omarchy 4 prefers the semantic names and falls back to the ANSI half only for what a theme leaves out. Both halves are written by `bin/omaricethcy-omarchy4`, which reads a theme's existing palette rather than a seed colour, so hand-authored `gloed` migrates as faithfully as generated `goud`:

```bash
bin/omaricethcy-omarchy4            # every theme
bin/omaricethcy-omarchy4 --check    # report drift, write nothing, exit 1 if stale
```

`bin/omaricethcy-theme` runs it automatically, so a newly generated theme is born with both halves.

### Why the semantic names are written out rather than left to fall back

Omarchy 4 can already read an Omarchy 3 palette. Relying on that costs three things, two of which are repaired here:

- **`lighter_background`** falls back to `color0` — but `color0` is first overwritten with `background`. Panels and dividers would flatten into the background instead of lifting off it. Stated explicitly as `#2d2a27`.
- **`light_foreground`** falls back to `color7`, likewise overwritten with `foreground`. The dim foreground would stop being dim. Stated explicitly.
- **`cursor`** is assigned from `bright_foreground` unconditionally and cannot be set by a theme at all. The accent-coloured cursor does not survive Omarchy 4. Nothing in this repository can change that; it is upstream's decision, recorded here so it is not mistaken for a bug later.

One value is changed on purpose rather than repaired: `orange` defaults to `yellow`, which in both themes *is* the accent, so a token meant to give a warmer step gives back the accent. It is set to `color4` instead — `#aa8f19` in goud, `#ff6a00` in gloed.

Everything else Omarchy 4 derives is written out too, at the values its own `mix` would have produced. That is deliberate: the fallback cascade is upstream's compatibility shim and is free to change, whereas a name the theme states itself is not.

### What is verified, and what is not

Verified on this machine, against Omarchy 3.8.4 and against Omarchy 4's own `omarchy-theme-color` resolver run directly on these files:

- Every token Omarchy 3's templates substitute resolves to exactly the value it did before the migration, for both themes.
- Re-applying a theme regenerates all 24 per-application configs **byte-identically** to before.
- Under the Omarchy 4 resolver, only the four intended keys change — `light_foreground`, `lighter_background`, `orange`, `brown`. Nothing else moved.
- `hyprctl configerrors` stays clean.
- `python3 bin/test_omaricethcy_omarchy4.py` — 6 tests, including that the committed files match what the tool produces, so a stale theme fails the suite rather than drifting quietly.

Not verified, because it needs a machine actually running Omarchy 4: that `hyprland.lua` and the two `shell.*.toml` files load. They are written against upstream's own `default/hypr/looknfeel.lua` and `default/themed/shell.toml.tpl`, but reading a format is not the same as running it. The one line to check first is `shadow.offset = "0 4"`, where the Lua spelling of a two-component value is inferred rather than seen.

### What Omarchy 4 does not carry over

Omarchy 4 deletes waybar, walker, mako, swayosd and hyprlock, which is most of the layer this rice hand-built in `~/.config/`. That layer is outside the theme and outside this repository, so it is not migrated here:

- The nine-label hyprlock lock screen and its typed ASCII banner. Omarchy 4's lock is the built-in shell's, configured by `[lock]` in `shell.toml`, which has no per-row label mechanism.
- The quickshell bar. Omarchy 4 ships its own; `shell.bar.toml` carries the one decision worth keeping, which is that attention is the accent rather than a second hue.
- The borderless launcher. `shell.launcher.toml` reproduces the frameless card and accent selection; the leading-edge accent bar has no equivalent, since the launcher section has no per-side border width.
- The `omarchy-launch-walker` and `omarchy-theme-bg-*` shims, which intercept commands that may be renamed.

The per-monitor wallpaper tooling is unaffected — it drives `swaybg` directly and never went through Omarchy.

## Roadmap

- **herdr.** `~/.config/herdr/config.toml` has no `[theme]` section, so the terminal workspace manager falls back to its built-in catppuccin — purple and blue against the rice. Themeable via `[theme]` / `[theme.custom]`.
- **aether.** `~/.config/aether/theme.css` hardcodes `@define-color accent_bg_color #7aa2f7` (blue), and every override in `theme.override.css` is commented out. Aether is not in Omarchy's theme pipeline, so it needs wiring by hand or by a `theme-set` hook.
- **fastfetch.** The logo now uses ANSI `yellow`, which is `color3` and therefore the accent, so it follows the theme with no per-theme file. The Hardware section's `keyColor` is still `green` (`color2`, the olive `#8a9d33`) — the only remaining off-ramp colour there, since `blue` and `magenta` both map into the gold ramp.
- **Wallpaper resolution.** Every shipped photo is at most 736px wide. The blur-fill companions make the framing work on a landscape screen, but they cannot add detail that is not in the source — the sharp centre panel is still an upscale.
- **Background menu.** Omarchy exposes no hook for its own background picker, so choosing a wallpaper there sets one image across both screens. `SUPER SHIFT W` restores the per-monitor split.
- **neovim.** Currently Gruvbox with the palette substituted via `palette_overrides`. A bespoke colorscheme is a later round.
- **VS Code.** Currently points at Gruvbox Dark Medium / Hard. Close in tone, not exact.
- **Preview images.** `preview.png`, `preview-unlock.png` and `unlock.png` are still missing, so the theme picker has no thumbnail and Plymouth has no themed boot logo.
- **The `~/.config/` layer on Omarchy 4.** The themes are ready; the hand-built layer around them is not. The lock screen, the bar and the launcher all have to be rebuilt against Omarchy 4's shell — see [What Omarchy 4 does not carry over](#what-omarchy-4-does-not-carry-over). Worth doing on the day of the upgrade, not before.

## Credits

Structure follows the stock Omarchy themes ([basecamp/omarchy](https://github.com/basecamp/omarchy), MIT). Colours are original.

## License

MIT — see [LICENSE](LICENSE).
