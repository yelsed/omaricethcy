#!/usr/bin/env python3
"""Self-check for picker previews. Run: python3 bin/test_omaricethcy_preview.py"""

import contextlib
import io
import importlib.machinery
import importlib.util
import pathlib
import tempfile

BIN = pathlib.Path(__file__).resolve().parent
REPOSITORY = BIN.parent
loader = importlib.machinery.SourceFileLoader("omaricethcy_preview", str(BIN / "omaricethcy-preview"))
spec = importlib.util.spec_from_loader(loader.name, loader)
preview = importlib.util.module_from_spec(spec)
loader.exec_module(preview)

THEME_NAMES = ("goud", "gloed")


def command_for(theme_name):
    command = preview.preview_command(REPOSITORY / "themes" / theme_name)
    assert command is not None
    return command


def selected_swatches(theme_dir):
    colors = preview.read_palette(theme_dir)
    ramp = [colors[f"color{index}"] for index in (5, 4, 6) if f"color{index}" in colors]
    neutrals = [colors.get(key) for key in ("color7", "color8")]
    return [colors.get("accent", colors.get("foreground", "#ede4c8"))] + ramp + [
        value for value in neutrals if value
    ]


def draw_arguments(command):
    return [argument for option, argument in zip(command, command[1:]) if option == "-draw"]


def test_preview_commands_have_no_annotations():
    for theme_name in THEME_NAMES:
        command = command_for(theme_name)
        assert "-annotate" not in command, command


def test_preview_commands_retain_lower_strip_and_accent_rule():
    strip_top = preview.HEIGHT - preview.STRIP_HEIGHT
    for theme_name in THEME_NAMES:
        command = command_for(theme_name)
        colors = preview.read_palette(REPOSITORY / "themes" / theme_name)
        lower_strip = f"rectangle 0,{strip_top} {preview.WIDTH},{preview.HEIGHT}"
        accent_rule = f"rectangle 0,{strip_top} {preview.WIDTH},{strip_top + 4}"
        lower_strip_index = command.index(lower_strip)
        accent_rule_index = command.index(accent_rule)

        assert command[lower_strip_index - 5:lower_strip_index + 1] == [
            "-fill", f"{colors['background']}E8", "-stroke", "none", "-draw", lower_strip,
        ]
        assert command[accent_rule_index - 3:accent_rule_index + 1] == [
            "-fill", colors["accent"], "-draw", accent_rule,
        ]


def test_preview_commands_draw_each_selected_swatch_once():
    for theme_name in THEME_NAMES:
        theme_dir = REPOSITORY / "themes" / theme_name
        command = command_for(theme_name)
        swatch_draws = []
        for draw_index, option in enumerate(command[:-1]):
            if option != "-draw" or not command[draw_index + 1].startswith("roundrectangle"):
                continue
            fill_index = max(
                index for index, candidate in enumerate(command[:draw_index]) if candidate == "-fill"
            )
            swatch_draws.append((command[fill_index + 1], command[draw_index + 1]))

        assert [color for color, draw in swatch_draws] == selected_swatches(theme_dir)
        assert len(swatch_draws) == len(selected_swatches(theme_dir))


def test_missing_palette_skips_preview():
    with tempfile.TemporaryDirectory() as temporary_directory:
        theme_dir = pathlib.Path(temporary_directory)
        message = io.StringIO()

        assert preview.read_palette(theme_dir) == {}
        assert preview.preview_command(theme_dir) is None
        with contextlib.redirect_stderr(message):
            assert not preview.build(theme_dir, "empty")
        assert message.getvalue() == "empty: no colors.toml, skipping\n"


if __name__ == "__main__":
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} passed")
