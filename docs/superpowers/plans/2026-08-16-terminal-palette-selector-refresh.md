# Terminal Palette and Selector Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make both themes readable in terminals, text-free in picker previews, visibly selectable in the Omarchy launcher, and supported by black-led wallpapers.

**Architecture:** `colors.toml` remains the palette source of truth. `bin/omaricethcy-omarchy4` reads its ANSI slots to generate semantic Omarchy 4 colors and the launcher override; `bin/omaricethcy-preview` renders `preview.png` from each theme’s palette and a selected wallpaper. Wallpaper sources live under each theme and are exposed through generated relative links in `backgrounds/`.

**Tech Stack:** Python 3, TOML theme files, ImageMagick, Omarchy 3/4 theme conventions, shell scripts.

**Spec:** `docs/superpowers/specs/2026-08-16-terminal-palette-selector-design.md`

## Global Constraints

- Do not modify `/usr/share/omarchy` or global user configuration.
- Preserve the fourteen pending deleted wallpaper paths; do not restore them.
- Use Kanagawa Dragon-derived ANSI roles: red, green, yellow, blue, magenta, and cyan must have visibly distinct hues.
- Keep brass exclusive to Goud identity surfaces and ember exclusive to Gloed identity surfaces.
- Maintain Omarchy 3 ANSI compatibility and Omarchy 4 semantic/ANSI equality.
- Commit generator output with its source.
- Only add high-resolution black-led wallpapers with explicit reuse permission and documented source URLs.

---

### Task 1: Establish the complete terminal palettes

**Files:**
- Modify: `themes/goud/colors.toml:6-60`
- Modify: `themes/gloed/colors.toml:6-60`
- Modify: `bin/test_omaricethcy_omarchy4.py:40-101`

**Interfaces:**
- Consumes: `semantic_palette(colors)` mapping from `bin/omaricethcy-omarchy4`.
- Produces: complete ANSI palettes that map directly to Omarchy semantic fields.

- [ ] **Step 1: Add a failing role-separation test**

Add a test that parses each shipped `colors.toml`, converts red, green, yellow, blue, magenta, and cyan hex values to RGB, and asserts every pair differs. Assert specifically that each theme’s `blue`, `cyan`, and `magenta` differs from `orange` and `yellow`.

- [ ] **Step 2: Run the migration self-check to establish the missing contract**

Run: `python3 bin/test_omaricethcy_omarchy4.py`

Expected: FAIL because the current palettes reuse brass/ember values for multiple terminal roles.

- [ ] **Step 3: Replace the ANSI role maps with Kanagawa Dragon-derived values**

Use these terminal values in both themes, while preserving theme-specific `accent`, `selection`, cursor, and warm-neutral foreground values:

```toml
red             = "#c4746e"
green           = "#8a9a7b"
yellow          = "#c4b28a"
blue            = "#8ba4b0"
magenta         = "#a292a3"
cyan            = "#8ea4a2"
bright_red      = "#e46876"
bright_green    = "#87a987"
bright_yellow   = "#e6c384"
bright_blue     = "#7fb4ca"
bright_magenta  = "#938aa9"
bright_cyan     = "#7aa89f"
```

Set matching legacy slots: `color1`, `color2`, `color3`, `color4`, `color5`, `color6`, then bright `color9` through `color14`. Keep `orange` a darkened form of the theme identity (`#aa8f19` for Goud and `#ff6a00` for Gloed) rather than an ANSI replacement.

- [ ] **Step 4: Regenerate Omarchy 4 theme artifacts**

Run: `python3 bin/omaricethcy-omarchy4 goud gloed`

Expected: rewrites `colors.toml`, `hyprland.lua`, `shell.bar.toml`, and `shell.launcher.toml` for both themes without erasing the new complete ANSI roles.

- [ ] **Step 5: Run focused palette tests**

Run: `python3 bin/test_omaricethcy_omarchy4.py && python3 bin/test_omaricethcy_theme.py`

