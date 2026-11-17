-- Linked to ~/.config/hypr/monitors.lua by install.sh, replacing Omarchy's
-- stock file. See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List outputs and their supported modes with: hyprctl monitors all

-- Omarchy's default is GDK_SCALE 2, for retina-class displays. Both screens
-- here are 1x, and a 2 would render every GTK application at double size.
hl.env("GDK_SCALE", "1")

-- Both panels are LG UltraGears, and their DP connector numbers move between
-- boots, so they are matched on the description shown by `hyprctl monitors all`
-- rather than on DP-2/DP-3.

-- 1440p 165Hz, landscape, primary.
hl.monitor({
  output = "desc:LG Electronics LG ULTRAGEAR 212MADHBHF58",
  mode = "preferred",
  position = "0x0",
  scale = 1,
})

-- 1080p 100Hz, stood on its right edge. transform 3 is 270°, so the panel's
-- 1920x1080 presents as 1080x1920 and sits to the right of the 1440p at its
-- full width.
hl.monitor({
  output = "desc:LG Electronics LG ULTRAGEAR 0x0007E98B",
  mode = "preferred",
  position = "2560x0",
  scale = 1,
  transform = 3,
})
