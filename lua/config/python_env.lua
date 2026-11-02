-- Automatic Python environment detection.
--
-- Finds a project-local interpreter (or a pyenv/conda environment referenced by
-- the project) and activates it through venv-selector. It deliberately stays
-- conservative:
--
--   * Explicit venv-selector cache entries always win.
--   * Manually selected environments already active for this project are kept.
--   * Deactivated buffers and uv/PEP 723 buffers are left alone.
--   * Auto-detected environments are not written to the persistent cache, so a
--     later manual selection remains authoritative.
--
-- In-project poetry/uv/pipenv environments are covered by the `.venv` search.
-- Environments kept in external tool caches remain available through the
-- regular venv-selector picker.

local M = {}

local uv = vim.uv

local venv_dir_names = { ".venv", "venv", "env", "virtualenv" }
local python_rel_paths = { "bin/python", "bin/python3", "Scripts/python.exe" }

local root_markers = {
  ".git",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  "uv.lock",
  "poetry.lock",
  "pyrightconfig.json",
}

-- Used to decide whether an active environment belongs to the current
-- project. The nearest marker/venv wins, so sibling packages in a monorepo are
-- treated as separate projects.
local scope_markers = vim.list_extend(vim.list_extend({}, venv_dir_names), root_markers)

---@type table<string, uv.uv_timer_t>
local timers = {}

