-- Keep transient UI out of floating windows.
-- Noice is only used for LSP hover/signature documentation; cmdline, messages,
-- notifications and progress are handled natively by Neovim instead.
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        -- Use Neovim's native cmdline at the bottom instead of a floating popup.
        enabled = false,
      },
      messages = {
        -- Use native messages instead of Noice notification/message popups.
        enabled = false,
      },
      popupmenu = {
        -- Use the native cmdline completion menu.
        enabled = false,
      },
      notify = {
        -- Do not route vim.notify() through Noice's notification popups.
        enabled = false,
      },
      lsp = {
        hover = {
          silent = true,
        },
        progress = {
          -- Never show LSP loading/progress popups.
          enabled = false,
        },
        message = {
          -- Let Neovim display LSP messages natively instead of queueing them in Noice.
          enabled = false,
        },
        signature = {
          auto_open = {
            -- Do not open signature help automatically while typing.
            enabled = false,
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = false,
      },
    },
  },
}
