-- Omarchy 4 form of hyprland.conf, loaded by Omarchy's
-- require_optional.module("omarchy.current.theme.hyprland"). Runs after
-- Omarchy's own looknfeel and before ~/.config/hypr, same as the .conf did, so
-- personal overrides still win.
--
-- The layer rules the .conf carried are gone on purpose: they blurred walker,
-- waybar, swayosd and mako, none of which exist in Omarchy 4. Their replacement
-- is the built-in shell, whose translucency is set in shell.*.toml.

local active_border_color = "rgb(ff8c00)"
local inactive_border_color = "rgb(4a4541)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },

    border_size = 1,
    gaps_in = 4,
    gaps_out = 8,
  },

  decoration = {
    rounding = 16,
    active_opacity = 1.0,
    inactive_opacity = 0.92,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = true,
      size = 6,
      passes = 3,
      contrast = 1.0,
      brightness = 1.1,
      vibrancy = 0.16,
      vibrancy_darkness = 0.0,
      noise = 0.02,
      ignore_opacity = true,
      new_optimizations = true,
    },

    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(00000066)",
      offset = "0 4",
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },

    groupbar = {
      text_color = "rgb(f0e3d5)",
      gradients = false,
      height = 20,
    },
  },

  animations = {
    enabled = true,
  },
})

hl.curve("fluentDecel", { type = "bezier", points = { { 0, 0.2 }, { 0.4, 1 } } })
hl.curve("easeOutCubic", { type = "bezier", points = { { 0.215, 0.61 }, { 0.355, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "overshot", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshot", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "fluentDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "fluentDecel" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutCubic", style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "easeOutCubic", style = "slidefadevert 15%" })