Expected: both scripts pass; semantic names equal their legacy ANSI slots.

- [ ] **Step 6: Commit the palette contract**

```bash
git add themes/goud/colors.toml themes/gloed/colors.toml \
  themes/goud/hyprland.lua themes/gloed/hyprland.lua \
  themes/goud/shell.bar.toml themes/gloed/shell.bar.toml \
  themes/goud/shell.launcher.toml themes/gloed/shell.launcher.toml \
  bin/test_omaricethcy_omarchy4.py
git commit -m "feat: separate terminal color roles"
```

### Task 2: Remove preview text without reducing picker recognition

**Files:**
- Modify: `bin/omaricethcy-preview:19-133`
- Modify: `README.md:400-414`
- Modify: `themes/goud/preview.png`
- Modify: `themes/gloed/preview.png`

**Interfaces:**
- Consumes: theme palette keys and eligible `landscape/` or `backgrounds/` image.
- Produces: a 1800×1012 preview PNG with dimmed backdrop, accent rule, and swatches but no annotations.

- [ ] **Step 1: Add a preview-command unit test**

Extract the ImageMagick command construction into `preview_command(theme_dir, colors)` and test that its argument list contains no `-annotate` option, while retaining the accent-rule rectangle and every swatch draw command.

- [ ] **Step 2: Run the preview test before changing the generator**

Run the new preview test directly with `python3`.

Expected: FAIL because `build()` currently adds two `-annotate` operations.

- [ ] **Step 3: Remove font discovery and annotation generation**

Delete `FONT_PREFERENCES`, `available_fonts()`, `resolve_fonts()`, the `fonts` parameter, and the `-annotate` command block. Keep the lower dark strip, four-pixel accent rule, and palette swatches.

- [ ] **Step 4: Regenerate both picker images**

Run: `python3 bin/omaricethcy-preview goud gloed`

Expected: each theme prints its generated `preview.png`; neither image contains theme name or subtitle text.

- [ ] **Step 5: Update picker documentation and test**

Rewrite the README preview description to say Omarchy supplies the theme label outside `preview.png`, and assert preview dimensions remain 1800×1012 using ImageMagick identification.

- [ ] **Step 6: Commit picker output and source**

```bash
git add bin/omaricethcy-preview README.md themes/goud/preview.png \
  themes/gloed/preview.png bin/test_omaricethcy_preview.py
git commit -m "feat: simplify theme picker previews"
```

### Task 3: Add a framed launcher selection state

**Files:**
- Modify: `bin/omaricethcy-omarchy4:282-305`
- Modify: `bin/test_omaricethcy_omarchy4.py:40-101`
- Create: `themes/goud/shell.launcher.toml`
- Create: `themes/gloed/shell.launcher.toml`
- Modify: `README.md:157-158,400-414`

**Interfaces:**
- Consumes: `shell_launcher_toml(palette)`.
- Produces: a complete `[launcher]` override with visible container and selected borders for Omarchy 4.

- [ ] **Step 1: Add a failing launcher contract test**

Assert generated launcher text has `border = palette["muted"]`, `border-alpha = 0.80`, `selected-border = palette["accent"]`, `selected-border-alpha = 1.0`, and selected-background alpha `0.16`.

- [ ] **Step 2: Run the migration self-check**

Run: `python3 bin/test_omaricethcy_omarchy4.py`

Expected: FAIL because current launcher output is explicitly borderless and selected-border alpha is zero.

- [ ] **Step 3: Change launcher style generation**

Replace borderless commentary and values with a muted visible container border, the above full-opacity accent selected border, and the 0.16 selected background alpha. Add box-drawing text only where Omarchy’s documented launcher labels support a string field; do not invent unsupported TOML keys. If the current Omarchy schema has no label-decoration field, the selected accent border is the ASCII-inspired frame and no literal glyph is emitted.

- [ ] **Step 4: Regenerate theme overrides and validate exact output**

Run: `python3 bin/omaricethcy-omarchy4 goud gloed && python3 bin/test_omaricethcy_omarchy4.py`

