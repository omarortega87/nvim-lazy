return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    -- Completion is enabled by default and can be toggled with <leader>uk
    vim.g.completion_enabled = vim.g.completion_enabled ~= false

    Snacks.toggle({
      name = "Completion",
      get = function()
        return vim.g.completion_enabled
      end,
      set = function(state)
        vim.g.completion_enabled = state
      end,
    }):map("<leader>uk")

    opts.enabled = function()
      return vim.g.completion_enabled
    end

    opts.completion = opts.completion or {}

    -- Show the menu automatically, but only when the LSP/keyword actually has
    -- something to offer. Trigger characters (".", "(", etc.) are enabled
    -- below, which is what makes member completion usable in TS/React.
    opts.completion.menu = opts.completion.menu or {}
    opts.completion.menu.auto_show = true

    -- Keep the noisy triggers off (insert mode entry, backspace, snippets),
    -- but enable keyword and trigger-character completion.
    opts.completion.trigger = vim.tbl_deep_extend("force", opts.completion.trigger or {}, {
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert = false,
      show_on_insert_on_trigger_character = false,
      show_on_accept_on_trigger_character = false,
      show_on_backspace = false,
      show_on_backspace_in_keyword = false,
      show_on_backspace_after_accept = false,
      show_on_backspace_after_insert_enter = false,
      show_in_snippet = false,
    })

    -- Do not display inline ghost-text suggestions while typing.
    opts.completion.ghost_text = opts.completion.ghost_text or {}
    opts.completion.ghost_text.enabled = false

    -- Highlight the first item so <CR> accepts it, but never insert a
    -- selection automatically while typing.
    opts.completion.list = opts.completion.list or {}
    opts.completion.list.selection = {
      preselect = true,
      auto_insert = false,
    }

    -- Manual trigger. This mirrors blink.cmp's default `enter` preset keymap.
    opts.keymap = opts.keymap or {}
    opts.keymap["<C-Space>"] = { "show", "show_documentation", "hide_documentation" }

    return opts
  end,
}
