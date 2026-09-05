# Installation

## macOS

1. `xcode-select --install`

2. `git clone git@github.com:AndreyCJ/dotfiles.git ~/dotfiles`

3. `~/dotfiles/bin/install.sh`

## Arch Linux (Omarchy)

1. `git clone git@github.com:AndreyCJ/dotfiles.git ~/dotfiles`

2. `~/dotfiles/bin/install.sh`

   Manual (explicit stow):

   ```bash
   sudo pacman -S stow zsh
   cd ~/dotfiles
   stow git nvim starship tmux vim wakatime zsh ghostty ssh vscode-linux hypr omarchy
   ```

   macOS equivalent:

   ```bash
   stow git nvim starship tmux vim wakatime zsh ghostty ssh vscode-macos aerospace
   ```

   or just

   ```bash
    cd ~/dotfiles
    stow .
   ```

## Packages

- `vscode-macos` → `~/Library/Application Support/Code/User/` (macOS)
- `vscode-linux` → `~/.config/Code/User/` (Linux)
- `nvim` → `~/.config/nvim/` (LazyVim)
- `hypr` / `omarchy` → Linux only
- `aerospace` → macOS only

