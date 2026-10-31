# Keybindings

`<leader>` is **Space** and `<localleader>` is **`\`**.

> This file documents the custom keybindings in this config plus the most useful
> LazyVim defaults. To browse the live, complete list, press `<leader>sk`
> (Snacks picker → Keymaps) or `<leader>?` (which-key for the current buffer).

## Custom keybindings

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>uk` | n | Toggle completion on/off |
| `<C-Space>` | i | Trigger completion manually |

There are no custom tab mappings. The `<leader><tab>` group is left to LazyVim
so that `<leader><tab>]`, `<leader><tab>[`, `<leader><tab><tab>`, and the other
tab actions keep working.

The mappings in `lua/plugins/example.lua` are **not active** because that file
returns early (`if true then return {} end`). Its `<leader>fp`, `<leader>co`, and
`<leader>cR` examples are therefore not registered.

## Completion (blink.cmp)

The completion menu opens automatically when you type a keyword or a trigger
character such as `.` or `(`. Ghost text is disabled, and selecting an item does
not insert it until you accept it. The first item is preselected, so `<CR>`
accepts it directly. Press `<C-Space>` to open the menu manually at any time.

| Key | Mode | Description |
| --- | --- | --- |
| `<C-Space>` | i | Show completion menu / toggle documentation |
| `<C-n>` | i | Select next item |
| `<C-p>` | i | Select previous item |
| `<Down>` | i | Select next item |
| `<Up>` | i | Select previous item |
| `<CR>` | i | Accept selected item |
| `<C-y>` | i | Accept selected item (LazyVim mapping) |
| `<C-e>` | i | Cancel selection / hide menu |
| `<Tab>` | i | Jump to next snippet placeholder |
| `<S-Tab>` | i | Jump to previous snippet placeholder |
| `<C-b>` | i | Scroll documentation up |
| `<C-f>` | i | Scroll documentation down |
| `<C-k>` | i | Toggle signature help |

## Navigation and windows

| Key | Mode | Description |
| --- | --- | --- |
| `<C-h>` | n | Go to left window |
| `<C-j>` | n | Go to lower window |
| `<C-k>` | n | Go to upper window |
| `<C-l>` | n | Go to right window |
| `<C-Up>` | n | Increase window height |
| `<C-Down>` | n | Decrease window height |
| `<C-Left>` | n | Decrease window width |
| `<C-Right>` | n | Increase window width |
| `<leader>-` | n | Split window below |
| `<leader>\|` | n | Split window right |
| `<leader>wd` | n | Delete window |
| `<leader>wm` | n | Toggle window zoom |
| `<leader>uZ` | n | Toggle window zoom |
| `<leader>uz` | n | Toggle zen mode |
| `<c-w><space>` | n | Window hydra mode (which-key) |

## Buffers

| Key | Mode | Description |
| --- | --- | --- |
| `<S-h>` | n | Previous buffer |
| `<S-l>` | n | Next buffer |
| `[b` | n | Previous buffer |
| `]b` | n | Next buffer |
| `<leader>bb` | n | Switch to other buffer |
| `<leader>` + backtick | n | Switch to other buffer |
| `<leader>bd` | n | Delete buffer |
| `<leader>bo` | n | Delete other buffers |
| `<leader>bi` | n | Delete invisible buffers |
| `<leader>bD` | n | Delete buffer and window |

## Tabs

| Key | Mode | Description |
| --- | --- | --- |
| `<leader><tab>l` | n | Last tab |
| `<leader><tab>o` | n | Close other tabs |
| `<leader><tab>f` | n | First tab |
| `<leader><tab><tab>` | n | New tab |
| `<leader><tab>]` | n | Next tab |
| `<leader><tab>[` | n | Previous tab |
| `<leader><tab>d` | n | Close tab |

These are LazyVim defaults. No direct `<leader><tab>` mapping overrides them.

## Files, search, and pickers

| Key | Mode | Description |
| --- | --- | --- |
| `<leader><space>` | n | Find files (root dir) |
| `<leader>ff` | n | Find files (root dir) |
| `<leader>fF` | n | Find files (cwd) |
| `<leader>fg` | n | Find git files |
| `<leader>fr` | n | Recent files |
| `<leader>fp` | n | Projects |
| `<leader>fc` | n | Find config file |
| `<leader>fn` | n | New file |
| `<leader>/` | n | Grep (root dir) |
| `<leader>sg` | n | Live grep (root dir) |
| `<leader>sG` | n | Live grep (cwd) |
| `<leader>sw` | n, x | Grep word / visual selection (root dir) |
| `<leader>sW` | n, x | Grep word / visual selection (cwd) |
| `<leader>sb` | n | Buffer lines |
| `<leader>sd` | n | Diagnostics |
| `<leader>sD` | n | Buffer diagnostics |
| `<leader>ss` | n | LSP symbols |
| `<leader>sS` | n | LSP workspace symbols |
| `<leader>sr` | n, x | Search and replace |
| `<leader>sR` | n | Resume last picker |
| `<leader>su` | n | Undo tree |
| `<leader>st` | n | Todo comments |
| `<leader>sT` | n | Todo / FIX / FIXME |
| `<leader>sh` | n | Help pages |
| `<leader>sm` | n | Marks |
| `<leader>sj` | n | Jumps |
| `<leader>s"` | n | Registers |
| `<leader>s/` | n | Search history |
| `<leader>sc` | n | Command history |
| `<leader>sC` | n | Commands |
| `<leader>sk` | n | Keymaps |
| `<leader>,` | n | Buffers |
| `<leader>:` | n | Command history |
| `<leader>n` | n | Notification history |

## LSP and code

