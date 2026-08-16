# Terminal palette and selector refresh

## Goal

Give `goud` and `gloed` complete, readable terminal color sets while preserving their brass and ember identities. Remove theme names baked into picker images, give the launcher a restrained active state, and reintroduce black-led wallpapers without restoring the user-deleted files.

## Scope

- `themes/goud/colors.toml` and `themes/gloed/colors.toml`
- `themes/goud/shell.lock.toml` and `themes/gloed/shell.lock.toml`
- `themes/goud/hyprland.lua` and `themes/gloed/hyprland.lua`
- `bin/omaricethcy-omarchy4`
- `bin/omaricethcy-preview`
- theme previews, wallpaper source trees, generated companion links, tests, and README documentation

No files under `/usr/share/omarchy` or global user configuration are changed.

## Palette

Both themes use a Kanagawa Dragon-derived ANSI role palette. Near-black surfaces and light warm-neutral text remain shared. ANSI roles become distinct:

- red: muted vermilion
- green: moss
- yellow: subdued gold
- blue: indigo
- magenta: muted violet
- cyan: blue-green

`goud` keeps brass for its accent, focus border, cursor, and selection treatment. `gloed` keeps ember for those same theme-identity surfaces. Neither theme maps blue, cyan, and magenta back to orange or yellow.

Semantic Omarchy fields and ANSI `color0` through `color15` remain equivalent. Any generated colors must update both representations together.

## Selector and launcher

`bin/omaricethcy-preview` continues to compose a dimmed wallpaper, accent rule, and swatches, but does not annotate text. Omarchy supplies the theme name outside the image.

`bin/omaricethcy-omarchy4` generates `shell.launcher.toml` for each theme. The launcher uses a subtle visible border and a selected-row frame built from box-drawing ASCII glyphs, with a low-contrast surface tint and readable selected text. The frame is a selection signal, not an enclosing decorative panel.

The generator is the source of truth; generated theme artifacts are committed with it.

## Wallpapers

Keep the fourteen existing deleted files deleted. Add only high-resolution images that are predominantly black and fit the themes' industrial, terminal, and ASCII character. Each new source image must have explicit reuse permission, include its attribution or source URL in repository documentation, and have usable landscape and portrait companions. Regenerate the relative `backgrounds/` symlinks and selector previews afterward.

## Failure handling

Existing preview fallback to a solid theme background remains when no eligible backdrop exists. Existing wallpaper selection fallback to the source image remains when an orientation companion is unavailable. Missing or invalid palette fields must continue to fail the existing generator/dry-run checks.

## Verification

- Run the project’s focused generator and dry-run tests.
- Regenerate previews and inspect them: no text appears inside either image; accent rule and swatches remain legible.
- Exercise the generated launcher configuration and confirm its visible border and selected ASCII frame are present.
- Confirm existing deleted background paths remain absent and every replacement source is documented.
- Obtain a separate code-review pass after implementation.
