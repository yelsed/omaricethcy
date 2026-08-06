#!/usr/bin/env python3
"""Self-check for the palette generator. Run: python3 bin/test_omaricethcy_theme.py"""

import importlib.machinery
import importlib.util
import pathlib

BIN = pathlib.Path(__file__).resolve().parent
loader = importlib.machinery.SourceFileLoader("omaricethcy_theme", str(BIN / "omaricethcy-theme"))
spec = importlib.util.spec_from_loader(loader.name, loader)
generator = importlib.util.module_from_spec(spec)
loader.exec_module(generator)

BACKGROUND = generator.to_rgb(generator.NEUTRAL["bg"])

# The ramp the seed colour was hand-authored against.
GOUD = ["#e5c125", "#c7a71f", "#aa8f19", "#8e7713", "#725f0d",
        "#584908", "#3f3404", "#282002", "#120e00", "#030200"]


def channels(hex_value):
    return [round(channel * 255) for channel in generator.to_rgb(hex_value)]


def test_reproduces_goud():
    produced = generator.build_ramp(generator.to_rgb("#e5c125"))
    assert len(produced) == 10, produced
    for want, got in zip(GOUD, produced):
        drift = max(abs(a - b) for a, b in zip(channels(want), channels(got)))
        assert drift <= 8, f"{want} -> {got} drifted {drift}/255"


def test_generated_slots_stay_readable():
    """Slots the generator derives must clear 4.5:1 for every hue on the wheel."""
    for hue in range(0, 360, 15):
        seed = generator.to_hex(generator.colorsys.hls_to_rgb(hue / 360, 0.52, 0.79))
        palette = generator.build_palette(seed)
        for slot in ("error", "success", "foreground", "bright"):
            ratio = generator.contrast(generator.to_rgb(palette[slot]), BACKGROUND)
            assert ratio >= 4.5, f"seed {seed}: {slot} {palette[slot]} only {ratio:.2f}:1"


def test_dark_seed_is_reported_not_altered():
    """A seed too dark for text is kept verbatim and flagged, never silently lightened."""
    seed = "#e52424"
    palette = generator.build_palette(seed)
    assert palette["accent"] == seed, f"seed was altered to {palette['accent']}"
    assert generator.accent_warning(palette), "no warning for a 3.93:1 accent"
    assert generator.accent_warning(generator.build_palette("#e5c125")) is None


def test_semantics_stay_distinguishable_from_accent():
    """A red-accented theme must not render errors in the accent colour."""
    for hue in (0, 12, 20, 71, 80):
        seed = generator.to_hex(generator.colorsys.hls_to_rgb(hue / 360, 0.52, 0.79))
        palette = generator.build_palette(seed)
        seed_hue = generator.colorsys.rgb_to_hls(*generator.to_rgb(seed))[0] * 360
        for slot in ("error", "success"):
            slot_hue = generator.colorsys.rgb_to_hls(*generator.to_rgb(palette[slot]))[0] * 360
            gap = generator.hue_distance(slot_hue, seed_hue)
            assert gap >= generator.MIN_HUE_GAP - 1, f"seed {seed}: {slot} only {gap:.1f}deg away"


def test_ramp_darkens_monotonically():
    for seed in ("#e5c125", "#ff8c00", "#7aa2f7", "#cba6f7"):
        ramp = generator.build_ramp(generator.to_rgb(seed))
        luminances = [generator.relative_luminance(generator.to_rgb(step)) for step in ramp]
        assert luminances == sorted(luminances, reverse=True), f"{seed}: {ramp}"


def test_rejects_bad_input():
    for bad in ("nope", "#12345", "#gggggg", ""):
        try:
            generator.to_rgb(bad)
        except ValueError:
            continue
        raise AssertionError(f"accepted invalid colour {bad!r}")


if __name__ == "__main__":
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()
        print(f"ok  {test.__name__}")
    print(f"\n{len(tests)} passed")
