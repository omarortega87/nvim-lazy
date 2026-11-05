local java = require("config.java")

-- Register :JavaLsp early, before lazy.nvim finishes loading the specs.
java.setup_command()

-- JDTLS (default). LazyVim's java extra supplies the ft/opts/config; we keep the
-- existing JDK override for jdtls snapshots that require Java 25+.
local jdtls = {
  "mfussenegger/nvim-jdtls",
  cond = java.is("jdtls"),
  opts = function(_, opts)
    -- jdtls 1.6x snapshots require Java 25+ on the VM that runs the server.
    -- The shell default here is JDK 21, so point jdtls at the newer Homebrew JDK.
    opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }
    vim.list_extend(opts.cmd, { "--java-executable", "/opt/homebrew/opt/openjdk/bin/java" })
  end,
}

-- IntelliJ LSP. This plugin must be loaded at startup: do NOT lazy-load it on
-- ft = { "java", "kotlin" }, because the eager build-file import needs it.
local intellij = {
  "JetBrains/intellij-lsp.nvim",
  cond = java.is("intellij"),
  lazy = false,
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {
    -- Consent: leave accept_eula/region unset for the first interactive start,
    -- or set all three to skip the screens. Only set accept_eula = true after
    -- reading the bundle's EULA.txt.
    -- accept_eula = true,
    -- region = "americas", -- africa|americas|apac|china|europe|middle_east|oceania
    data_sharing = "none",

    -- JDK used to analyze projects that do not configure their own.
    default_sdk = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",

    -- blink.cmp owns completion and <CR> in this config.
    autotrigger = false,
    word_triggers = false,
    enter_accepts_completion = false,
    completeopt = false,
    signature_help = false,

    -- Keep the existing colorscheme and formatter.
    colorscheme = false,
    format_on_save = false,

    -- Disabled so <leader>co stays LazyVim's Organize Imports. The hierarchy and
    -- workspace-symbol maps are added under <leader>cj in config() below.
    keymaps = false,

    -- Avoid prompting for a template on every new empty .java/.kt file.
    file_templates = false,

    filetypes = { "java", "kotlin" },
  },
  config = function(_, opts)
    require("intellij-lsp").setup(opts)

    local group = vim.api.nvim_create_augroup("JavaLspIntellijKeys", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = group,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "intellij" then
          return
        end

        -- intellij-lsp installs its buffer-local maps in on_attach. Defer this
        -- so we run after it and can replace the mappings that would shadow
        -- LazyVim's <leader>b buffer group.
        vim.schedule(function()
          local buf = args.buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
          end

          pcall(vim.keymap.del, "n", "<leader>b", { buffer = buf })
          pcall(vim.keymap.del, "n", "<leader>B", { buffer = buf })

          local ok, debug = pcall(require, "intellij-lsp.debug")
          if ok then
            map("<leader>db", debug.toggle_breakpoint, "IntelliJ: toggle breakpoint")
            map("<leader>dB", debug.toggle_conditional_breakpoint, "IntelliJ: conditional breakpoint")
          end

          map("<leader>cjt", "<cmd>IntellijLspTypeHierarchy subtypes<CR>", "Type hierarchy: subtypes")
          map("<leader>cjT", "<cmd>IntellijLspTypeHierarchy supertypes<CR>", "Type hierarchy: supertypes")
          map("<leader>cji", "<cmd>IntellijLspCallHierarchy incoming<CR>", "Call hierarchy: incoming")
          map("<leader>cjo", "<cmd>IntellijLspCallHierarchy outgoing<CR>", "Call hierarchy: outgoing")
          map("<leader>cjs", "<cmd>IntellijLspSymbols<CR>", "Workspace symbols")
        end)
      end,
    })
  end,
}

return { jdtls, intellij }
