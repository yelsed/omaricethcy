-- Linked to ~/.config/hypr/looknfeel.lua by install.sh, replacing Omarchy's
-- stock file.
--
-- Corner rounding, borders, blur, shadows and animations are not here: each
-- theme sets them in its own hyprland.lua, which Omarchy loads before this
-- file. Repeating them here would silently win over the theme.

-- Blender composites its own viewport, and the inactive-window opacity Omarchy
-- applies muddies it. The tag has to go along with the opacity: Omarchy tags
-- windows `default-opacity` and applies the fade through that tag, so setting
-- opacity alone leaves the tagged rule still in play. Two rules because Blender
-- reports its class differently depending on how it was launched.
o.window("blender", { tag = "-default-opacity", opacity = "1 1" })
o.window("Blender", { tag = "-default-opacity", opacity = "1 1" })
