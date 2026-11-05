# IDE configuration using LazyVim

## Java / Kotlin language server

This config supports two mutually exclusive Java/Kotlin language backends:

| Backend | Implementation | Covers |
| --- | --- | --- |
| `jdtls` (default) | `nvim-jdtls` and LazyVim's Java extra | Java |
| `intellij` | [intellij-lsp.nvim](https://github.com/JetBrains/intellij-lsp.nvim) | Java and Kotlin |

### Switching backends

```vim
:JavaLsp status
:JavaLsp intellij
:restart
```

`:JavaLsp status` shows the configured backend and any attached `jdtls` or
`intellij` clients. Changing the backend requires `:restart` because lazy.nvim
evaluates the plugin specs at startup.

Switch back to JDTLS with:

```vim
:JavaLsp jdtls
:restart
```

The choice is persisted in `stdpath("state")/java_lsp_backend`. You can override
it per session or permanently:

- Per session: `NVIM_JAVA_LSP=intellij nvim`
- Permanently: `vim.g.java_lsp = "intellij"` in `lua/config/options.lua`

Precedence is `NVIM_JAVA_LSP` → `vim.g.java_lsp` → the saved choice → `jdtls`.

### Mutual exclusion

Only one backend is loaded:

- `nvim-jdtls` has `cond = java.is("jdtls")`.
- `intellij-lsp.nvim` has `cond = java.is("intellij")`.

The unselected plugin is never loaded, so it cannot start its server or attach to
buffers. Once installed, both plugins stay installed, so switching does not
require reinstalling. The JDTLS configuration is unchanged when `jdtls` is
selected.

The IntelliJ backend is tuned to coexist with the rest of this config:

- `blink.cmp` owns completion, signature help, and `<CR>`.
- The bundled `islands-dark` colorscheme is disabled.
- `format_on_save` is disabled; use `:IntellijLspFormat` (or configure conform).
- The plugin's own hierarchy/symbol mappings are disabled. This config adds:
  - `<leader>cjt` / `<leader>cjT` — type hierarchy: subtypes / supertypes
  - `<leader>cji` / `<leader>cjo` — call hierarchy: incoming / outgoing
  - `<leader>cjs` — search workspace symbols
  - `<leader>db` / `<leader>dB` — toggle / conditional breakpoint
- `<leader>co` stays LazyVim's Organize Imports.

See `KEYBINDINGS.md` for the full list of IntelliJ run/debug/hierarchy mappings.

### First switch to IntelliJ

Nothing is downloaded until you select the backend:

1. Run `:JavaLsp intellij`.
2. Run `:restart`.
3. lazy.nvim installs `intellij-lsp.nvim`; on first start the plugin downloads
   the separate `intellij-server` bundle.
4. Answer the EULA, region, and telemetry prompts, or pre-set
   `accept_eula`/`region`/`data_sharing` in `lua/plugins/java.lua`.
5. Verify with `:checkhealth intellij-lsp`.
6. Activate a license with `:IntellijLspLicense` when needed.

Notes on the IntelliJ backend:

- The plugin is pre-alpha: features, options, and commands may change without
  deprecation.
- The server requires about 2 GB of free memory; Maven/Gradle import needs more.
- The server is free for a 30-day trial, after which it needs an IntelliJ IDEA
  Ultimate subscription. `:IntellijLspLicense` manages the license afterwards.
- Do not lazy-load it on `ft = { "java", "kotlin" }`; the eager build-file import
  requires the plugin to be loaded at startup.

### Troubleshooting

- `:JavaLsp status` — confirm which backend is configured and which clients are
  attached.
- `:checkhealth intellij-lsp` — check the IntelliJ server, bundle, and license.
- If only one backend should be active but both appear attached, restart Neovim
  so lazy.nvim re-evaluates the plugin specs.
- If the IntelliJ server is silent or refuses requests, inspect the license with
  `:IntellijLspLicense` and the EULA/telemetry answers with
  `:IntellijLspLicense setup`.

## Backup

Make a backup of your current Neovim files:

# required

```shell
mv ~/.config/nvim{,.bak}

> 
```

# optional but recommended

```shell
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

- Clone the started

```shell
git clone https://github.com/omarortega87/nvim-lazy.git~/.config/nvim
```

- Remove the .git folder

`rm -rf ~/.config/nvim/.git`


- Start Neovim

`nvim`
