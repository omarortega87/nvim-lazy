return {
  {
    "folke/which-key.nvim",
    opts = {
      -- Show the which-key popup on <leader>w instead of on <leader> alone.
      -- Replacing the default `<auto>` trigger disables the popup for every
      -- prefix, so the useful non-leader prefixes are listed explicitly.
      triggers = {
        { "<leader>w", mode = { "n", "x" } },
        { "g", mode = { "n", "x" } },
        { "z", mode = { "n", "x" } },
        { "[", mode = { "n", "x" } },
        { "]", mode = { "n", "x" } },
        { "<c-w>", mode = "n" },
      },
    },
  },
}