Expected: both `shell.launcher.toml` files exist, match generator output, and focused tests pass.

- [ ] **Step 5: Correct README statements**

Replace claims that launcher/bar overrides are intentionally absent with the generated launcher contract and its visible active state.

- [ ] **Step 6: Commit launcher behavior**

```bash
git add bin/omaricethcy-omarchy4 bin/test_omaricethcy_omarchy4.py \
  themes/goud/shell.launcher.toml themes/gloed/shell.launcher.toml README.md
git commit -m "feat: frame active launcher selections"
```

### Task 4: Add documented black-led wallpaper sources

**Files:**
- Modify: `themes/goud/wallpapers/landscape/`
- Modify: `themes/goud/wallpapers/portrait/`
- Modify: `themes/gloed/wallpapers/landscape/`
- Modify: `themes/gloed/wallpapers/portrait/`
- Modify: `themes/goud/backgrounds/`
- Modify: `themes/gloed/backgrounds/`
- Modify: `README.md:187-210`

**Interfaces:**
- Consumes: high-resolution source images and `bin/omaricethcy-companions`.
- Produces: relative wallpaper links discoverable by `bin/omaricethcy-bg` and picker preview generation.

- [ ] **Step 1: Select explicitly reusable sources**

Use only images released under CC0, Public Domain, Unsplash License, or another repository-compatible reusable license. For every chosen image, record creator, source URL, license, original resolution, and placement in the README inventory.

- [ ] **Step 2: Preserve removals while adding replacements**

Confirm the fourteen pending deleted paths remain deleted. Place new originals under the appropriate `wallpapers/landscape` and `wallpapers/portrait` directories; do not reuse a removed file stem.

- [ ] **Step 3: Regenerate companion links**

Run: `python3 bin/omaricethcy-companions goud gloed`

Expected: `backgrounds/` contains only relative symlinks to current source images, and no removed path returns.

- [ ] **Step 4: Regenerate previews from the new selection**

Run: `python3 bin/omaricethcy-preview goud gloed`

Expected: each preview has a black-led backdrop and remains text-free.

- [ ] **Step 5: Validate images and link targets**

Run ImageMagick `identify` over all added sources and `readlink` over every generated `backgrounds/` entry. Reject assets below 2560×1440 landscape or 1440×2560 portrait, and reject broken relative links.

- [ ] **Step 6: Commit wallpaper assets and inventory**

```bash
git add themes/goud themes/gloed README.md
git commit -m "feat: add dark theme wallpapers"
```

### Task 5: End-to-end verification and review

**Files:**
- Test: `bin/test_omaricethcy_omarchy4.py`
- Test: `bin/test_omaricethcy_theme.py`
- Test: `bin/test_omaricethcy_preview.py`

**Interfaces:**
- Consumes: committed generator source and generated theme assets.
- Produces: evidence that theme regeneration is stable and visible selector artifacts meet the design.

- [ ] **Step 1: Run all focused checks**

Run: `python3 bin/test_omaricethcy_omarchy4.py && python3 bin/test_omaricethcy_theme.py && python3 bin/test_omaricethcy_preview.py && python3 bin/omaricethcy-omarchy4 --check`

Expected: every test passes and `--check` reports no changes.

- [ ] **Step 2: Inspect preview images**

Open both `themes/goud/preview.png` and `themes/gloed/preview.png`; confirm no baked theme text, legible swatches, and no bright yellow/orange-dominant composition.

- [ ] **Step 3: Inspect generated launcher files**

Confirm each launcher file has a visible muted border, full-opacity accent selected border, and no unknown configuration keys.

- [ ] **Step 4: Obtain independent code review**

Ask a separate reviewer to inspect the final diff for palette-role correctness, generator-output synchronization, deleted-wallpaper preservation, and unsupported Omarchy configuration.

- [ ] **Step 5: Commit any reviewer-approved corrections**

```bash
git add -A
git commit -m "fix: address theme refresh review"
```
