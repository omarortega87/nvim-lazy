-- venv-selector requires the `fd` binary. If it is not available, skip loading
-- the plugin so opening a Python file does not raise an error.
-- Install it with `brew install fd` (or another package manager) to enable it.
local function has_fd()
  for _, cmd in ipairs({ "fd", "fdfind", "fd_find" }) do
    if vim.fn.executable(cmd) == 1 then
      return true
    end
  end
  -- Also accept an fd installed through Mason, which is added to PATH later.
  return vim.uv.fs_stat(vim.fn.stdpath("data") .. "/mason/bin/fd") ~= nil
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    enabled = has_fd(),
    opts = {
      options = {
        -- Keep virtualenv activation silent instead of showing status popups.
        notify_user_on_venv_activation = false,
        override_notify = false,
      },
    },
    config = function(_, opts)
      require("venv-selector").setup(opts)
      -- Auto-detect local/pyenv/conda environments for projects that have not
      -- been configured manually yet.
      require("config.python_env").setup()
    end,
  },
  {
    -- venv-selector can only configure LSP clients that have a project root.
    -- Treat environment markers as roots so projects that only contain a venv
    -- still get their interpreter applied to Pyright/Ruff.
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local markers = {
        {
          "pyrightconfig.json",
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "ruff.toml",
          ".ruff.toml",
          ".venv",
          "venv",
          "virtualenv",
          ".python-version",
          "environment.yml",
          "environment.yaml",
        },
        ".git",
      }

      for _, server in ipairs({ "pyright", "basedpyright", "ruff", "ruff_lsp" }) do
        local server_opts = opts.servers[server]
        if server_opts ~= false then
          if type(server_opts) ~= "table" then
            server_opts = {}
            opts.servers[server] = server_opts
          end
          server_opts.root_markers = vim.deepcopy(markers)
        end
      end

      return opts
    end,
  },
}
