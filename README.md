# Installation

## macOS

1. `xcode-select --install`

2. `git clone git@github.com:AndreyCJ/dotfiles.git ~/dotfiles`  # or ~/Dotfiles (both work)

3. `~/dotfiles/bin/install.sh`  # installs Brewfile, stows aerospace + vscode-macos, etc.

## Arch Linux (Omarchy)

1. `git clone git@github.com:AndreyCJ/dotfiles.git ~/dotfiles`

2. `~/dotfiles/bin/install.sh`  # auto-detects Linux: installs pacman deps, stows vscode-linux + hypr + omarchy

   Manual (explicit stow):
   ```bash
   sudo pacman -S stow zsh
   cd ~/dotfiles
   stow git starship tmux vim wakatime zsh ghostty ssh vscode-linux hypr omarchy
   ```

   macOS equivalent:
   ```bash
   stow git starship tmux vim wakatime zsh ghostty ssh vscode-macos aerospace
   ```

> Repo is source of truth — fresh Omarchy configs (ghostty/starship/tmux/Code) are overwritten.

## Packages
- `vscode-macos` → `~/Library/Application Support/Code/User/` (macOS)
- `vscode-linux` → `~/.config/Code/User/` (Linux)
- `hypr` / `omarchy` → Linux only
- `aerospace` → macOS only
- `ghostty` / `starship` / `tmux` → cross-platform (repo wins)

# Terminal

fzf:

- Ctrl+R → поиск по history
- Ctrl+T → поиск файлов
- Alt+C → поиск директорий