---@param bufnr integer
---@return boolean
local function valid_python_buf(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and vim.bo[bufnr].filetype == "python"
end

---@param bufnr integer
---@return boolean
local function is_disabled(bufnr)
  return vim.b[bufnr].venv_selector_disabled == true
end

---@param bufnr integer
---@return boolean
local function is_uv_buffer(bufnr)
  local ok, uv2 = pcall(require, "venv-selector.uv2")
  return ok and uv2.is_uv_buffer(bufnr)
end

---@param path string|nil
---@return boolean
local function readable(path)
  return type(path) == "string" and path ~= "" and vim.fn.filereadable(path) == 1
end

---@param bufnr integer
---@return string|nil
local function file_directory(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil
  end
  return vim.fs.dirname(name)
end

---@param dir string
---@return string|nil project_root
local function search_root(dir)
  -- Prefer the repository root so a shared root-level venv can be found from a
  -- nested package that only has its own project metadata. When there is no
  -- git repo, allow a venv above the nearest project marker to be found too.
  return vim.fs.root(dir, { ".git" })
    or vim.fs.root(dir, venv_dir_names)
    or vim.fs.root(dir, root_markers)
    or dir
end

---@param dir string
---@return string|nil project_scope
local function project_scope(dir)
  -- Pass the marker list as one "equal priority" group so the nearest marker
  -- wins regardless of its type (avoids a root .git shadowing a package venv).
  return vim.fs.root(dir, { scope_markers }) or dir
end

---@param parent string
---@param child string
---@return boolean
local function path_contains(parent, child)
  local p = vim.fs.normalize(parent)
  local c = vim.fs.normalize(child)
  return c == p or c:sub(1, #p + 1) == p .. "/"
end

---@param a string
---@param b string
---@return boolean
local function same_project(a, b)
  return path_contains(a, b) or path_contains(b, a)
end

---@param dir string
---@return table|nil
local function find_local_venv(dir)
  for _, name in ipairs(venv_dir_names) do
    for _, rel in ipairs(python_rel_paths) do
      local python = vim.fs.joinpath(dir, name, rel)
      if readable(python) then
        return { python = python, env_type = "venv", source = "auto:" .. name }
      end
    end
  end
end

---@param path string
---@return string|nil
local function read_first_line(path)
  local ok, lines = pcall(vim.fn.readfile, path, "", 1)
  if not ok or not lines[1] then
    return nil
  end
  return vim.trim(lines[1])
end

---@param dir string
---@return table|nil
local function find_pyenv(dir)
  local version = read_first_line(vim.fs.joinpath(dir, ".python-version"))
  if not version or version == "" or version == "system" then
    return nil
  end

  local pyenv_root = vim.env.PYENV_ROOT or vim.fs.joinpath(vim.fn.expand("~"), ".pyenv")
  local python = vim.fs.joinpath(pyenv_root, "versions", version, "bin", "python")
  if readable(python) then
    return { python = python, env_type = "venv", source = "auto:pyenv" }
  end
end

---@return string[]
local function conda_bases()
  local bases = {}

  if vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX ~= "" then
    local prefix = vim.fs.normalize(vim.env.CONDA_PREFIX)
    local parent = vim.fs.dirname(prefix)
    if vim.fs.basename(parent) == "envs" then
      bases[#bases + 1] = vim.fs.dirname(parent)
    else
      bases[#bases + 1] = prefix
    end
  end

  local home = vim.fn.expand("~")
  for _, path in ipairs({
    vim.fs.joinpath(home, ".conda"),
    vim.fs.joinpath(home, "miniconda3"),
    vim.fs.joinpath(home, "anaconda3"),
    vim.fs.joinpath(home, "miniforge3"),
    vim.fs.joinpath(home, "mambaforge"),
    "/opt/homebrew/Caskroom/miniconda/base",
    "/opt/anaconda3",
    "/opt/miniconda3",
  }) do
    bases[#bases + 1] = path
  end

  return bases
end

---@param dir string
---@param name string
---@return string|nil
local function find_conda_env(dir, name)
  for _, base in ipairs(conda_bases()) do
    if base then
      if name == "base" then
        local python = vim.fs.joinpath(base, "bin", "python")
        if readable(python) then
          return python
        end
      end

      local python = vim.fs.joinpath(base, "envs", name, "bin", "python")
      if readable(python) then
        return python
      end
    end
  end

  -- Conda keeps a list of every environment it knows about, including ones in
  -- non-standard locations.
  local envs_file = vim.fs.joinpath(vim.fn.expand("~"), ".conda", "environments.txt")
  if vim.fn.filereadable(envs_file) == 1 then
    local ok, lines = pcall(vim.fn.readfile, envs_file)
    if ok then
      for _, line in ipairs(lines) do
        line = vim.trim(line)
        if line ~= "" and vim.fs.basename(line) == name then
          local python = vim.fs.joinpath(line, "bin", "python")
          if readable(python) then
            return python
          end
        end
      end
    end
  end

  -- Fall-back for projects that keep an environment inside the repository.
  local python = vim.fs.joinpath(dir, name, "bin", "python")
  if readable(python) then
    return python
  end
end

---@param dir string
---@return table|nil
local function find_conda(dir)
  local yaml
  for _, name in ipairs({ "environment.yml", "environment.yaml" }) do
    local path = vim.fs.joinpath(dir, name)
    if vim.fn.filereadable(path) == 1 then
      yaml = path
      break
    end
  end
  if not yaml then
    return nil
  end

  local env_name
  local ok, lines = pcall(vim.fn.readfile, yaml)
  if ok then
    for _, line in ipairs(lines) do
      local name = line:match([[^%s*name:%s*["']?([%w._-]+)["']?%s*$]])
      if name then
        env_name = name
        break
      end
    end
  end
  if not env_name then
    return nil
  end

  local python = find_conda_env(dir, env_name)
  if python then
    return { python = python, env_type = "anaconda", source = "auto:conda" }
  end
end

---@param dir string
---@return table|nil
local function find_python_in_dir(dir)
  return find_local_venv(dir) or find_pyenv(dir) or find_conda(dir)
end

---@param bufnr integer
---@return table|nil candidate
local function find_python(bufnr)
  local dir = file_directory(bufnr)
  if not dir then
    return nil
  end

  local stop = search_root(dir)
  local current = dir
  local depth = 0

  while current and depth < 16 do
    local candidate = find_python_in_dir(current)
    if candidate then
      return candidate
    end

    if vim.fs.normalize(current) == vim.fs.normalize(stop) then
      break
    end

    local parent = vim.fs.dirname(current)
    if not parent or parent == current then
      break
    end

    current = parent
    depth = depth + 1
  end

  return nil
end

---Read a project's cached interpreter without triggering venv-selector's own
---restore flow. A cache entry means the user picked an environment explicitly.
---@param root string|nil
---@return string|nil
local function cached_python_for_root(root)
  if not root then
    return nil
  end

  local ok, config = pcall(require, "venv-selector.config")
  if not ok then
    return nil
  end

  local file = config.user_settings
    and config.user_settings.cache
    and config.user_settings.cache.file
  if type(file) ~= "string" or file == "" then
    return nil
  end

  file = vim.fn.expand(file)
  if vim.fn.filereadable(file) ~= 1 then
    return nil
  end

  local read_ok, lines = pcall(vim.fn.readfile, file, "", 1)
  if not read_ok or not lines[1] then
    return nil
  end

  local decode_ok, decoded = pcall(vim.fn.json_decode, lines[1])
  if not decode_ok or type(decoded) ~= "table" then
    return nil
  end

  local info = decoded[root]
  local python = type(info) == "table" and info.value or nil
  if readable(python) then
    return python
  end
end

---Return the active interpreter when it belongs to this buffer's project.
---@param bufnr integer
---@return string|nil python
---@return string|nil env_type
local function active_env_for_buffer(bufnr)
  local dir = file_directory(bufnr)
  if not dir then
    return nil
  end

  local path = require("venv-selector.path")
  local current = path.current_python_path
  if not current then
    return nil
  end

  local root = project_scope(dir)
  local active_root = require("venv-selector.venv").active_project_root()

  if active_root and same_project(root, active_root) then
    return current, path.current_type
  end
  if path_contains(root, current) then
    return current, path.current_type
  end

  return nil
end

---Return true when an attached Python LSP still needs the selected interpreter.
---@param bufnr integer
---@param python string
---@return boolean
local function needs_lsp_update(bufnr, python)
  local hooks = require("venv-selector.hooks")

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if hooks.is_python_lsp(client) and client.name ~= "ruff" and client.name ~= "ruff_lsp" then
      local settings = client.config and client.config.settings or {}
      if not (settings.python and settings.python.pythonPath == python) then
        return true
      end
    end
  end

  return false
end

---@param bufnr integer
---@return boolean
function M.maybe_activate(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not valid_python_buf(bufnr) or is_disabled(bufnr) or is_uv_buffer(bufnr) then
    return false
  end

  local candidate = find_python(bufnr)
  if not candidate then
    return false
  end

  local dir = file_directory(bufnr)
  if not dir then
    return false
  end
  local scope = project_scope(dir)

  local path = require("venv-selector.path")
  local venv = require("venv-selector.venv")
  local project_root = require("venv-selector.project_root")

  local current = path.current_python_path
  local active_root = venv.active_project_root()

  if current == candidate.python then
    -- Track the environment for this project even when the interpreter is
    -- shared with another project.
    venv.activate_for_buffer(candidate.python, candidate.env_type, bufnr, { save_cache = false })

    if (not active_root or not same_project(scope, active_root)) or needs_lsp_update(bufnr, candidate.python) then
      local root = project_root.key_for_buf(bufnr)
      local hooks = require("venv-selector.hooks")
      hooks.clear_restart_memo_for_root(root)
      hooks.dynamic_python_lsp_hook(candidate.python, candidate.env_type, bufnr)
    end

    return false
  end

  -- A manual selection in this buffer wins, even before its cache restore runs.
  local last = vim.b[bufnr].venv_selector_last_python
  if type(last) == "string" and last ~= "" and last ~= candidate.python then
    return false
  end

  -- Respect an explicit cached choice for this project. If the cache already
  -- points at the interpreter we found, activation below is harmless.
  local root = project_root.key_for_buf(bufnr)
  local cached = cached_python_for_root(root)
  if cached and cached ~= candidate.python then
    return false
  end

  if current and active_root then
    -- Keep an environment that is already active for this project.
    if same_project(scope, active_root) then
      return false
    end

    -- Also keep a manually selected interpreter that lives inside the project.
    if path_contains(scope, current) then
      return false
    end
  end

  venv.set_source(candidate.source)
  return venv.activate_for_buffer(candidate.python, candidate.env_type, bufnr, { save_cache = false })
end

---@param bufnr integer
local function schedule(bufnr)
  local key = tostring(bufnr)
  local timer = timers[key]
  if timer then
    timer:stop()
    timer:close()
    timers[key] = nil
  end

  local new_timer = uv.new_timer()
  if not new_timer then
    return
  end

  timers[key] = new_timer
  new_timer:start(
    1200,
    0,
    vim.schedule_wrap(function()
      if timers[key] == new_timer then
        timers[key] = nil
      end
      new_timer:close()

      -- The environment is global, so only activate for the buffer the user is
      -- actually looking at. Returning later schedules a fresh check.
      if bufnr == vim.api.nvim_get_current_buf() then
        M.maybe_activate(bufnr)
      end
    end)
  )
end

function M.setup()
  local group = vim.api.nvim_create_augroup("PythonAutoEnv", { clear = true })

  local function on_event(args)
    local bufnr = args.buf
    if not valid_python_buf(bufnr) or is_disabled(bufnr) or is_uv_buffer(bufnr) then
      return
    end
    schedule(bufnr)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = on_event,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    callback = on_event,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = on_event,
  })

  -- If an environment was activated before Pyright/Ruff finished starting, the
  -- plugin's restart hook had no client to update. Re-run it once the LSP
  -- attaches so the interpreter is applied to that client too.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      local ok, hooks = pcall(require, "venv-selector.hooks")
      if not ok or not hooks.is_python_lsp or not hooks.is_python_lsp(client) then
        return
      end
      if client.config and client.config._venv_selector == true then
        return
      end

      -- Ruff does not need the interpreter path; Pyright/basedpyright do.
      if client.name == "ruff" or client.name == "ruff_lsp" then
        return
      end

      local bufnr = args.buf
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or not valid_python_buf(bufnr) then
          return
        end

        local python, env_type = active_env_for_buffer(bufnr)
        if not python then
          return
        end

        local current = vim.lsp.get_client_by_id(args.data.client_id)
        if not current or (current.config and current.config._venv_selector == true) then
          return
        end

        local settings = current.config and current.config.settings or {}
        if settings.python and settings.python.pythonPath == python then
          return
        end

        -- Clear the plugin's per-root memo: it may have restarted another
        -- Python client before this one attached.
        local root = require("venv-selector.project_root").key_for_buf(bufnr)
        hooks.clear_restart_memo_for_root(root)
        hooks.dynamic_python_lsp_hook(python, env_type, bufnr)
      end, 100)
    end,
  })
end

return M
