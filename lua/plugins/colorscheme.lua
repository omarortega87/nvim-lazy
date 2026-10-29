return {
  -- add gruvbox
  { "neanias/everforest-nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
      -- Do not open the floating changelog/news window automatically.
      news = {
        lazyvim = false,
        neovim = false,
      },
    },
  },
}
