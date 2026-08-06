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
        bright_red = "#ff5c33",
        neutral_red = "#ff3200",
        faded_red = "#a62600",
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
