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
        bright_red = "#e87a5c",
        neutral_red = "#d85e40",
        faded_red = "#8e4a35",
        bright_green = "#a3b845",
        neutral_green = "#8a9d33",
        faded_green = "#5c6a22",
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
