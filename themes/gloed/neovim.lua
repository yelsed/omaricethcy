-- Gruvbox with the gloed palette substituted in. Reuses an already-installed
-- colorscheme rather than shipping a bespoke one; the hexes below are the same
-- values as colors.toml.
return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      palette_overrides = {
        dark0_hard = "#181716",
        dark0 = "#181716",
        dark0_soft = "#211f1d",
        dark1 = "#211f1d",
        dark2 = "#2d2a27",
        dark3 = "#4a4541",
        dark4 = "#837c74",
        gray = "#837c74",
        light0 = "#f0e3d5",
        light1 = "#f0e3d5",
        light2 = "#d3c4b4",
        light3 = "#d3c4b4",
        light4 = "#837c74",
        bright_yellow = "#ffab40",
        neutral_yellow = "#ff8c00",
        faded_yellow = "#a62600",
        bright_orange = "#ff8c00",
        neutral_orange = "#ff6a00",
        faded_orange = "#7c1b00",
        bright_aqua = "#ff6a00",
        neutral_aqua = "#d63100",
        faded_aqua = "#7c1b00",
        bright_blue = "#d3c4b4",
        neutral_blue = "#d63100",
        faded_blue = "#7c1b00",
        bright_purple = "#ff8c00",
        neutral_purple = "#d63100",
        faded_purple = "#7c1b00",
        -- Gruvbox paints keywords, conditionals and operators with the red
        -- family, which leaves ordinary code looking like it is full of errors.
        -- The family is folded into the amber end of the ramp instead; real
        -- errors keep the hot end through the overrides below, which stays
        -- distinguishable from amber even though gloed has no separate red.
        bright_red = "#ffab40",
        neutral_red = "#ff8c00",
        faded_red = "#ff6a00",
        bright_green = "#a3b845",
        neutral_green = "#8a9d33",
        faded_green = "#5c6a22",
      },
      overrides = {
        DiagnosticError = { fg = "#ff3200" },
        DiagnosticSignError = { fg = "#ff3200" },
        DiagnosticVirtualTextError = { fg = "#ff3200" },
        DiagnosticUnderlineError = { sp = "#ff3200", undercurl = true },
        DiagnosticFloatingError = { fg = "#ff3200" },
        ErrorMsg = { fg = "#ff3200" },
        Error = { fg = "#ff3200" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
