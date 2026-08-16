#!/usr/bin/env python3
"""Self-check for the Omarchy 4 migration. Run: python3 bin/test_omaricethcy_omarchy4.py"""

import importlib.machinery
import importlib.util
import pathlib
import re

BIN = pathlib.Path(__file__).resolve().parent
REPOSITORY = BIN.parent
loader = importlib.machinery.SourceFileLoader("omaricethcy_omarchy4", str(BIN / "omaricethcy-omarchy4"))
spec = importlib.util.spec_from_loader(loader.name, loader)
migration = importlib.util.module_from_spec(spec)
loader.exec_module(migration)

# Every token Omarchy 3's templates substitute. Losing any of these breaks the
# desktop on the version actually installed, so the migration must keep them all.
OMARCHY_3_TOKENS = (
    "accent", "background", "cursor", "foreground",
    "selection_background", "selection_foreground",
) + tuple(f"color{index}" for index in range(16))

THEMES = sorted(path for path in (REPOSITORY / "themes").iterdir() if path.is_dir())


def parse_as_omarchy_3(text):
    """Omarchy 3's parser: split on the first =, take what is between quotes."""
    values = {}
    for line in text.splitlines():
        key, separator, value = line.partition("=")
        key = re.sub(r"[\"' ]", "", key)
        if not key or key.startswith("#") or not separator:
            continue
        quoted = re.search(r'"([^"]*)"', value)
        if quoted:
            values[key] = quoted.group(1)
    return values


def test_shipped_themes_are_in_sync_with_the_tool():
    """The committed files must be what the tool produces, or the next run churns them."""
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        palette = migration.semantic_palette(colors)
        for filename, produced in (
            ("colors.toml", migration.colors_toml(colors, palette)),
            ("hyprland.lua", migration.hyprland_lua(palette, theme_dir.name)),
            ("shell.bar.toml", migration.shell_bar_toml(palette)),
            ("shell.launcher.toml", migration.shell_launcher_toml(palette)),
            ("shell.menu.toml", migration.shell_menu_toml(palette)),
        ):
            on_disk = (theme_dir / filename).read_text()
            assert on_disk == produced, f"{theme_dir.name}/{filename} is stale, rerun bin/omaricethcy-omarchy4"


def test_launcher_has_visible_container_and_selection_frame():
    """Each shipped theme gives the launcher and its selected row a restrained frame."""
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        palette = migration.semantic_palette(colors)
        launcher = migration.shell_launcher_toml(palette)
        expected_lines = (
            f'border                    = "{palette["muted"]}"',
            "border-alpha              = 0.80",
            f'selected-background       = "{palette["accent"]}"',
            "selected-background-alpha = 0.16",
            f'selected-text             = "{palette["accent"]}"',
            f'selected-border           = "{palette["accent"]}"',
            "selected-border-alpha     = 1.0",
        )
        for expected_line in expected_lines:
            assert expected_line in launcher, f"{theme_dir.name}: missing {expected_line}"


def test_menu_has_visible_container_and_selection_frame():
    """Super+Space must use the same restrained frame as the launcher."""
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        palette = migration.semantic_palette(colors)
        menu = migration.shell_menu_toml(palette)
        expected_lines = (
            f'border                    = "{palette["muted"]}"',
            "border-alpha              = 0.80",
            f'selected-background       = "{palette["accent"]}"',
            "selected-background-alpha = 0.16",
            f'selected-text             = "{palette["accent"]}"',
            f'selected-border           = "{palette["accent"]}"',
            "selected-border-alpha     = 1.0",
        )
        for expected_line in expected_lines:
            assert expected_line in menu, f"{theme_dir.name}: missing {expected_line}"
def test_omarchy_3_tokens_all_survive():
    for theme_dir in THEMES:
        values = parse_as_omarchy_3((theme_dir / "colors.toml").read_text())
        missing = [token for token in OMARCHY_3_TOKENS if token not in values]
        assert not missing, f"{theme_dir.name}: Omarchy 3 would not find {', '.join(missing)}"


def test_the_two_lossy_fallbacks_are_repaired():
    """Omarchy 4 flattens lighter_background into background and light_foreground into
    foreground unless the theme states them. Both must differ, or the fix did nothing."""
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        assert colors["lighter_background"] != colors["background"], theme_dir.name
        assert colors["light_foreground"] != colors["foreground"], theme_dir.name


def test_semantic_names_agree_with_the_ansi_slots():
    """The two halves describe one palette; a drifting pair means the desktop would
    change colour on upgrade."""
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        for name, slot in {**migration.FROM_ANSI, **migration.FROM_ANSI_OVERWRITTEN}.items():
            assert colors[name] == colors[slot], \
                f"{theme_dir.name}: {name} {colors[name]} but {slot} {colors[slot]}"


def test_terminal_roles_are_distinct():
    """Terminal roles must remain individually recognizable across shipped themes."""
    roles = ("red", "green", "yellow", "blue", "magenta", "cyan")
    for theme_dir in THEMES:
        colors = migration.parse_colors(theme_dir / "colors.toml")
        role_colors = [colors[role] for role in roles]
        assert len(set(role_colors)) == len(role_colors), theme_dir.name
        for role in ("blue", "magenta", "cyan"):
            assert colors[role] not in (colors["orange"], colors["yellow"]), \
                f"{theme_dir.name}: {role} duplicates orange or yellow"

def test_mix_matches_omarchys_rounding():
    """Values written here have to equal the ones Omarchy would derive, or a theme
    changes shade the moment upstream stops shipping the key."""
    for start, end, amount, want in (
        ("#181716", "#000000", 0.25, "#121111"),
        ("#181716", "#000000", 0.50, "#0c0c0b"),
        ("#ffffff", "#000000", 0.50, "#808080"),
        ("#aa8f19", "#000000", 0.50, "#55480d"),
    ):
        got = migration.mix(start, end, amount)
        assert got == want, f"mix({start}, {end}, {amount}) = {got}, expected {want}"


def test_migration_is_idempotent():
    for theme_dir in THEMES:
        first = migration.parse_colors(theme_dir / "colors.toml")
        second = parse_as_omarchy_3(migration.colors_toml(first, migration.semantic_palette(first)))
        third = parse_as_omarchy_3(
            migration.colors_toml(second, migration.semantic_palette(second))
        )
        assert second == third, f"{theme_dir.name}: a second run would change the file"


if __name__ == "__main__":
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} passed")
