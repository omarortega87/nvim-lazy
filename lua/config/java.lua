-- Single source of truth for the Java/Kotlin language backend.
--
-- Precedence:
--   1. NVIM_JAVA_LSP environment variable
--   2. vim.g.java_lsp
--   3. the choice saved by :JavaLsp
--   4. "jdtls"
--
-- Only one backend is loaded at a time (see lua/plugins/java.lua). Changing the
-- backend requires restarting Neovim so that lazy.nvim re-evaluates the plugin
-- specs; use :JavaLsp <backend> followed by :restart.
local M = {}

local VALID = { jdtls = true, intellij = true }
local state_file = vim.fn.stdpath("state") .. "/java_lsp_backend"

local function saved()
  local file = io.open(state_file, "r")
  if not file then
    return nil
  end
  local value = file:read("*l")
  file:close()
  return value
end

--- @return "jdtls"|"intellij"
function M.backend()
  local choice = vim.env.NVIM_JAVA_LSP or vim.g.java_lsp or saved() or "jdtls"
  choice = tostring(choice):lower()

  if not VALID[choice] then
    vim.notify(("Java LSP: unknown backend %q, using jdtls"):format(choice), vim.log.levels.WARN)
    return "jdtls"
  end

  return choice
end

--- @param name "jdtls"|"intellij"
--- @return boolean
function M.is(name)
  return M.backend() == name
end

--- Persist a backend choice for the next Neovim start.
--- @param name "jdtls"|"intellij"
function M.set(name)
  if not VALID[name] then
    vim.notify("Java LSP: backend must be 'jdtls' or 'intellij'", vim.log.levels.ERROR)
    return
  end

  if vim.env.NVIM_JAVA_LSP or vim.g.java_lsp then
    vim.notify("Java LSP: NVIM_JAVA_LSP or vim.g.java_lsp is set and overrides the saved choice", vim.log.levels.WARN)
  end

  local current = M.backend()
  vim.fn.writefile({ name }, state_file)
  vim.notify(
    ("Java LSP: saved %s — restart Neovim with :restart (current session: %s)"):format(name, current),
    vim.log.levels.INFO
  )
end

--- Register :JavaLsp once, as early as the plugin spec is loaded.
function M.setup_command()
  if vim.g.java_lsp_command_registered then
    return
  end
  vim.g.java_lsp_command_registered = true

  vim.api.nvim_create_user_command("JavaLsp", function(args)
    local what = args.fargs[1] or "status"

    if what == "status" then
      local attached = {}
      for _, client in ipairs(vim.lsp.get_clients({ _uninitialized = true })) do
        if client.name == "jdtls" or client.name == "intellij" then
          attached[#attached + 1] = ("%s #%d"):format(client.name, client.id)
        end
      end

      vim.notify(
        ("Java LSP: configured=%s attached=%s"):format(
          M.backend(),
          #attached > 0 and table.concat(attached, ", ") or "none"
        )
      )
    elseif what == "jdtls" or what == "intellij" then
      M.set(what)
    else
      vim.notify("Usage: :JavaLsp [status|jdtls|intellij]", vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    complete = function()
      return { "status", "jdtls", "intellij" }
    end,
  })
end

return M
