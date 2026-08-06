-- Gruvbox with the goud palette substituted in. Reuses an already-installed
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
        light0 = "#ede4c8",
        light1 = "#ede4c8",
        light2 = "#c9bc93",
        light3 = "#c9bc93",
        light4 = "#837c74",
        bright_yellow = "#e5c125",
        neutral_yellow = "#c7a71f",
        faded_yellow = "#8e7713",
        bright_orange = "#c7a71f",
        neutral_orange = "#aa8f19",
        faded_orange = "#725f0d",
        bright_aqua = "#aa8f19",
        neutral_aqua = "#8e7713",
        faded_aqua = "#725f0d",
        bright_blue = "#c9bc93",
        neutral_blue = "#aa8f19",
        faded_blue = "#725f0d",
        bright_purple = "#c7a71f",
        neutral_purple = "#aa8f19",
        faded_purple = "#725f0d",
        -- Gruvbox paints keywords, conditionals and operators with the red
        -- family, which leaves ordinary code looking like it is full of errors.
        -- The family is folded into the accent ramp instead; real errors keep a
        -- red of their own through the overrides below.
        bright_red = "#e5c125",
        neutral_red = "#c7a71f",
        faded_red = "#aa8f19",
        bright_green = "#a3b845",
        neutral_green = "#8a9d33",
        faded_green = "#5c6a22",
      },
      overrides = {
        DiagnosticError = { fg = "#d85e40" },
        DiagnosticSignError = { fg = "#d85e40" },
        DiagnosticVirtualTextError = { fg = "#d85e40" },
        DiagnosticUnderlineError = { sp = "#d85e40", undercurl = true },
        DiagnosticFloatingError = { fg = "#d85e40" },
        ErrorMsg = { fg = "#d85e40" },
        Error = { fg = "#d85e40" },
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
