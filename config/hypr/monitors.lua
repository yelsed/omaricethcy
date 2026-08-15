-- Linked to ~/.config/hypr/monitors.lua by install.sh, replacing Omarchy's
-- stock file. See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List outputs and their supported modes with: hyprctl monitors all

-- Omarchy's default is GDK_SCALE 2, for retina-class displays. Both screens
-- here are 1x, and a 2 would render every GTK application at double size.
hl.env("GDK_SCALE", "1")

-- DP-2: LG UltraGear 1440p 165Hz, landscape, primary.
hl.monitor({ output = "DP-2", mode = "preferred", position = "0x0", scale = 1 })

-- DP-3: LG UltraGear 1080p 144Hz, stood on its right edge. transform 3 is 270°,
-- so the panel's 1920x1080 presents as 1080x1920 and sits to the right of DP-2
-- at DP-2's full width.
hl.monitor({ output = "DP-3", mode = "preferred", position = "2560x0", scale = 1, transform = 3 })
