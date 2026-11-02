return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- jdtls 1.6x snapshots require Java 25+ on the VM that runs the server.
      -- The shell default here is JDK 21, so point jdtls at the newer Homebrew JDK.
      opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }
      vim.list_extend(opts.cmd, { "--java-executable", "/opt/homebrew/opt/openjdk/bin/java" })
    end,
  },
}
