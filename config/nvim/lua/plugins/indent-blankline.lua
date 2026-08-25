return {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main = "ibl", -- required for v3
  opts = {
    indent = {
      char = "┊",
      tab_char = "┊",
    },
  },
}
