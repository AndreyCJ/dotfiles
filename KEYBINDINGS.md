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


## Aerospace

AeroSpace is an i3-like tiling window manager for macOS. Unlike yabai, it doesn't require disabling System Integrity Protection (SIP), making it safer and easier to set up. The YADRLite configuration uses vim-style keybindings with Alt as the modifier key.

### AeroSpace Shortcuts

AeroSpace uses `Alt` (Option) as the primary modifier. After installation, grant Accessibility permissions when prompted (System Settings > Privacy & Security > Accessibility).

#### Window Focus

- `Alt+h`: Focus window to the left
- `Alt+j`: Focus window below
- `Alt+k`: Focus window above
- `Alt+l`: Focus window to the right

#### Window Movement

- `Alt+Shift+h`: Move window left
- `Alt+Shift+j`: Move window down
- `Alt+Shift+k`: Move window up
- `Alt+Shift+l`: Move window right

#### Workspaces

- `Alt+1` through `Alt+9`: Switch to workspace 1-9
- `Alt+Shift+1` through `Alt+Shift+9`: Move window to workspace 1-9

#### Layout Controls

- `Alt+/`: Toggle between horizontal and vertical tiling
- `Alt+,`: Toggle accordion layout
- `Alt+f`: Toggle fullscreen
- `Alt+Shift+f`: Toggle floating/tiling mode

#### Splits

- `Alt+\`: Split horizontally
- `Alt+Shift+\`: Split vertically

#### Resize

- `Alt+-`: Shrink window
- `Alt+=`: Expand window

#### Theme

- `Alt+t`: Toggle theme (SeaShells dark/light)

#### Service Mode

- `Alt+Shift+;`: Enter service mode
  - `Esc`: Reload config and return to main mode
  - `r`: Flatten workspace tree
  - `Backspace`: Close all windows except current

#### Float Rules

The following applications open as floating windows by default:

- Finder
- System Settings/Preferences
- Calculator
- Preview

## Mixed Layouts (Accordion + Tiles)

AeroSpace uses a tree structure where each container can have its own layout. This is useful for widescreen monitors where you want different layouts on each side of the screen.

**Example: Accordion on the left, single window on the right**

```
┌─────────────────┬─────────────────┐
│   [Accordion]   │                 │
│   ┌─────────┐   │    Single       │
│   │ Window1 │   │    Window       │
│   │ Window2 │   │    (tiles)      │
│   │ Window3 │   │                 │
│   └─────────┘   │                 │
└─────────────────┴─────────────────┘
```

**How to set it up:**

1. Open two windows - they'll tile horizontally by default
2. Focus the left window
3. Press `Alt+,` to switch that side to accordion
4. Open more windows while focused on the left - they stack in the accordion
5. The right side remains unaffected (tiles layout)

**Useful keybindings for mixed layouts:**

- `Alt+,`: Toggle accordion layout (affects only the focused container)
- `Alt+/`: Toggle between horizontal and vertical tiling

