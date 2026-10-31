local function version()
  local v = vim.version()
  return ("Neovim %d.%d.%d"):format(v.major, v.minor, v.patch)
end

return {
  {
    "snacks.nvim",
    opts = {
      -- Notifications are shown by Neovim's native message area instead of
      -- floating notification popups.
      notifier = { enabled = false },
      -- Use the native command-line prompt instead of a floating input popup.
      input = { enabled = false },
      dashboard = {
        -- A narrower dashboard keeps the home screen centered and uncluttered.
        width = 54,
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
╭───────────────────────────╮
│                           │
│    D e v e l o p i n g    │
│                           │
╰───────────────────────────╯]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find Files", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "g", desc = "Live Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = 2 },
          { section = "keys", padding = 1 },
          { text = { { version(), hl = "NonText" } }, align = "center", padding = 1 },
        },
      },
    },
  },
}
