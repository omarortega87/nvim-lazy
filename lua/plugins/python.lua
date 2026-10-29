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
  },
}
