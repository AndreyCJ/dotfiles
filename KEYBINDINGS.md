# Keybinds

## Terminal

### fzf

- Ctrl+R → search history
- Ctrl+T → search files
- Alt+C → search dirs

### Zsh / command line editing

- Ctrl+F → accept autosuggestion
- Ctrl+A → go to beginning of line
- Ctrl+E → go to end of line
- Ctrl+W → delete word before cursor
- Ctrl+U → clear line before cursor
- Ctrl+K → kill line after cursor
- Ctrl+L → clear screen
- Ctrl+Z → suspend current process
- Ctrl+D → exit shell (or EOF)
- Tab → autocomplete
- Up / Down arrows → history navigation

## nvim

Leader key is `<Space>`. Press `<Space>` alone to see the menu of everything, or `<leader>sk` to browse all keymaps.

### Searching

**Find a file** — `<Space><Space>` (or `<Space>` `ff`). Fuzzy-searches the whole project folder, hidden files included. Type part of the name and hit Enter.

**Find text across the project** — `<Space>` `sg` greps every file in the folder with ripgrep.

**Find text in the current file** — `/` then type your search, Enter. Jump between matches with `n` (next) and `N` (previous). `*` searches for the word under the cursor.

### Files & buffers

- `<Space>` `fb` — pick from open buffers (also `<S-h>` / `<S-l>` to cycle)
- `<Space>` `fr` — recently opened files
- `<Space>` `e` — toggle file explorer (side panel), `H` shows hidden files there

### Editing

- `u` / `Ctrl+r` — undo / redo
- `dd` / `yy` / `p` — delete line / copy line / paste
- `gcc` — toggle comment on a line
- `gg` / `G` — jump to top / bottom of file

### Code (LSP)

- `gd` — go to definition · `gr` — find references · `K` — hover docs
- `<Space>` `ca` — code actions · `<Space>` `cr` — rename · `<Space>` `cf` — format

### Git

- `<Space>` `gg` — lazygit · `<Space>` `gs` — status · `<Space>` `gb` — blame

### Windows

- `<Space>` `-` / `<Space>` `|` — horizontal / vertical split
- `Ctrl+h/j/k/l` — jump between split windows
- `<Space>` `qq` — quit all · `Ctrl+s` — save