| Key | Mode | Description |
| --- | --- | --- |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `gI` | n | Go to implementation |
| `gy` | n | Go to type definition |
| `gr` | n | References |
| `K` | n | Hover documentation |
| `gK` | n | Signature help |
| `<C-k>` | i | Signature help |
| `]]` | n | Next reference |
| `[[` | n | Previous reference |
| `<A-n>` | n | Next reference (current word) |
| `<A-p>` | n | Previous reference (current word) |
| `<leader>ca` | n, x | Code action |
| `<leader>cr` | n | Rename symbol |
| `<leader>cR` | n | Rename file |
| `<leader>cA` | n | Source action |
| `<leader>cc` | n, x | Run codelens |
| `<leader>cC` | n | Refresh and display codelens |
| `<leader>cf` | n, x | Format buffer |
| `<leader>co` | n | Organize imports (when supported) |
| `<leader>cl` | n | LSP info |
| `<leader>cm` | n | Mason |
| `<leader>cs` | n | Symbols (Trouble) |
| `<leader>cS` | n | LSP references/definitions (Trouble) |

## Diagnostics and quickfix

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>cd` | n | Line diagnostics |
| `]d` | n | Next diagnostic |
| `[d` | n | Previous diagnostic |
| `]e` | n | Next error |
| `[e` | n | Previous error |
| `]w` | n | Next warning |
| `[w` | n | Previous warning |
| `<leader>xx` | n | Diagnostics (Trouble) |
| `<leader>xX` | n | Buffer diagnostics (Trouble) |
| `<leader>xL` | n | Location list (Trouble) |
| `<leader>xQ` | n | Quickfix list (Trouble) |
| `<leader>xt` | n | Todo comments (Trouble) |
| `<leader>xT` | n | Todo / FIX / FIXME (Trouble) |
| `]q` | n | Next quickfix item |
| `[q` | n | Previous quickfix item |
| `<leader>xq` | n | Toggle quickfix list |
| `<leader>xl` | n | Toggle location list |

## Git

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>gg` | n | Lazygit (root dir) |
| `<leader>gG` | n | Lazygit (cwd) |
| `<leader>gs` | n | Git status |
| `<leader>gd` | n | Git diff (hunks) |
| `<leader>gD` | n | Git diff (origin) |
| `<leader>gl` | n | Git log |
| `<leader>gL` | n | Git log (cwd) |
| `<leader>gb` | n | Git blame line |
| `<leader>gf` | n | Current file history |
| `<leader>gB` | n, x | Open in browser |
| `<leader>gY` | n, x | Copy URL to clipboard |
| `<leader>ghs` | n, x | Stage hunk |
| `<leader>ghr` | n, x | Reset hunk |
| `<leader>ghS` | n | Stage buffer |
| `<leader>ghu` | n | Undo stage hunk |
| `<leader>ghR` | n | Reset buffer |
| `<leader>ghp` | n | Preview hunk inline |
| `<leader>ghb` | n | Blame line |
| `<leader>ghB` | n | Blame buffer |
| `<leader>ghd` | n | Diff this |
| `<leader>ghD` | n | Diff this against `~` |

## Editing

| Key | Mode | Description |
| --- | --- | --- |
| `<C-s>` | n, i, x, s | Save file |
| `<esc>` | n, i, s | Clear search highlight / stop snippet |
| `j` / `k` | n, x | Move down / up by screen line |
| `<A-j>` / `<A-k>` | n, i, v | Move line(s) down / up |
| `<` / `>` | x | Indent and keep selection |
| `gco` | n | Add comment below |
| `gcO` | n | Add comment above |
| `n` / `N` | n, x, o | Next / previous search result |
| `<leader>K` | n | Run `keywordprg` |
| `<leader>ur` | n | Redraw / clear search / update diff |
| `<leader>l` | n | Open Lazy |
| `<leader>?` | n | Buffer keymaps (which-key) |

## Toggles

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>uf` | n | Auto format (buffer) |
| `<leader>uF` | n | Auto format (global) |
| `<leader>us` | n | Spell checking |
| `<leader>uw` | n | Wrap |
| `<leader>uL` | n | Relative number |
| `<leader>ud` | n | Diagnostics |
| `<leader>ul` | n | Line numbers |
| `<leader>uc` | n | Conceal level |
| `<leader>uA` | n | Tabline |
| `<leader>uT` | n | Treesitter |
| `<leader>ub` | n | Dark background |
| `<leader>uD` | n | Dim mode |
| `<leader>ua` | n | Animations |
| `<leader>ug` | n | Indent guides |
| `<leader>uS` | n | Smooth scrolling |
| `<leader>uh` | n | Inlay hints |
| `<leader>ui` | n | Inspect position |
| `<leader>uI` | n | Inspect treesitter tree |
| `<leader>uk` | n | Completion (custom) |

## Sessions and quit

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>qs` | n | Restore session |
| `<leader>qS` | n | Select session |
| `<leader>ql` | n | Restore last session |
| `<leader>qd` | n | Don't save current session |
| `<leader>qq` | n | Quit all |

## Terminal

| Key | Mode | Description |
| --- | --- | --- |
| `<leader>ft` | n | Terminal (root dir) |
| `<leader>fT` | n | Terminal (cwd) |
| `<C-/>` | n, t | Focus terminal (root dir) |
| `<C-_>` | n, t | Focus terminal (root dir) |

## Dashboard (Snacks)

| Key | Description |
| --- | --- |
| `f` | Find files |
| `g` | Live grep |
| `r` | Recent files |
| `n` | New file |
| `s` | Restore session |
| `c` | Find config file |
| `l` | Open Lazy |
| `q` | Quit |

## Discover more

- `<leader>sk` — search all keymaps with Snacks picker.
- `<leader>?` — show which-key mappings for the current buffer.
- `:map` — list normal-mode mappings.
- `:verbose map <key>` — show where a mapping was defined.
