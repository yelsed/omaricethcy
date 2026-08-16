-- Linked to ~/.config/hypr/input.lua by install.sh, replacing Omarchy's stock
-- file. See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",

    -- Caps Lock becomes the compose key. It is the most reachable key on the
    -- board and the least used one, and this rice types enough Dutch to want
    -- a compose key within reach.
    kb_options = "compose:caps",

    repeat_rate = 40,
    repeat_delay = 600,

    touchpad = {
      scroll_factor = 0.4,
    },
  },
})

-- Terminals scroll by lines rather than pixels, so the same gesture travels
-- much further in them than in a document. Ghostty overshoots worst of the
-- four, hence its own much lower factor rather than a shared one.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Middle-click autoscroll, from estebanhiram/hypr-autoscroll, installed with
-- hyprpm. Direct activation claims the middle button globally, which costs
-- middle-click paste and open-in-new-tab; that trade was made deliberately for
-- Windows-style scrolling everywhere, and SUPER + A in bindings.lua gives the
-- button back when something else needs it.
--
-- Commented out along with its binding until `hyprpm reload` actually loads the
-- plugin. hyprpm builds against a specific Hyprland commit and refuses to load
-- when the two drift apart, and settings for a plugin that is not loaded are
-- reported as a config error on every reload.
-- hl.config({
--   plugin = {
--     hypr_autoscroll = {
--       direct_activation = true,
--     },
--   },
-- })
